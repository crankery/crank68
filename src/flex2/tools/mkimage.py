#!/usr/bin/env python3
"""Build a deterministic 1 MiB FLEX disk and link its RAM boot sector."""
from pathlib import Path
import json
import runpy
from stories import story_files
from disk_layout import DRIVES, TRACKS, SECTORS, DRIVE_BYTES, LABELS, file_drive

distribution_files = runpy.run_path(str(Path(__file__).with_name("source-disk.py")))["distribution_files"]

SECTOR = 256
SECTORS_PER_TRACK = 16


def binary_records(data, address, entry):
    """FLEX binary records: 02 addr-hi addr-lo count data; 16 entry-hi entry-lo."""
    result = bytearray()
    for offset in range(0, len(data), 255):
        part = data[offset:offset + 255]
        result.extend(b'\x02' + (address + offset).to_bytes(2, 'big') + bytes([len(part)]) + part)
    result.extend(b'\x16' + entry.to_bytes(2, 'big'))
    return bytes(result)


def ts(index):
    return bytes([index // SECTORS_PER_TRACK, index % SECTORS_PER_TRACK + 1])


def make_image():
    root = Path('build')
    z68 = (root / 'z68.bin').read_bytes()
    assert 0 < len(z68) <= 0x7E00 - 0x0300, 'Z68 overlaps its reserved stack or FLEX'
    files = [
        ('Z68.CMD', binary_records(z68, 0x0300, 0x0300)),
        ('FLEX2.SYS', binary_records((root / 'c68flex.bin').read_bytes(), 0xA100, 0xAD00)),
        ('MSBASIC.CMD', binary_records((root / 'msbasic.bin').read_bytes(), 0, 0)),
    ]
    files.extend(distribution_files())
    stories = story_files()
    image = bytearray()
    drives = []
    for drive in range(DRIVES):
        selected = [(name, payload) for name, payload in files if file_drive(name) == drive]
        if drive == 3:
            selected.extend(stories)
            for name in ('CZECH.DAT', 'VMBOOT.DAT', 'VMFAIL.DAT', 'VMLIMIT.DAT'):
                assert name not in dict(stories), f'Local story name reserved for acceptance tests: {name}'
                selected.append((name, (root / name).read_bytes()))
        disk, manifest, free = make_drive(root, drive, selected)
        image.extend(disk)
        drives.append(dict(drive=drive, label=LABELS[drive], offset=drive * DRIVE_BYTES,
                           files=manifest, free_sectors=free))
    (root / 'flex2.dsk').write_bytes(image)
    (root / 'image.json').write_text(json.dumps(dict(
        geometry=dict(drives=DRIVES, tracks_per_drive=TRACKS,
                      sectors_per_track=16, sector_bytes=256), drives=drives), indent=2) + '\n')
    print(f'Created {len(image):,}-byte SRAM image with {DRIVES} drives: ' +
          ', '.join(f"{d['drive']}: {len(d['files'])} files, {d['free_sectors']} free" for d in drives))


def make_drive(root, drive, files):
    assert len(files) <= 120, "Directory capacity exceeded"
    image = bytearray(DRIVE_BYTES)
    boot = (root / 'boot.bin').read_bytes() if drive == 0 else b''
    assert len(boot) <= SECTOR
    image[:len(boot)] = boot
    # Track 0: boot sectors 1/2, SIR 3, reserved 4, directory sectors 5..16.
    for index in range(4, 16):
        if index < 15:
            image[index * SECTOR:index * SECTOR + 2] = ts(index + 1)
    next_free = 16
    manifest = []
    for number, (name, payload) in enumerate(files):
        count = (len(payload) + 251) // 252
        assert next_free + count < SECTORS, f"Drive {drive} is full"
        start = next_free
        for seq in range(count):
            index = start + seq
            offset = index * SECTOR
            if seq + 1 < count:
                image[offset:offset + 2] = ts(index + 1)
            image[offset + 2:offset + 4] = (seq + 1).to_bytes(2, 'big')
            chunk = payload[seq * 252:(seq + 1) * 252]
            image[offset + 4:offset + 4 + len(chunk)] = chunk
        entry = bytearray(24)
        stem, ext = name.split('.')
        entry[:len(stem)] = stem.encode('ascii')
        entry[8:8 + len(ext)] = ext.encode('ascii')
        entry[13:15] = ts(start)
        entry[15:17] = ts(start + count - 1)
        entry[17:19] = count.to_bytes(2, 'big')
        entry[21:24] = bytes([11, 1, 26])
        offset = (4 + number // 10) * SECTOR + 16 + (number % 10) * 24
        image[offset:offset + 24] = entry
        (root / name).write_bytes(payload)
        manifest.append(dict(name=name, start=list(ts(start)), sectors=count, bytes=len(payload)))
        if name == 'FLEX2.SYS':
            image[5:7] = ts(start)  # LINK's boot-sector convention.
        next_free += count
    for index in range(next_free, SECTORS - 1):
        image[index * SECTOR:index * SECTOR + 2] = ts(index + 1)
    sir = bytearray(24)
    label = LABELS[drive].encode('ascii')
    sir[:len(label)] = label
    sir[13:15] = ts(next_free)
    sir[15:17] = ts(SECTORS - 1)
    sir[17:19] = (SECTORS - next_free).to_bytes(2, 'big')
    sir[19:22] = bytes([11, 1, 26])
    sir[22:24] = bytes([TRACKS - 1, 16])
    image[2 * SECTOR + 16:2 * SECTOR + 40] = sir
    return image, manifest, SECTORS - next_free

if __name__ == '__main__':
    make_image()
