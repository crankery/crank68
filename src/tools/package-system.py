#!/usr/bin/env python3
"""Collect matching build outputs without touching emulator or SD work images."""
import argparse
import hashlib
import importlib.util
import os
from pathlib import Path
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'build' / 'system'


def write_atomic(path, data, executable=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, prefix='.package-', delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
            os.chmod(temporary, 0o755 if executable else 0o644)
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sd-volume', type=int, choices=(0, 1), default=1)
    parser.add_argument('--drive-layout', choices=('sram-first', 'sd-first'), default='sram-first')
    args = parser.parse_args()

    spec = importlib.util.spec_from_file_location('extract_image', ROOT / 'sd/tools/extract_image.py')
    image_tool = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(image_tool)

    sources = {
        'mikbug2.rom': ROOT / 'roms/mikbug2/mikbug2.rom',
        'flex2.dsk': ROOT / 'flex2/build/flex2.dsk',
        'sd_bridge.hex': ROOT / 'sd/build/sd_bridge.ino.hex',
        'avr-fuses.conf': ROOT / 'sd/fuses.conf',
        'emu': ROOT / 'emu/build/bin/emu',
    }
    for source in sorted((ROOT / 'pld').glob('*.gal')):
        for suffix in ('.jed', '.fus', '.pin'):
            name = source.stem + suffix
            sources[f'pld/{name}'] = ROOT / 'build/pld' / name
    payloads = {name: path.read_bytes() for name, path in sources.items()}
    payloads['FLEX.DSK'] = image_tool.expand(
        image_tool.extract(sources['flex2.dsk'], args.sd_volume))

    if len(payloads['mikbug2.rom']) != 8192:
        raise ValueError('MIKBUG ROM must be 8 KiB')
    if len(payloads['flex2.dsk']) != 1048576 or len(payloads['FLEX.DSK']) != 1048576:
        raise ValueError('SRAM and SD images must each be 1 MiB')
    if not payloads['sd_bridge.hex'].startswith(b':'):
        raise ValueError('AVR hex file is missing Intel HEX records')

    lines = [f'FLEX drive layout: {args.drive_layout}',
             f'SD volume seeded from SRAM drive {args.sd_volume}',
             'Each SHA-256 covers the exact packaged file.']
    for name, data in payloads.items():
        write_atomic(OUTPUT / name, data, executable=name == 'emu')
        digest = hashlib.sha256(data).hexdigest()
        lines.append(f'{digest}  {len(data):>8}  {name}')
    write_atomic(OUTPUT / 'MANIFEST.txt', ('\n'.join(lines) + '\n').encode())
    print(f'Packaged ROM, SRAM, SD, AVR, GALs and emulator in {OUTPUT.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
