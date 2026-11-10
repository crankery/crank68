#!/usr/bin/env python3
"""Check image layout and transformations against source and intermediate files."""
import argparse
from pathlib import Path

from bank import make_bank
from combine import combine
from extract import extract
from fontedit import parse_patch
from osborne8 import squeeze
from remap import remap
from roll import roll
from shift import shift_down


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--row-address-xor", type=int, default=0)
    parser.add_argument("image", type=Path)
    parser.add_argument("banks", type=Path, nargs="+")
    args = parser.parse_args()
    image = args.image.read_bytes()
    paths = args.banks
    assert len(paths) == 16 and len(image) == 32768
    assert 0 <= args.row_address_xor < 8
    for number, path in enumerate(paths):
        bank = path.read_bytes()
        assert len(bank) == 2048
        physical = bytes(bank[glyph * 8 + (row ^ args.row_address_xor)]
                         for glyph in range(256) for row in range(8))
        assert image[number * 2048:(number + 1) * 2048] == physical, path

    for name, source in (
        ("vt100", "vt100-23-018E2.bin"),
        ("pet-graphics", "cbm-pet.901447-08.bin"),
        ("pet-business", "cbm-pet.901447-08.bin"),
        ("spectrum", "sinclair-spectrum-48.rom"),
        ("atari", "ATARIOSB.ROM"),
        ("ega", "IBM-EGA.bin"),
        ("ega-8x8", "IBM-EGA.bin"),
        ("alto", "SysFont.Al."),
        ("osborne", "OCC1_char.BIN"),
    ):
        assert Path(f"build/extract/{name}.bin").read_bytes() == extract(name, Path("resources") / source), name
    for name in ("pet-graphics", "pet-business", "spectrum", "alto"):
        assert Path(f"build/mapped/{name}.bin").read_bytes() == remap(
            name, Path(f"build/extract/{name}.bin").read_bytes()), name
    osborne_rom = Path("resources/OCC1_char.BIN").read_bytes()
    osborne = Path("build/extract/osborne.bin").read_bytes()
    assert len(osborne) == 128 * 10
    assert osborne[0x41 * 10:0x42 * 10] == bytes(osborne_rom[row * 128 + 0x41] for row in range(10))
    assert Path("build/mapped/osborne.bin").read_bytes() == osborne
    osborne_base = squeeze(osborne)
    assert Path("build/base/osborne-8x8.bin").read_bytes() == osborne_base
    osborne_expected = bytearray(osborne_base)
    for operation, code, value in parse_patch("patches/osborne-8x8.fontedit", 8):
        glyph = osborne_base[value * 8:(value + 1) * 8] if operation == "copy" else value
        osborne_expected[code * 8:(code + 1) * 8] = glyph
    osborne_8x8 = Path("build/mapped/osborne-8x8.bin").read_bytes()
    assert osborne_8x8 == osborne_expected
    assert osborne_8x8[0x51 * 8:0x52 * 8] == bytes.fromhex("78 cc cc cc ec 78 18 0c")
    first_lit_row = lambda ch: next(i for i, row in enumerate(
        osborne_8x8[ord(ch) * 8:(ord(ch) + 1) * 8]) if row)
    assert all(first_lit_row(ch) == first_lit_row("a") for ch in "gpqy")
    assert osborne_8x8[ord("i") * 8:(ord("i") + 1) * 8] == bytes.fromhex(
        "30 00 30 30 30 30 78 00")
    assert osborne_8x8[ord("j") * 8:(ord("j") + 1) * 8] == bytes.fromhex(
        "18 00 18 18 18 18 d8 70")
    assert all(first_lit_row(ch) == first_lit_row("k") for ch in "ijl")
    assert all(osborne_8x8[ord(ch) * 8 + 2] for ch in "ij")
    assert all(osborne_8x8[(ord(ch) + 1) * 8 - 1] for ch in "gjpqy")
    ega_rom = Path("resources/IBM-EGA.bin").read_bytes()
    ega_8x8 = Path("build/extract/ega-8x8.bin").read_bytes()
    assert ega_8x8 == ega_rom[0x3160:0x3960]
    assert Path("build/mapped/ega-8x8.bin").read_bytes() == ega_8x8
    atari_base = remap("atari", Path("build/extract/atari.bin").read_bytes())
    assert Path("build/base/atari.bin").read_bytes() == atari_base
    atari_expected = bytearray(atari_base)
    for operation, code, value in parse_patch("patches/atari.fontedit", 8):
        glyph = atari_base[value * 8:(value + 1) * 8] if operation == "copy" else value
        atari_expected[code * 8:(code + 1) * 8] = glyph
    atari = Path("build/mapped/atari.bin").read_bytes()
    assert atari == atari_expected
    for destination, source in ((0x00, 0x7E), (0x10, 0x7F), (0x1B, 0x7D), (0x7F, 0x1B)):
        assert atari[destination * 8:(destination + 1) * 8] == atari_base[source * 8:(source + 1) * 8]
    for code in (0x60, 0x7B, 0x7D, 0x7E):
        assert atari[code * 8:(code + 1) * 8] != atari_base[code * 8:(code + 1) * 8]
    rolled = roll(Path("build/extract/vt100.bin").read_bytes(), 16, 2)
    vt100_base = Path("build/base/vt100.bin").read_bytes()
    patches = parse_patch("patches/vt100.fontedit", 16)
    assert {0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
            0x15, 0x16, 0x17, 0x18, 0x19} <= {dest for _, dest, _ in patches}
    expected = bytearray(rolled)
    for operation, code, value in patches:
        glyph = rolled[value * 16:(value + 1) * 16] if operation == "copy" else value
        expected[code * 16:(code + 1) * 16] = glyph
    assert vt100_base == expected
    vt100 = Path("build/mapped/vt100.bin").read_bytes()
    assert vt100 == shift_down(vt100_base, 16, 2, repeat_top=True)
    for code in (0x0B, 0x0E, 0x0F, 0x15, 0x16, 0x17, 0x19):
        assert vt100[code * 16:code * 16 + 3] == bytes([vt100_base[code * 16]]) * 3, code
    for code in (0x0C, 0x0D, 0x0F, 0x15, 0x16, 0x18, 0x19):
        assert vt100[(code + 1) * 16 - 1] & 0x10, code
    business = Path("build/mapped/pet-business.bin").read_bytes()
    ascii_expected = bytearray(business)
    for operation, code, value in parse_patch("patches/pet-ascii.fontedit", 8):
        glyph = business[value * 8:(value + 1) * 8] if operation == "copy" else value
        ascii_expected[code * 8:(code + 1) * 8] = glyph
    ascii_font = Path("build/mapped/pet-ascii.bin").read_bytes()
    assert ascii_font == ascii_expected
    graphics = Path("build/mapped/pet-graphics.bin").read_bytes()
    combo = Path("build/mapped/pet-ascii-graphics.bin").read_bytes()
    assert combo == combine(ascii_font, graphics)
    for name in ("pet-ascii-graphics", "ega-8x8", "spectrum", "atari", "osborne-8x8"):
        assert Path(f"build/bank/{name}.bin").read_bytes() == make_bank(
            Path(f"build/mapped/{name}.bin").read_bytes(), 8, rows=8), name
    combo_bank = Path("build/bank/pet-ascii-graphics.bin").read_bytes()
    assert combo_bank == ascii_font + graphics
    assert Path("build/bank/ega-8x8.bin").read_bytes() == ega_8x8
    for name in ("spectrum", "atari", "osborne-8x8"):
        source = Path(f"build/mapped/{name}.bin").read_bytes()
        bank = Path(f"build/bank/{name}.bin").read_bytes()
        assert bank[:1024] == source
        assert bank[1024:] == bytes(pixel ^ 0xFF for pixel in source)
    assert Path("build/bank/reserved.bin").read_bytes() == bytes(2048)
    print("OK: 16 8x8 banks, 32768 bytes; taller originals kept as previews")


if __name__ == "__main__":
    main()
