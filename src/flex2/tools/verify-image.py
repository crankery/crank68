#!/usr/bin/env python3
"""Independently walk the directory, files, records, and free-sector chain."""
from pathlib import Path
import sys
import runpy
from stories import story_files
from disk_layout import DRIVES, TRACKS, DRIVE_BYTES, SECTORS, file_drive


def verify_drive(image, drive):
    assert len(image) == DRIVE_BYTES
    seen = {0, 1, 2, 3}  # boot, SIR, reserved

    def index(link):
        track, sector = link
        assert 0 <= track < TRACKS and 1 <= sector <= 16, (track, sector)
        return track * 16 + sector - 1

    def chain(link, sequence=False):
        result = []
        payload = bytearray()
        while link != b'\0\0':
            where = index(link)
            assert where not in seen, f'Sector reused: {list(link)}'
            seen.add(where)
            result.append(where)
            block = image[where * 256:(where + 1) * 256]
            if sequence:
                assert int.from_bytes(block[2:4], 'big') == len(result)
            payload.extend(block[4:])
            link = block[:2]
        return result, payload

    directories, _ = chain(bytes([0, 5]))
    files = {}
    for sector in directories:
        for offset in range(16, 256, 24):
            entry = image[sector*256+offset:sector*256+offset+24]
            if entry[0] in (0, 255):
                continue
            name = entry[:8].rstrip(b'\0').decode() + '.' + entry[8:11].rstrip(b'\0').decode()
            assert name not in files
            sectors, payload = chain(entry[13:15], True)
            assert len(sectors) == int.from_bytes(entry[17:19], 'big')
            assert sectors[-1] == index(entry[15:17])
            files[name] = (entry, payload)
    sir = image[2*256+16:2*256+40]
    free, _ = chain(sir[13:15])
    assert len(free) == int.from_bytes(sir[17:19], 'big')
    assert (free[-1] == index(sir[15:17])) if free else sir[15:17] == b'\0\0'
    assert sir[22:24] == bytes([TRACKS - 1, 16])
    assert len(seen) == SECTORS, 'Lost sectors'
    if drive == 0:
        assert image[5:7] == files['FLEX2.SYS'][0][13:15], 'Boot link mismatch'
    print(f'Drive {drive}: {len(files)} files, {len(free)} free sectors; chains verified.')
    return files


def verify(path):
    image = Path(path).read_bytes()
    assert len(image) == 1024 * 1024
    disks = [verify_drive(image[d * DRIVE_BYTES:(d + 1) * DRIVE_BYTES], d)
             for d in range(DRIVES)]
    for name, binary_name, base, entrypoint in [
        ('FLEX2.SYS', 'c68flex.bin', 0xA100, 0xAD00),
        ('MSBASIC.CMD', 'msbasic.bin', 0, 0),
        ('Z68.CMD', 'z68.bin', 0x0300, 0x0300),
        ('VERA.CMD', 'vera.bin', 0x0300, 0x0300),
        ('BOOP.CMD', 'boop.bin', 0x0300, 0x0300),
    ]:
        payload = disks[file_drive(name)][name][1]
        loaded = {}
        pos = 0
        entry = None
        while pos < len(payload):
            tag = payload[pos]
            pos += 1
            if tag == 0:
                continue
            if tag == 0x16:
                assert entry is None
                entry = int.from_bytes(payload[pos:pos+2], 'big')
                pos += 2
                continue
            assert tag == 2, f'Unexpected record {tag}'
            address = int.from_bytes(payload[pos:pos+2], 'big')
            count = payload[pos+2]
            pos += 3
            assert pos+count <= len(payload)
            for value in payload[pos:pos+count]:
                assert address not in loaded
                loaded[address] = value
                address += 1
            pos += count
        binary = Path('build', binary_name).read_bytes()
        if name in ('Z68.CMD', 'VERA.CMD', 'BOOP.CMD'):
            assert loaded and min(loaded) == 0x0300 and max(loaded) < 0x7E00, f'{name} exceeds application RAM'
        assert entry == entrypoint
        assert loaded == dict(enumerate(binary, base)), name
    source_files = runpy.run_path(str(Path(__file__).with_name('source-disk.py')))['distribution_files']()
    for name, expected in source_files:
        assert bytes(disks[file_drive(name)][name][1]) == expected, (
            f'Imported file differs: {name}. The image may have been modified or '
            'overwritten by an emulator save. Exit the emulator and back up any '
            'wanted files, then run `make rebuild-image` to recreate the initial '
            'disk contents. Use a separate --sram-image working copy.')
    assert 'BUILD.TXT' in disks[0], 'Missing BUILD.TXT: stale image? Run make rebuild-image.'
    stamp = Path('build/BUILD.TXT').read_bytes()
    actual = bytes(disks[0]['BUILD.TXT'][1])
    assert actual == stamp + bytes((-len(stamp)) % 252), 'Build stamp differs: stale image?'
    acceptance_files = [(name, Path('build', name).read_bytes()) for name in
                        ('CZECH.DAT', 'VMBOOT.DAT', 'VMFAIL.DAT', 'VMLIMIT.DAT')]
    for name, expected in story_files() + acceptance_files:
        actual = bytes(disks[file_drive(name)][name][1])
        assert actual == expected + bytes((-len(expected)) % 252), f'Story differs: {name}'
    print(f'{path}: both SRAM drives, imported files, load records, and boot link verified.')


if __name__ == '__main__':
    for path in sys.argv[1:] or ['build/flex2.dsk']:
        verify(path)
