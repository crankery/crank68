#!/usr/bin/env python3
"""Make an 8-row Osborne face from its 128-glyph, 10-row extract."""

import argparse
from pathlib import Path


def squeeze(source):
    if len(source) != 128 * 10:
        raise ValueError("Expected 128 Osborne glyphs of 10 rows")

    output = bytearray()
    for code in range(128):
        glyph = source[code * 10:(code + 1) * 10]
        if code < 0x20 or code == 0x7F:
            # Keep both edges while reducing the full-height control graphics.
            rows = (0, 1, 2, 3, 5, 6, 8, 9)
            output.extend(glyph[row] for row in rows)
        elif glyph[9] and not glyph[1]:
            # Descenders occupy rows 2–9; the first two rows are empty.
            output.extend(glyph[2:10])
        else:
            # Most printable glyphs occupy rows 1–8. Q is patched separately
            # to retain its ninth occupied row and its descending tail.
            output.extend(glyph[1:9])
    return bytes(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.write_bytes(squeeze(args.source.read_bytes()))


if __name__ == "__main__":
    main()
