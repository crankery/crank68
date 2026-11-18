#!/usr/bin/env python3
"""Reconstruct 80x24 frames from iz-cpm's ADM-3A-to-ANSI output."""
import argparse
import gzip
import re
import struct
import zlib
from pathlib import Path

CSI = re.compile(rb"\x1b\[([0-9;?]*)([A-Za-z])")


def replay(data, width=80, height=24, every=500):
    screen = [[" "] * width for _ in range(height)]
    row = col = 0
    frames = []
    moves = 0
    clear_count = 0

    def snap(offset, label):
        frames.append((offset, label, tuple("".join(line) for line in screen)))

    pos = 0
    while pos < len(data):
        ch = data[pos]
        if ch == 27:
            m = CSI.match(data, pos)
            if not m:
                raise ValueError(f"unknown escape at byte {pos}")
            args = [int(v) if v else 0 for v in m.group(1).split(b";")]
            cmd = m.group(2)
            if cmd == b"H":
                row = min(max((args[0] or 1) - 1, 0), height - 1)
                col = min(max(((args[1] if len(args)>1 else 1) or 1) - 1, 0), width - 1)
                moves += 1
                if moves % every == 0:
                    snap(pos, f"move-{moves}")
            elif cmd == b"J":
                if args == [2]:
                    snap(pos, f"before-clear-{clear_count}")
                    screen = [[" "] * width for _ in range(height)]
                    clear_count += 1
                    row = col = 0
                elif args == [0]:
                    for y in range(row, height):
                        begin = col if y == row else 0
                        screen[y][begin:] = [" "] * (width - begin)
            else:
                raise ValueError(f"unsupported CSI {cmd!r} at byte {pos}")
            pos = m.end()
            continue
        if ch == 13:
            col = 0
        elif ch == 10:
            row += 1
            if row >= height:
                screen.pop(0)
                screen.append([" "] * width)
                row = height - 1
        elif ch == 7:
            pass
        elif 32 <= ch <= 126:
            screen[row][col] = chr(ch)
            col += 1
            if col >= width:
                col = width - 1
        else:
            raise ValueError(f"unexpected byte {ch} at {pos}")
        pos += 1
    snap(len(data), "final")
    return frames


def write_png(path, screen, font, scale=2):
    """Draw the captured characters using the C68 project's EGA 8x8 ROM."""
    width, height = 80 * 8 * scale, 24 * 8 * scale
    foreground, background = (158, 224, 171), (12, 22, 20)
    raw = bytearray()
    for y in range(24):
        for gy in range(8):
            line = bytearray()
            for char in screen[y]:
                bits = font[ord(char) * 8 + gy]
                for gx in range(8):
                    color = foreground if bits & (0x80 >> gx) else background
                    line.extend(bytes(color) * scale)
            for _ in range(scale):
                raw.append(0)
                raw.extend(line)

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def main():
    p = argparse.ArgumentParser()
    p.add_argument("input", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--every", type=int, default=500)
    p.add_argument("--font", type=Path, help="256 glyph by 8 row bitmap font")
    p.add_argument("--select", help="comma-separated frame labels to export")
    args = p.parse_args()
    data = gzip.open(args.input, "rb").read() if args.input.suffix == ".gz" else args.input.read_bytes()
    frames = replay(data, every=args.every)
    args.output.mkdir(parents=True, exist_ok=True)
    selected = set(args.select.split(",")) if args.select else None
    font = args.font.read_bytes() if args.font else None
    if font is not None and len(font) == 16384:
        font = font[0x3160:0x3960]  # IBM EGA 8x8 face in the source ROM.
    if font is not None and len(font) != 2048:
        raise ValueError("font must contain 256 8x8 glyphs")
    exported = []
    for n, (offset, label, screen) in enumerate(frames):
        if selected is None or label in selected:
            stem = args.output / f"{n:03d}-{label}"
            stem.with_suffix(".txt").write_text("\n".join(line.rstrip() for line in screen) + "\n")
            if font is not None:
                write_png(stem.with_suffix(".png"), screen, font)
            exported.append((n, offset, label, screen))
    print(f"{len(frames)} frames found, {len(exported)} exported from {len(data)} bytes")
    for n, offset, label, screen in exported:
        print(f"{n:03d} byte {offset:6d} {label:20s} | {screen[18].strip()[:70]}")


if __name__ == "__main__":
    main()
