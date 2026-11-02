#!/usr/bin/env python3
"""Read the historical 35-track, 10-sector FLEX distribution disks."""
from pathlib import Path

SOURCES = [Path('6800Flex') / name for name in
           ('6800FLEX.DSK', '6800UTL1.DSK', '6800UTL2.DSK',
            'GAMES_5.DSK', 'MYGAMES.DSK', 'XBASIC_1.DSK')]
# These programs depend on the original floppy/boot or printer hardware.
EXCLUDED = {'LINK.CMD', 'NEWDISK.CMD', 'PRINT.CMD'}


def read_distribution(source):
    image = source.read_bytes()
    if len(image) != 35 * 10 * 256:
        raise ValueError('Unexpected distribution disk geometry')
    used = set()

    def chain(link):
        blocks = []
        while link != b'\0\0':
            track, sector = link
            if not (0 <= track < 35 and 1 <= sector <= 10):
                raise ValueError(f'Invalid source link {list(link)}')
            index = track * 10 + sector - 1
            if index in used:
                raise ValueError(f'Reused source sector {list(link)}')
            used.add(index)
            block = image[index * 256:(index + 1) * 256]
            blocks.append(block)
            link = block[:2]
        return blocks

    files = []
    for block in chain(bytes([0, 5])):
        for offset in range(16, 256, 24):
            entry = block[offset:offset + 24]
            if entry[0] in (0, 255):
                continue
            name = (entry[:8].rstrip(b'\0').decode('ascii') + '.' +
                    entry[8:11].rstrip(b'\0').decode('ascii'))
            if source in SOURCES[3:] and name.endswith('.BAS'):
                pass
            elif name != 'ERRORS.SYS' and (not name.endswith('.CMD') or (source == SOURCES[0] and name in EXCLUDED)):
                continue
            blocks = chain(entry[13:15])
            if len(blocks) != int.from_bytes(entry[17:19], 'big'):
                raise ValueError(f'Wrong source sector count for {name}')
            files.append((name, b''.join(block[4:] for block in blocks)))
    return files


def distribution_files():
    # Disk order gives the existing system utilities precedence (DATE.CMD).
    files = {}
    for source in SOURCES:
        for name, payload in read_distribution(source):
            if name == 'CAT.CMD' and name not in files:
                # CAT converts an ASCII drive digit with AND #3, aliasing 4 to 0.
                # SUBA #'0' preserves out-of-range digits for driver validation.
                old = bytes.fromhex('bdad278403cea840a703')
                new = bytes.fromhex('bdad278030cea840a703')
                if payload.count(old) != 1:
                    raise ValueError('Unexpected CAT drive argument code')
                payload = payload.replace(old, new)
            files.setdefault(name, payload)
    return list(files.items())
