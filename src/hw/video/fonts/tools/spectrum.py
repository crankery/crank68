
#!/usr/bin/env python3
"""Extract Spectrum 48K font, ASCII-align, add 16 quadrant glyphs."""
import argparse
from pathlib import Path

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rom")
    ap.add_argument("output")
    args = ap.parse_args()

    rom = Path(args.rom).read_bytes()
    if len(rom) < 0x4000:
        raise ValueError("Expected a 16 KB Spectrum ROM")

    font = bytearray(128 * 8)

    # Spectrum glyphs represent ASCII 0x20 through 0x7F.
    font[0x20 * 8:] = rom[0x3D00:0x4000]

    # Sixteen 2x2 quadrant graphics in slots 0x00-0x0F.
    # Pattern bits: TL=0, TR=1, BL=2, BR=3.
    for pattern in range(16):
        for y in range(8):
            bits = pattern >> (2 if y >= 4 else 0)
            font[pattern * 8 + y] = (
                (0xF0 if bits & 1 else 0) |
                (0x0F if bits & 2 else 0)
            )

    Path(args.output).write_bytes(font)
    print(f"{args.output}: 128 glyphs, 8 scanlines each")

if __name__ == "__main__":
    main()
