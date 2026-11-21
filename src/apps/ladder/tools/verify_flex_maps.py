#!/usr/bin/env python3
"""Check generated FLEX map terrain against captured original tile tables."""

from pathlib import Path
import re

from compare_ladder_maps import BOARDS, ROOT, TILE, original_tiles


def decoded_map(path: Path) -> list[str]:
    cells = []
    for line in path.read_text().splitlines():
        if match := re.fullmatch(r'\s*\.ascii "(.*)"', line):
            cells.extend(match.group(1))
        elif match := re.fullmatch(r'\s*\.byte (34|92)', line):
            cells.append(chr(int(match.group(1))))
    if len(cells) != 79 * 20:
        raise ValueError(f'{path}: expected 1580 cells, got {len(cells)}')
    return [''.join(cells[y * 79:(y + 1) * 79]) for y in range(20)]


def main() -> None:
    for name, level, filename in BOARDS:
        slug = re.sub(r'[^a-z0-9]+', '_', name.lower()).strip('_')
        rows = decoded_map(ROOT / 'flex' / f'{slug}.inc')
        original = original_tiles(filename, level)
        differences = [(x, y, char, original[x, y])
                       for y, row in enumerate(rows, 1)
                       for x, char in enumerate(row, 1)
                       if TILE.get(char, 0) != original[x, y]]
        if differences:
            raise AssertionError(f'{name}: {differences[:5]}')
        print(f'{name}: 1580 terrain cells match')


if __name__ == '__main__':
    main()
