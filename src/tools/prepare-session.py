#!/usr/bin/env python3
"""Seed an emulator SRAM working copy once; never replace its saved changes."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
factory = root / 'build/system/flex2.dsk'
session = root / 'build/session.dsk'
factory_data = factory.read_bytes()
if len(factory_data) != 1048576:
    raise ValueError('Packaged SRAM image is not 1 MiB')
try:
    with session.open('xb') as target:
        target.write(factory_data)
    print('Created build/session.dsk from the packaged SRAM image')
except FileExistsError:
    if session.stat().st_size != 1048576:
        raise ValueError('Existing build/session.dsk is not a 1 MiB SRAM image')
    print('Using existing build/session.dsk; saved files are preserved')
