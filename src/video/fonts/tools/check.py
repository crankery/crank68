#!/usr/bin/env python3
"""Check image layout and transformations against source and intermediate files."""
import sys
from pathlib import Path

from bank import make_bank
from combine import combine
from extract import extract
from fontedit import parse_patch
from remap import remap
from roll import roll
from shift import shift_down


def main():
    image = Path(sys.argv[1]).read_bytes()
    paths = [Path(p) for p in sys.argv[2:]]
    assert len(paths) == 8 and len(image) == 32768
    for number, path in enumerate(paths):
        bank = path.read_bytes()
        assert len(bank) == 4096
        assert image[number * 4096:(number + 1) * 4096] == bank, path

    for name, source in (
        ("vt100", "vt100-23-018E2.bin"),
        ("pet-graphics", "cbm-pet.901447-08.bin"),
        ("pet-business", "cbm-pet.901447-08.bin"),
        ("spectrum", "sinclair-spectrum-48.rom"),
        ("atari", "ATARIOSB.ROM"),
        ("ega", "IBM-EGA.bin"),
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
    for name, height in (("vt100", 16), ("pet-ascii-graphics", 8),
                         ("spectrum", 8), ("atari", 8),
                         ("ega", 14), ("alto", 12), ("osborne", 10)):
        assert Path(f"build/bank/{name}.bin").read_bytes() == make_bank(
            Path(f"build/mapped/{name}.bin").read_bytes(), height), name
    combo_bank = Path("build/bank/pet-ascii-graphics.bin").read_bytes()
    assert combo_bank[:2048] == make_bank(ascii_font, 8)[:2048]
    assert combo_bank[2048:] == make_bank(graphics, 8)[:2048]
    assert Path("build/bank/reserved.bin").read_bytes() == bytes(4096)
    osborne_bank = Path("build/bank/osborne.bin").read_bytes()
    assert osborne_bank[0x41 * 16:0x42 * 16] == bytes(3) + osborne[0x41 * 10:0x42 * 10] + bytes(3)
    assert osborne_bank[2048:] == bytes(pixel ^ 0xFF for pixel in osborne_bank[:2048])
    print("OK: seven font banks plus blank bank, 32768 bytes; PET halves verified")


if __name__ == "__main__":
    main()
