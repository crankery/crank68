#!/usr/bin/env python3
"""Extract glyph bytes in source ROM order, without remapping or scaling."""
import argparse
from pathlib import Path

from decode_al_font import decode


def extract(kind, source):
    data = Path(source).read_bytes()
    if kind == "alto":
        height, _, width, _, glyphs = decode(source)
        if (height, width, len(glyphs)) != (12, 8, 256):
            raise ValueError("Unexpected Alto font dimensions")
        return bytes(sum(0x80 >> x for x, bit in enumerate(row[:8]) if bit == "#")
                     for glyph in glyphs for row in glyph)

    if kind == "osborne":
        if len(data) != 2048:
            raise ValueError(f"Unexpected Osborne ROM size: {len(data)}")
        # Each 128-byte page contains one scanline of every glyph.
        return bytes(data[row * 128 + code] for code in range(128) for row in range(10))

    sizes = {"vt100": 2048, "pet-graphics": 2048, "pet-business": 2048,
             "spectrum": 16384, "atari": 10240, "ega": 16384}
    if len(data) != sizes[kind]:
        raise ValueError(f"Unexpected {kind} ROM size: {len(data)}")
    start, length = {
        "vt100": (0, 2048),
        "pet-graphics": (0, 1024),
        "pet-business": (1024, 1024),
        "spectrum": (0x3D00, 768),
        "atari": (0x800, 1024),
        "ega": (8752, 3584),
    }[kind]
    return data[start:start + length]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=("vt100", "pet-graphics", "pet-business",
                                         "spectrum", "atari", "ega", "alto", "osborne"))
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    data = extract(args.kind, args.source)
    args.output.write_bytes(data)
    print(f"{args.output}: {len(data)} bytes")


if __name__ == "__main__":
    main()
