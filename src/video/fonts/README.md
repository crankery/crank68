# C68 font EEPROM

Run `make` to build `build/fonts-28c256.bin` and its full ROM contact sheet `build/fonts-28c256.png`, or `make check` to build and verify them. Python 3 and Pillow (`python3 -m pip install -r requirements.txt`) are needed. `make clean` removes generated files.

The 32 KB image has eight 4 KB banks. Address bits A0–A3 select a scanline, A4–A11 select a character, and A12–A14 select a font.

To reorder banks, reorder the names in `FONTS` in the Makefile and run `make`. Update the bank table below to match.

| Bank | Face | Source | Source size |
| ---: | --- | --- | --- |
| 0 | Xerox Alto | `SysFont.Al.` | 128 used × 8 × 12 |
| 1 | VT100 | `vt100-23-018E2.bin` | 128 × 8 × 16 |
| 2 | Reserved, blank | — | 4096 zero bytes |
| 3 | IBM EGA | `IBM-EGA.bin`, `$2230–$302F` | 256 × 8 × 14 |
| 4 | PET ASCII / PET graphics | PET business plus `patches/pet-ascii.fontedit`; PET graphics in upper half | 256 × 8 × 8 |
| 5 | Spectrum 48K | `sinclair-spectrum-48.rom`, `$3D00–$3FFF` | 96 × 8 × 8 |
| 6 | Atari 8 bit | `ATARIOSB.ROM`, `$0800–$0BFF` | 128 × 8 × 8 |
| 7 | Osborne 1 | `OCC1_char.BIN` | 128 × 8 × 10 |

All inputs are in `resources/`. `build/extract/*.bin` and `*.png` are straight source order glyph extracts and contact sheets. The Alto extract keeps all 256 decoded slots, although slots 128–255 are empty. `build/mapped/*.bin` contains ASCII arranged glyphs, and each mapped binary has a matching `*.png` contact sheet. Every sheet starts with a 40-column text sample using adjacent glyphs; the full ROM sheet shows one sample per bank. Samples on straight extracts may read oddly where the ROM's glyph order differs from ASCII. `build/bank/` contains each final 4 KB bank.

The VT100 extract keeps the original ROM rows. Its glyphs rotate down two scanlines, then `patches/vt100.fontedit` extends the vertical strokes of ten line drawing glyphs to their cell edges. The patched glyphs shift down two more rows in the mapped font; any lit top row is repeated into the exposed rows to keep line drawings connected. The Atari map applies `patches/atari.fontedit`: triangles move to `$00` and `$10`, the original `$7D` glyph moves to `$1B`, the original `$1B` glyph moves to `$7F`, and `$60`, `$7B`, `$7D`, and `$7E` receive ASCII punctuation. The Osborne ROM stores row 0 of all 128 glyphs, then row 1 of all glyphs, through row 9; its decoded extract puts each glyph's ten rows together. The remaining 768 bytes of the 2 KB ROM are unused by the font. This layout follows the [Osborne 1 Technical Manual, section 5.3](https://www.esocop.org/docs/Osborne1TechnicalManual.pdf). Eight row glyphs are doubled vertically. Ten, twelve, and fourteen row glyphs have equal blank padding above and below. For 128 glyph faces, codes `$80–$FF` are inverted copies of `$00–$7F`. The combined PET bank uses ASCII in `$00–$7F` and graphics in `$80–$FF`, with no inversion. EGA already contains 256 glyphs, so its upper half comes from the ROM. Spectrum block graphics are generated at `$00–$0F`, matching its firmware convention.

To edit the PET ASCII, VT100, or Atari glyphs, change their files in `patches/`. For other glyph edits, `tools/fontedit.py dump <build/mapped/name.bin> --height N` shows bitmaps, and `tools/fontedit.py build INPUT PATCH --height N -o OUTPUT` applies `@XX` bitmap or `copy DEST SOURCE` directives. Add a Makefile patch stage to use further edits in the EEPROM build.
