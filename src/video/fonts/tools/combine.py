#!/usr/bin/env python3
"""Combine two 128-glyph 8x8 fonts into one 256-glyph font."""
import argparse
from pathlib import Path


def combine(lower, upper):
    if len(lower) != 1024 or len(upper) != 1024:
        raise ValueError("Expected two 128-glyph 8x8 fonts")
    return lower + upper


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lower", type=Path)
    parser.add_argument("upper", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.write_bytes(combine(args.lower.read_bytes(), args.upper.read_bytes()))
    print(f"Wrote {args.output}: 256 glyphs")


if __name__ == "__main__":
    main()
