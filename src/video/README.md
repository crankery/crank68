# 6845 video card

Notes for the KiCad schematic in `../Video/`. This describes the signal flow
currently drawn in the schematic. It is not a measured timing sign-off.

## The cast

| Part | Job |
| --- | --- |
| U1 MC6845 | Character addresses, raster row, display enable, and sync. |
| U3 IDT7005L55J | 8K × 8 dual-port video RAM; 55 ns address access grade. |
| U2 AT28C256-compatible EEPROM | Eight selectable character fonts in a 32-pin PLCC socket. Provisional 150 ns access-time budget. |
| U8 74F163A | Counts the 16 MHz dot clock in groups of eight. |
| U19 74ACT238 + U10 74ACT273 | Decode the dot count, then register clean fetch and load strobes. |
| U20/U21 74ACT574 | Hold 16 bits of 6845 address, raster row, and DE. |
| U11/U13 74ACT574 | Hold the character and attribute bytes fetched from RAM. |
| U9 74ACT299 | Load eight font pixels, then shift them out one at a time. |
| U17 74ACT574 + U18 74ACT74 | Align the display attribute and DE with the glyph. |
| U14 74ACT157 + U12 74ACT175 | Select foreground/background colour, then register RGBI. |
| U22 74AHCT1G02 | Combine HSYNC and VSYNC into provisional CSYNC. |
| U6 74ACT273 | CPU-written mode register; separate from the U10 timing register. |

The CPU side still selects video RAM in the shared 8K banked window. The
video-card GAL decodes the 6845 registers and mode latch. Font selection and
display-page selection come from that mode latch.

## A small time machine made of flip-flops

```text
                              16 MHz oscillator
                                      |
                                  U8 F163A
                             count 0 1 2 3 4 5 6 7
                              |       |       |
                              |       +--> Q2: 2 MHz 6845 clock
                              |                 +--> RAM character/attribute select
                              v
                      U19 ACT238 decoder
                              |
                      U10 ACT273 strobes
                        |   |   |   |
                        |   |   |   +-- SNAPSHOT_CAPTURE, count 7
                        |   |   +------ ATTR_CAPTURE,     count 6
                        |   +---------- CHAR_CAPTURE,     count 3
                        +-------------- GLYPH_LOAD,       count 2 to 3

  6845 MA, RA, DE
          |
          v             count 7
  U20/U21 snapshot registers ----------> MA', RA', DE'
          |                                  |    |    |
          |                                  |    |    +--> U18A -- U18B
          |                                  |    |         count 6  count 3
          |                                  |    |            \    /
          |                                  |    +--> font ROM  \  / display DE
          |                                  v                   \/
          |                             dual-port RAM          U14 enable
          |                              /        \
          |                    character/          \attribute
          |                     count 3              count 6
          |                       |                     |
          |                      U11                   U13
          |                       |                     |
          |                       +--> font ROM         +--> U17, count 3
          |                              |                       |
          |                         U9 ACT299 --> pixel --> U14 colour mux
          |                         load count 3                 |
          |                                                    U12 RGBI
          |                                                one dot per edge
          |                                                       |
          |                                                       v
          |                                                  video output
          +-- the 6845 has already moved on by the time this pixel arrives
```

Each 6845 address gets **snapshotted**, read as two RAM bytes in the next
character period, and painted in the period after that. The diagram's U18A
and U18B path carries DE through those same two handoffs.

## Addresses and pages

U20 captures `MA0`–`MA7`. U21 captures `MA8`–`MA10`, `RA0`–`RA3`, and
`DE`. Both clock on `SNAPSHOT_CAPTURE` at count 7. Their outputs have primed
names: `MA0'`–`MA10'`, `RA0'`–`RA3'`, and `DE'`.

The RAM's video port gets `MA0'`–`MA10'` on A0–A10. A11 is `TEXT_PAGE`;
A12 is U8 Q2, labelled `CHAR_CLK_{(2MHz)}`. Q2 is low over counts 0–3, when
RAM presents the character byte. It is high over counts 4–7, when RAM
presents the attribute byte. Its falling edge at count 0 also advances the
6845. The snapshots prevent that simultaneous 6845 address change from
disturbing the current RAM fetch.

