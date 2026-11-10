
#!/usr/bin/env python3
"""Render a 40-column text sample and glyph contact sheet as a PNG."""

import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

SAMPLE_LINES = (
    "The quick brown fox jumps over the lazy",
    "dog. 0123456789 !?.,:; +-*/= {}[] `~@#$%",
    "Lorem ipsum dolor sit amet, consectetur",
    "adipiscing elit. ABCDEFGHIJKLMNOPQRST",
    "UVWXYZ abcdefghijklmnopqrstuvwxyz",
)


def draw_glyph(draw, data, index, height, x, y, scale):
    if index >= len(data) // height:
        return
    offset = index * height
    for row in range(height):
        bits = data[offset + row]
        for col in range(8):
            if bits & (0x80 >> col):
                px = x + col * scale
                py = y + row * scale
                draw.rectangle((px, py, px + scale - 1, py + scale - 1),
                               fill="#80FF80")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("rom", type=Path)
    parser.add_argument("--height", type=int, default=16,
                        help="Bytes per glyph (default: 16)")
    parser.add_argument("--scale", type=int, default=4)
    parser.add_argument("--output", "-o", type=Path)
    args = parser.parse_args()
    if args.height <= 0 or args.scale <= 0:
        parser.error("Height and scale must be positive")

    data = args.rom.read_bytes()
    if len(data) % args.height:
        parser.error("ROM size is not divisible by glyph height")

    count = len(data) // args.height
    columns = 16
    rows = (count + columns - 1) // columns

    cell_w = 64
    cell_h = args.height * args.scale + 22
    sample_scale = min(args.scale, 3)
    sample_banks = count // 256 if count > 256 and count % 256 == 0 else 1
    sample_h = 44 + len(SAMPLE_LINES) * args.height * sample_scale
    sheet_top = sample_banks * sample_h
    image = Image.new("RGB",
                      (max(columns * cell_w, 40 * 8 * sample_scale + 32),
                       sheet_top + rows * cell_h),
                      "#202020")
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()

    for bank in range(sample_banks):
        block_y = bank * sample_h
        draw.rectangle((8, block_y + 4, image.width - 8, block_y + sample_h - 4),
                       outline="#555555")
        heading = "40-COLUMN SAMPLE" + (f"  |  BANK {bank}" if sample_banks > 1 else "")
        draw.text((16, block_y + 12), heading, fill="#AAAAAA", font=font)
        for line_no, line in enumerate(SAMPLE_LINES):
            y = block_y + 32 + line_no * args.height * sample_scale
            for column, character in enumerate(line):
                draw_glyph(draw, data, bank * 256 + ord(character), args.height,
                           16 + column * 8 * sample_scale, y, sample_scale)

    for index in range(count):
        x = (index % columns) * cell_w
        y = sheet_top + (index // columns) * cell_h

        draw.text((x + 4, y + 2), f"{index:02X}",
                  fill="#888888", font=font)

        # Keep the outline two pixels away from the glyph so it reads as a
        # cell boundary rather than another stroke of the character.
        draw.rectangle((x + 14, y + 16,
                        x + 16 + 8 * args.scale + 1,
                        y + 18 + args.height * args.scale + 1),
                       outline="#555555")
        draw_glyph(draw, data, index, args.height,
                   x + 16, y + 18, args.scale)

    output = args.output or args.rom.with_suffix(".png")
    image.save(output)
    print(f"{count} glyphs, 8x{args.height}")
    print(f"Wrote {output}")

if __name__ == "__main__":
    main()
