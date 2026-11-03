#!/usr/bin/env python3
"""Seed emulator SRAM and SD working copies once; preserve saved changes."""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--drive-layout', choices=('sram-first', 'sd-first'), default='sram-first')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]


def seed(factory, session):
    factory_data = factory.read_bytes()
    if len(factory_data) != 1048576:
        raise ValueError(f'Packaged image is not 1 MiB: {factory}')
    try:
        with session.open('xb') as target:
            target.write(factory_data)
        print(f'Created {session.relative_to(root)} from the packaged image')
    except FileExistsError:
        if session.stat().st_size != 1048576:
            raise ValueError(f'Existing image is not 1 MiB: {session}')
        print(f'Using existing {session.relative_to(root)}; saved files are preserved')


ram_session = 'session.dsk' if args.drive_layout == 'sram-first' else 'session-sram-sd-first.dsk'
seed(root / 'build/system/flex2.dsk', root / 'build' / ram_session)
seed(root / 'build/system/FLEX.DSK', root / f'build/session-sd-{args.drive_layout}.dsk')
