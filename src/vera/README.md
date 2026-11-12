# C68 VERA text display experiment

> **Inactive legacy add-on:** the VERA adapter is paused in favor of the
> [Instore board](../../Instore/). This driver and its `$E080` keyboard protocol
> are retained for reference; the current keyboard AVR firmware targets
> Instore's `$E082/$E083` status/data registers.

`make` builds a FLEX command named `VERA.CMD` on SRAM drive 0. Set the VERA
adapter's A5–A7 slot switches to select `$E040–$E05F` (the two slots starting
at `$E040`), then run `VERA` at the FLEX prompt. The command initializes a
VGA text screen, prints a banner, and displays keys from the matrix keyboard
connected to the VERA board's keyboard AVR. Return, tab, backspace, Shift,
Caps Lock, and Control-letter are handled by the AVR; Ctrl-C returns to FLEX.
FLEX continues using
its serial console before and after the command.

The new command is in the freshly built `build/system/flex2.dsk`. Existing
saved emulator sessions preserve their directories and will not gain it
automatically; use a fresh working copy of the built image when testing.

## Keyboard connection

The VERA board connects the matrix keyboard to its ATmega328P. Bridge the
keyboard address jumpers for `$E080`, independent of the VERA register slot.
`keyboard.s` reads this one byte until it gets nonzero ASCII. Each read
consumes a character; the AVR handles scanning, debounce, modifiers, Caps
LED, Ctrl+backslash NMI, and Ctrl+Backspace reset. The original VERA
keyboard firmware has been superseded by the Instore version in `../keyboard_avr/`; it cannot be used with this `$E080` driver.
The older PIA 2 keyboard connection is unused.

The base address is one constant, `vera_base`, near the top of `terminal.s`.
The adapter carries A0–A4 to VERA, so the window must be 32-byte aligned. Do
not place it over the SRAM latches at `$E000`, ACIA #1 at `$E010`, or the PIA
at `$E020`. The board's switches choose A5–A7, so `$E040` selects switch
pattern 010 (electrical polarity depends on the board's switch wiring).

The display uses VERA layer 0 with a 128 × 32 tile map in VRAM `$00000` and
an 8 × 8 ASCII font at VRAM `$08000`. Horizontal scale is 1:1 and vertical
scale is 2:1, yielding 80 × 30 visible characters on VGA. Scrolling rotates
the map's 32 physical rows through VERA's vertical scroll register. The font
is converted at build time from the repository's PicoDVI `font_8x8.h`, which
is covered by the PicoDVI BSD 3-Clause license.

`make test` runs the 6800 code against small VERA and keyboard-byte models. It
checks font upload, text positioning, backspace, scrolling, and queued input,
then verifies the disk image. The keyboard AVR project separately tests matrix
translation and debouncing. The normal C68 emulator does not yet emulate
VERA or the keyboard AVR.
This is a display and input exercise, not a replacement FLEX or MIKBUG console
driver. Those can call `vera_init`, `keyboard_getc`, and `term_putc` after
terminal control sequence behavior is worked out.
