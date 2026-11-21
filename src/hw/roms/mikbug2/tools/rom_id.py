#!/usr/bin/env python3
"""Generate the ASCII chip ID stored in the ROM's I/O-shadowed first page."""
import argparse
from datetime import datetime, timezone
import os
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--version', required=True)
parser.add_argument('--sound-rev', required=True, choices=('1', '2'))
args = parser.parse_args()
if not re.fullmatch(r'[A-Za-z0-9._-]{1,16}', args.version):
    parser.error('ROM version must be 1-16 ASCII letters, digits, dots, underscores or hyphens')

stamp = os.environ.get('SOURCE_DATE_EPOCH')
when = datetime.fromtimestamp(int(stamp), timezone.utc) if stamp is not None else datetime.now(timezone.utc)
fields = (
    'CRANK68 MIKBUG2',
    f'ROM VERSION {args.version}',
    f'BUILT {when:%Y-%m-%d %H:%M} UTC',
    'SD ABI 3',
    f'SOUND REV {args.sound_rev}',
)
if sum(len(field) + 1 for field in fields) > 0x100:
    parser.error('ROM ID exceeds the $E000-$E0FF shadow area')
source = '; Physical ROM bytes at $E000; CPU reads in this range select I/O.\n'
source += ''.join(f'    .byte "{field}",0\n' for field in fields)
args.output.parent.mkdir(parents=True, exist_ok=True)
if not args.output.exists() or args.output.read_text() != source:
    args.output.write_text(source)
