#!/usr/bin/env python3
"""Concatenate 8 or 16 equal-sized font banks into a 32 KB EEPROM image."""
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("banks", type=Path, nargs="+")
    parser.add_argument("--row-address-xor", type=int, default=0,
                        help="XOR mask between logical scanline and ROM row address")
    parser.add_argument("--glyph-height", type=int, default=8)
    args = parser.parse_args()
    if len(args.banks) not in (8, 16):
        parser.error("Expected 8 or 16 font banks")
    bank_size = 32768 // len(args.banks)
    if args.glyph_height <= 0 or bank_size % args.glyph_height:
        parser.error("Glyph height must divide the bank size")
    if args.row_address_xor < 0 or any(
            row ^ args.row_address_xor >= args.glyph_height
            for row in range(args.glyph_height)):
        parser.error("Row address XOR maps outside the glyph")
    banks = [path.read_bytes() for path in args.banks]
    for path, bank in zip(args.banks, banks):
        if len(bank) != bank_size:
            parser.error(f"{path}: expected {bank_size} bytes, got {len(bank)}")
    def address_rows(bank):
        height = args.glyph_height
        mask = args.row_address_xor
        return bytes(bank[start + (physical_row ^ mask)]
                     for start in range(0, len(bank), height)
                     for physical_row in range(height))

    args.output.write_bytes(b"".join(address_rows(bank) for bank in banks))
    print(f"Wrote {args.output}: 32768 bytes")


if __name__ == "__main__":
    main()
