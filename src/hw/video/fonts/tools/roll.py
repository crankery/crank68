#!/usr/bin/env python3
"""Rotate the scanlines of every glyph independently."""
import argparse
from pathlib import Path


def roll(data, height, rows):
    if height <= 0 or len(data) % height:
        raise ValueError("Font size must be divisible by a positive glyph height")
    rows %= height
    return b"".join(glyph[-rows:] + glyph[:-rows] if rows else glyph
                    for start in range(0, len(data), height)
                    for glyph in (data[start:start + height],))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    args = parser.parse_args()
    data = roll(args.source.read_bytes(), args.height, args.rows)
    args.output.write_bytes(data)
    print(f"Wrote {args.output}: {len(data) // args.height} glyphs, rolled {args.rows} rows")


if __name__ == "__main__":
    main()
