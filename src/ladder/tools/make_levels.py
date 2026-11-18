#!/usr/bin/env python3
"""Extract the seven 79x20 Ladder maps from the Turbo Pascal rewrite."""

from argparse import ArgumentParser
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent

parser = ArgumentParser(description=__doc__)
parser.add_argument('--source', type=Path,
                    default=ROOT / 'Ladder/src/ladicons.pas')
parser.add_argument('--output-dir', type=Path, default=ROOT / 'flex')
args = parser.parse_args()

text = args.source.read_text()
levels = text.split('levels : ARRAY', 1)[1].split('jumpPaths', 1)[0]
header = re.compile(
    r"Name\s*:\s*'([^']+)';\s*InitialBonusTime\s*:\s*(\d+);"
    r"\s*Rocks\s*:\s*(\d+);\s*Layout\s*:\s*\(", re.IGNORECASE)
matches = list(header.finditer(levels))
assert len(matches) == 7, f'expected seven levels, found {len(matches)}'

for index, match in enumerate(matches):
    name, bonus, rocks = match.groups()
    end = matches[index + 1].start() if index + 1 < len(matches) else len(levels)
    rows = re.findall(r"'((?:''|[^'])*)'", levels[match.end():end])
    rows = [row.replace("''", "'") for row in rows]
    assert len(rows) == 20, f'{name}: expected 20 rows, found {len(rows)}'
    assert all(len(row) == 79 for row in rows), f'{name}: wrong row width'
    assert sum(row.count('p') for row in rows) == 1, f'{name}: expected one Lad start'
    assert all(all(32 <= ord(char) <= 126 for char in row)
               for row in rows), f'{name}: non-printable map character'
    slug = re.sub(r'[^a-z0-9]+', '_', name.lower()).strip('_')
    output = args.output_dir / f'{slug}.inc'
    directives = []
    for row in rows:
        # Emit punctuation outside quoted strings so vasm cannot interpret
        # a map backslash as an assembler escape sequence.
        for chunk in re.split(r'([\\"])', row):
            if chunk == '\\':
                directives.append('        .byte 92')
            elif chunk == '"':
                directives.append('        .byte 34')
            elif chunk:
                directives.append(f'        .ascii "{chunk}"')
    output.write_text(
        f'; Generated from Ladder/src/ladicons.pas by tools/make_levels.py\n'
        f'; {name}: initial bonus {bonus}, rocks {rocks}\n'
        + '\n'.join(directives) + '\n')
    print(f'{output.name}: 20 x 79')
