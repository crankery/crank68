#!/usr/bin/env python3
"""Convert the PicoDVI repository's row-major ASCII font to VERA tiles."""
from pathlib import Path
import re


def main():
    source = Path(__file__).resolve().parents[1] / 'terminal/picodvi/software/assets/font_8x8.h'
    body = source.read_text().split('{', 1)[1].split('}', 1)[0]
    rows = bytes(int(value, 16) for value in re.findall(r'0x([0-9a-fA-F]{2})', body))
    assert len(rows) == 95 * 8, f'Unexpected source font size: {len(rows)}'
    tiles = bytearray(256 * 8)
    for char in range(32, 127):
        for row in range(8):
            tiles[char * 8 + row] = rows[row * 95 + char - 32]
    Path(__file__).with_name('font.bin').write_bytes(tiles)


if __name__ == '__main__':
    main()
