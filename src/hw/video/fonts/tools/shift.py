#!/usr/bin/env python3
"""Shift glyph rows downward, optionally extending a nonblank top edge."""
import argparse
from pathlib import Path


def shift_down(data, height, rows, repeat_top=False):
    if height <= 0 or not 0 <= rows < height or len(data) % height:
        raise ValueError("Invalid glyph height, shift, or font size")
    output = bytearray()
    for start in range(0, len(data), height):
        glyph = data[start:start + height]
        output.extend(bytes([glyph[0] if repeat_top else 0]) * rows)
        output.extend(glyph[:height - rows])
    return bytes(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--repeat-top", action="store_true")
    args = parser.parse_args()
    shifted = shift_down(args.source.read_bytes(), args.height, args.rows, args.repeat_top)
    args.output.write_bytes(shifted)
    print(f"Wrote {args.output}: {len(shifted) // args.height} glyphs, shifted {args.rows} rows")


if __name__ == "__main__":
    main()
