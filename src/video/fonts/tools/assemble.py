#!/usr/bin/env python3
"""Concatenate eight 4 KB font banks into a 32 KB EEPROM image."""
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("banks", type=Path, nargs=8)
    args = parser.parse_args()
    banks = [path.read_bytes() for path in args.banks]
    for path, bank in zip(args.banks, banks):
        if len(bank) != 4096:
            parser.error(f"{path}: expected 4096 bytes, got {len(bank)}")
    args.output.write_bytes(b"".join(banks))
    print(f"Wrote {args.output}: 32768 bytes")


if __name__ == "__main__":
    main()