The font ROM gets `RA0'`–`RA3'` for the raster row, U11's character byte,
and three mode bits for the selected font. Its eight data outputs are
`CGD0`–`CGD7`.

### Font ROM image layout options

Each of the eight font-select values owns a 4 KiB ROM bank. As wired, ROM
A0–A3 come from `RA0'`–`RA3'`, A4–A11 come from all eight character bits,
and A12–A14 select the font. This supports 256 glyphs × 16 rows per bank.

For inverse video with no hardware change, use character bit 7 to select
an inverted copy of each glyph: 128 glyphs × 16 rows × two polarities per
bank. Store the inverted row byte as `normal_row ^ 0xFF`. With raster row
`r`, seven-bit character `c`, and font bank `f`, the address is
`(f << 12) | (inverse << 11) | (c << 4) | r`.

Alternatively, 128 glyphs × 32 rows also fits in a 4 KiB bank, but that
requires ROM A11 to receive the 6845's `RA4` rather than character bit 7.
The current schematic leaves 6845 pin 34 (`RA4`) unconnected, and U21 has
no free snapshot bit. Add a flip-flop clocked by `SNAPSHOT_CAPTURE` for RA4
before using it as a ROM address. The 6845 maximum-scan-line register can
then select rows 0–31. A 32-line font at 80 × 25 would require 800 visible
scanlines; at 16 MHz and 640 visible dots per line, even zero blanking would
limit refresh to 31.25 Hz. A practical tall-font mode needs fewer text rows
or a different video clock/format.

## Registered strobes

U8's Q0, Q1, and Q2 outputs form a three-bit count. U19 decodes it into
active-high Y0–Y7. U10 and U8 share the **same 16 MHz rising-edge clock**:
U10 samples the decode of the *old* count while U8 advances. Thus a selected
Y output becomes a clean U10 Q pulse during the following count.

| U19 output | U10 input → output | Registered signal | Active during |
| --- | --- | --- | --- |
| Y1, pin 14 | D0 pin 3 → Q0 pin 2 | `GLYPH_LOAD` | Count 2 |
| Y2, pin 13 | D1 pin 4 → Q1 pin 5 | `CHAR_CAPTURE` | Count 3 |
| Y5, pin 10 | D2 pin 7 → Q2 pin 6 | `ATTR_CAPTURE` | Count 6 |
| Y6, pin 9 | D3 pin 8 → Q3 pin 9 | `SNAPSHOT_CAPTURE` | Count 7 |

The U19-to-U10 nets are distinct from the named strobes leaving U10.
U19 may glitch while U8 changes count; U10 samples after the decoder has
settled. U8 Q2 itself is already registered, so the RAM phase needs no
extra gates or flip-flop.

## One character's itinerary

The 16 MHz dot period is 62.5 ns. Eight dots make a 500 ns 6845 character
period. For a particular character **N**, the overlapping stages are:

```text
6845 period N:        0  1  2  3  4  5  6  7
                                           snapshot MA, RA, DE for N

6845 period N+1:      0  1  2  3  4  5  6  7
                      |        |  |     |
                      |        |  |     +-- U13 captures attribute N
                      |        |  |         U18A captures DE N
                      |        |  +-------- RAM selects attribute
                      |        +----------- U11 captures character N
                      +-------------------- RAM selects character

6845 period N+2:      0  1  2  3  4  5  6  7  0  1  2  3
                               |  |                    |
                               |  +-- first RGBI dot    +-- final RGBI dot
                               +----- U9 loads glyph N
                                      U17 takes attribute N
                                      U18B takes DE N
```

At count 6, U13 and U18A capture the attribute and `DE'` together. At the
next count 3, U17 and U18B transfer that pair to the display stage. U18B's
inverted Q drives U14's active-low enable `~DISPLAY_DE`; its ordinary Q is
unused. U11 also uses `CHAR_CAPTURE`, but it captures the *next* character
while U17 displays the one already fetched.

The IDT7005L55J has a 55 ns maximum address access time. The attribute
read gets two dot periods (125 ns) between the count-4 phase change and
count-6 capture, less propagation and setup delays.

## U9: swallow a byte, spit out pixels

