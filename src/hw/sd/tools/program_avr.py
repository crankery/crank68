#!/usr/bin/env python3
"""Program a socketed ATmega328P-PU using the Homebrew Minipro CLI."""
import argparse
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DEVICE = 'ATMEGA328P@DIP28'


def commands(hex_file, fuses, icsp=False):
    base = ['minipro', '-p', DEVICE]
    if icsp:
        base.append('-i')
    return [
        base + ['-c', 'code', '-f', 'ihex', '-w', str(hex_file)],
        base + ['-c', 'config', '-w', str(fuses), '-e'],
        base + ['-c', 'code', '-f', 'ihex', '-m', str(hex_file)],
        base + ['-c', 'config', '-m', str(fuses)],
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('hex_file', type=Path, help='compiled application HEX, without bootloader')
    parser.add_argument('--fuses', type=Path, default=ROOT / 'fuses.conf')
    parser.add_argument('--dry-run', action='store_true', help='print commands; do not contact programmer')
    parser.add_argument('--icsp', action='store_true', help='use the six-pin ISP header in circuit')
    args = parser.parse_args()
    hex_file = args.hex_file.resolve()
    fuses = args.fuses.resolve()
    if not hex_file.is_file() or not hex_file.read_bytes().startswith(b':'):
        parser.error('Expected an existing Intel HEX firmware file')
    if not fuses.is_file():
        parser.error('Fuse configuration file is missing')
    if not shutil.which('minipro'):
        parser.error('minipro is not on PATH')
    for command in commands(hex_file, fuses, args.icsp):
        print(' '.join(command), flush=True)
        if not args.dry_run:
            subprocess.run(command, check=True)


if __name__ == '__main__':
    main()
