
#!/usr/bin/env python3
"""Expand an 8-pixel-wide font into one 256-glyph, 8x16 EEPROM bank."""
import argparse
from pathlib import Path

def make_bank(source, height):
    if height not in (8, 10, 12, 14, 16) or len(source) not in (128 * height, 256 * height):
        raise ValueError("Expected 128 or 256 glyphs of height 8, 10, 12, 14, or 16")
    count = len(source) // height
    bank = bytearray(4096)
    top = (16 - height) // 2
    for code in range(count):
        glyph = source[code * height:(code + 1) * height]
        rows = bytes(row for pixel in glyph for row in ((pixel, pixel) if height == 8 else (pixel,)))
        offset = code * 16 + (0 if height == 8 else top)
        bank[offset:offset + len(rows)] = rows
    if count == 128:
        for code in range(128):
            bank[(code + 128) * 16:(code + 129) * 16] = bytes(
                pixel ^ 0xFF for pixel in bank[code * 16:(code + 1) * 16])
    return bytes(bank)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("output")
    ap.add_argument("--height", type=int, choices=(8, 10, 12, 14, 16), required=True)
    args = ap.parse_args()

    bank = make_bank(Path(args.source).read_bytes(), args.height)
    Path(args.output).write_bytes(bank)
    print(f"{args.output}: {len(bank)} bytes")

if __name__ == "__main__":
    main()
