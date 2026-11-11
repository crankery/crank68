# Processor GAL bank-select variants

The processor board has two compatible U7 programs:

| Source | `/BANK_SEL` owner | Use |
| --- | --- | --- |
| `cpu.gal` | Processor GAL | No Video board |
| `cpu-video.gal` | Video GAL | Video board installed |

`cpu-video.gal` keeps physical pin 21 high impedance. Its output-enable
product term is `PHI2 * /PHI2`, which can never be true. The video board
must then drive `/BANK_SEL` high when VRAM is selected and low for valid
`$C000–$DFFF` banked-SRAM cycles. Do not fit the `cpu-video.gal` program
without a Video board whose GAL implements that selection.

The Video board's `VRAM/~BANK` configuration bit resets low, so its GAL
asserts `/BANK_SEL` during valid `$C000–$DFFF` accesses by default. MIKBUG2
and the serial SRAM loader can therefore boot and load the disk without
writing the video mode latch first.

Assemble the variant with GALasm before programming the GAL22V10. The
generated `cpu-video.jed` is included here; regenerate it after changing
the equations. A later processor-board revision could use a jumper to
select which board owns `/BANK_SEL` without swapping GAL programs.
