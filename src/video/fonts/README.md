# C68 font EEPROM

Run `make` to build `build/fonts-28c256.bin` and its full ROM contact sheet `build/fonts-28c256.png`, or `make check` to build and verify them. Python 3 and Pillow (`python3 -m pip install -r requirements.txt`) are needed. `make clean` removes generated files.

The 32 KB image has sixteen 2 KB banks. Every bank has 256 glyphs of eight rows. The intended EEPROM address wiring is A0=`RA0′`, A1=`RA1′`, A2=`RA2`, A3–A10=the video RAM character byte, and A11–A14=the four font select bits. `RA3′` is not used by the font ROM. Because A0 and A1 are inverted, the assembled ROM stores logical glyph row `r` at physical row address `r XOR 3`. `ROM_ROW_ADDRESS_XOR` in the Makefile controls this permutation; the full ROM contact sheet decodes it for display.

To reorder banks, reorder the names in `FONTS` in the Makefile and run `make`. Update the bank table below to match.

| Bank | Face | Source | Source size |
| ---: | --- | --- | --- |
| 0 | PET ASCII / PET graphics | PET business plus `patches/pet-ascii.fontedit`; PET graphics in upper half | 256 × 8 × 8 |
| 1 | IBM EGA 8×8 | `IBM-EGA.bin`, `$3160–$395F` | 256 × 8 × 8 |
| 2 | Spectrum 48K | `sinclair-spectrum-48.rom`, `$3D00–$3FFF` | 128 × 8 × 8 after graphics generation |
| 3 | Atari 8 bit | `ATARIOSB.ROM`, `$0800–$0BFF` | 128 × 8 × 8 |
| 4 | Osborne 1 | `OCC1_char.BIN`, reduced from 8×10 | 128 × 8 × 8 |
| 5–15 | Reserved, blank | — | 2048 zero bytes each |

All inputs are in `resources/`. Every binary produced by the current build in `build/extract/`, `build/rolled/`, `build/base/`, `build/mapped/`, and `build/bank/` has a same-name PNG contact sheet beside it. `extract` contains source order glyphs; `rolled` and `base` hold intermediate transformations; `mapped` holds edited or ASCII arranged glyphs; and `bank` holds the 256-glyph, 2 KB banks assembled into the ROM. The Alto extract keeps all 256 decoded slots, although slots 128–255 are empty. Every sheet starts with a 40-column text sample using adjacent glyphs; the full ROM sheet shows one sample per bank. Samples on straight extracts may read oddly where the ROM's glyph order differs from ASCII. The `bank` sheets also show the upper 128 glyphs, including inverted copies where used.

The final ROM stores eight rows per glyph, with no vertical scaling. Spectrum, Atari, and Osborne have inverted copies in `$80–$FF`. The combined PET bank uses ASCII in `$00–$7F` and graphics in `$80–$FF`. EGA 8×8 has 256 glyphs from its ROM. Spectrum block graphics are generated at `$00–$0F`, matching its firmware convention. The EGA 8×8 offset is documented by [PCjs](https://www.pcjs.org/machines/pcx86/ibm/video/ega/).

The taller originals remain in the extract and mapped previews: Alto 8×12, VT100 8×16, EGA 8×14, and Osborne 8×10. The VT100 mapped font retains its rotation, line drawing patch, and shift. The Osborne extract transposes its row-interleaved ROM layout, as described in the [Osborne 1 Technical Manual, section 5.3](https://www.esocop.org/docs/Osborne1TechnicalManual.pdf). `tools/osborne8.py` takes rows 1–8 of most printable glyphs, rows 2–9 for descenders, and eight rows spread across the ten-row control graphics. The patch gives the four corner triangles at `$08`, `$0A`, `$15`, and `$19` even diagonals and replaces the damaged fraction symbols at `$13` and `$1D` with euro and pound signs. It also removes a repeated body row from Q, g, p, q, and y, preserving their tails and aligning the lowercase tops. It moves the `i` dot up while keeping its stem aligned with the unpatched `j`. The reduced face and its sheet are in `build/mapped/osborne-8x8.*`.

To edit the PET ASCII, VT100, Atari, or Osborne 8×8 glyphs, change their files in `patches/`. For other glyph edits, `tools/fontedit.py dump <build/mapped/name.bin> --height N` shows bitmaps, and `tools/fontedit.py build INPUT PATCH --height N -o OUTPUT` applies `@XX` bitmap or `copy DEST SOURCE` directives. Add a Makefile patch stage to use further edits in the EEPROM build.
