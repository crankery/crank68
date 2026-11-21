
#!/usr/bin/env python3
"""Convert a 2 KB PET 901447-08 character ROM into two ASCII-mapped fonts."""

import argparse
from pathlib import Path

GLYPH_SIZE = 8

def convert(source, base):
    # Source PET screen codes to ASCII positions.
    # PET screen codes 0x00-0x1F correspond to ASCII 0x40-0x5F.
    # PET screen codes 0x20-0x3F correspond to ASCII 0x20-0x3F.
    # PET screen codes 0x40-0x5F correspond to ASCII 0x60-0x7F.
    # PET screen codes 0x60-0x7F provide extra graphics.
    output = bytearray(128 * GLYPH_SIZE)

    def copy(dst, src):
        output[dst*8:dst*8+8] = source[src*8:src*8+8]

    for code in range(0x20, 0x40):
        copy(code, base + code)

    for code in range(0x40, 0x60):
        copy(code, base + code - 0x40)

    for code in range(0x60, 0x80):
        copy(code, base + code - 0x20)

    # Preserve some PET graphics in the unused ASCII control positions.
    for code in range(0x20):
        copy(code, base + 0x60 + code)

    return output

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("rom", type=Path)
    args = parser.parse_args()

    data = args.rom.read_bytes()
    if len(data) != 2048:
        parser.error("Expected a 2048-byte PET character ROM")

    graphics = convert(data, 0x00)
    business = convert(data, 0x80)

    for name, font in (
        ("pet-graphics.bin", graphics),
        ("pet-business.bin", business),
    ):
        Path(name).write_bytes(font)
        print(f"Wrote {name}: {len(font)} bytes")

if __name__ == "__main__":
    main()
