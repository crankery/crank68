# Processor GAL bank-select variants

The rev 1 processor board has two bank-select choices. Each has a standard
program for an external `/Φ2` inverter and a pin-18 bodge program:

| Source | `/BANK_SEL` owner | Pin 18 | Use |
| --- | --- | --- | --- |
| `cpu.gal` | Processor GAL | Unused | No Video board; external inverter |
| `cpu-video.gal` | Video GAL | Unused | Video board installed; external inverter |
| `cpu-rev1-bodge.gal` | Processor GAL | `/Φ2` output | No Video board; lifted pin 18 |
| `cpu-video-rev1-bodge.gal` | Video GAL | `/Φ2` output | Video board installed; lifted pin 18 |

The two video variants keep physical pin 21 high impedance. Its output-enable
product term is `PHI2 * /PHI2`, which can never be true. The video board
must then drive `/BANK_SEL` high when VRAM is selected and low for valid
`$C000–$DFFF` banked-SRAM cycles. Do not fit either video program
without a Video board whose GAL implements that selection.

The Video board's `VRAM/~BANK` configuration bit resets low, so its GAL
asserts `/BANK_SEL` during valid `$C000–$DFFF` accesses by default. MIKBUG2
and the serial SRAM loader can therefore boot and load the disk without
writing the video mode latch first.

Assemble the variant with GALasm before programming the GAL22V10. The
generated `cpu-video.jed` is included here; regenerate it after changing
the equations.

## Processor transceiver enable and board revision

The standard GAL sources leave pin 18 unused. The rev 1 PCB grounds that pin,
so it must not be programmed as an output while seated in the socket. U4 pin 19
(`/CE`) is on an undriven `/Φ2` net on the rev 1 PCB. The revised schematic
uses a separate inverter from `Φ2` to `/Φ2`; an existing rev 1 board still
needs a physical rework to drive U4 pin 19.

The revised processor board has JP1 between U7 pin 21 and backplane
`/BANK_SEL`. Fit the shunt without a video board; remove it when the video
board drives the signal. This lets `cpu.gal` serve both configurations on
that board. The rev 1 PCB connects those points directly and still requires
one of the video variants when the video board is installed.

## Rev 1 board rework

The assembled rev 1 PCB has three missing connections:

1. Wire U2 (MC6875) pin 7, **BUS Φ2**, to U1 (MC6800) pin 36, **DBE**.
   This also drives the DBE contact on the backplane.
2. Wire J1 backplane pin 46, **R/W**, to U4 (74LS245) pin 1, which is
   already on the processor R/W net.
3. Drive U4 pin 19, **/CE**, with the inverse of BUS Φ2. Choose one method:
   - With a rev 1 bodge GAL program, lift GAL pin 18 entirely clear of its
     grounded socket contact, then wire the lifted leg to U4 pin 19.
     **Never seat pin 18 while running either bodge program.**
   - With a separate 74HCT00, tie gate inputs 1 and 2 to BUS Φ2 and wire
     gate output 3 to U4 pin 19. Power the IC at pins 14 (+5 V) and 7
     (ground), add a local 100 nF bypass capacitor, and tie all six unused
     gate inputs low. Use a standard GAL program with pin 18 unused.

Run `make pld` to assemble the GAL sources. The programming files are under
`build/pld/`. Before applying power, verify the lifted GAL leg (if used) is
isolated from ground and that the new wires do not short adjacent pins.