U9 is a 74ACT299 universal shift register. With `S1=1, S0=1`, the next
rising pixel edge loads `CGD7..CGD0` in parallel. With `S1=1, S0=0`,
subsequent edges shift left, presenting bits 7 through 0 at Q7.

| U9 pin | Connection |
| --- | --- |
| 1 `S0` | `GLYPH_LOAD`: high during count 2, sampled at the count-3 edge. |
| 19 `S1` | +5 V. |
| 2 `/OE1`, 3 `/OE2` | +5 V; the ROM drives the parallel I/O pins. |
| 7, 13, 6, 14 | `CGD0`, `CGD1`, `CGD2`, `CGD3` respectively. |
| 5, 15, 4, 16 | `CGD4`, `CGD5`, `CGD6`, `CGD7` respectively. |
| 17 `Q7` | Serial `PIXEL` output. |
| 12 `CP` | 16 MHz pixel clock. |
| 9 `/MR` | Inactive during normal operation. |
| 18 `DS7`, 11 `DS0` | Defined low level. |
| 20, 10 | +5 V, ground. |

```text
pixel edge:        count 3     4       5       ...    next count 3
299 action:        load N      shift   shift          load N+1
299 Q7 afterward: bit 7       bit 6   bit 5          next bit 7
U12 captures:      prior bit   bit 7   bit 6          bit 0
```

U14 selects foreground or background from U17 using the pixel bit, and
blanks outside delayed DE. U12 captures the resulting four RGBI bits on
every pixel edge. That output register keeps intermediate mux transitions
away from the video output.

## Timing notes

- The font ROM gets about one 500 ns character period from U11's capture
  to U9's load. Keep **150 ns** as the provisional address-access budget.
  The EEPROMs already on hand are marked `AT28C256-12JC`, a code absent from
  published AT28C256 ordering information, so their identity and speed are
  unverified. A couple of 120 ns AT28HC256 pulls have been ordered from eBay,
  and a genuine 120 ns AT28HC256 was included in the DigiKey order. This
  grade shares U2's 5 V, 32-pin PLCC read pinout and fits the access budget.
  Verify the actual parts and complete the timing check before final sign-off.
- The 299 load-mode handoff, registered strobe pulse widths, and all setup
  and hold margins still need a final datasheet calculation. The circuit
  has not been measured on a board.
- The first RGBI dot for a 6845 address emerges about 20 pixel clocks
  after that address's count-0 edge. The 6845 sync positions and porch
  values must account for that fixed delay.
- The current `CSYNC` is `~(HSYNC | VSYNC)` from U22's NOR gate. This
  suppresses horizontal sync pulses throughout vertical sync. Revisit the
  waveform against the intended display's sync requirements before calling
  the composite-sync output finished.
- Page and font mode bits currently come from the CPU-written register;
  changing either during active display may show a partial frame.

The `video/` directory can also hold the video-card GAL equations and the
eight-font EEPROM image when those are written.

## Datasheets

- [Renesas/IDT 7005 dual-port RAM](https://www.renesas.com/document/dst/7005-data-sheet)
- [Motorola MC6845](https://www.spic.net/mirrors/misc/mindcandydvd.com/pub/drivers/Motorola/mc6845.pdf)
- [TI CD74ACT299](https://www.ti.com/lit/ds/symlink/cd74act299.pdf)
- [TI CD74ACT273](https://www.ti.com/lit/ds/symlink/cd74ac273.pdf)
- [TI CD74ACT238](https://www.ti.com/lit/ds/symlink/cd74act238.pdf)
- [Atmel AT28C256 historical data sheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf)
- [Microchip AT28C256 ordering information](https://ww1.microchip.com/downloads/aemDocuments/documents/MPD/ProductDocuments/DataSheets/AT28C256-Industrial-Grade-256-Kbit-Paged-Parallel-EEPROM-Data-Sheet-DS20006386.pdf)
- [Microchip AT28HC256 ordering information](https://onlinedocs.microchip.com/oxy/GUID-69965E02-E221-4AA5-B83B-FEEC9DAFC06D-en-US-2/GUID-ADB76E99-DC24-4AF5-9900-BED214AAAF86.html)
