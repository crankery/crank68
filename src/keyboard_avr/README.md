# Instore keyboard AVR

Firmware for U4, the ATmega328P-P on `../../Instore/Instore.kicad_sch` and
`../../Instore/Keyboard.kicad_sch`. It scans the existing 6-row, 11-column
keyboard through the two 74LS165s and the 74LS138, debounces three complete
scans spaced 5 ms apart, translates key presses to ASCII, and queues up to 15
characters. There is no key repeat. Caps Lock controls the LED. Ctrl+backslash
pulses `/NMI`; Ctrl+Backspace pulses system `/RESET`. Either Control key works.
Reset takes precedence if both combinations are pressed together.

This is the direct C68 bus version of the earlier VERA keyboard firmware. The
scan, debounce, translation and queue logic in `key_logic.cpp` is retained;
`firmware.ino` now drives two isolated 74HCT573 output latches and uses U7's
read-completion flip-flop. It is not compatible with the VERA `$E080` driver.

## Address and byte protocol

The slot jumpers set A7–A4. When they select `$E080`, U2 assigns:

| Address | Operation | Result |
| --- | --- | --- |
| `$E082` | Read status | Bit 0 `READY`; bit 1 `SEQUENCE`; other bits zero |
| `$E083` | Read data | Oldest queued ASCII byte; its read completion is recorded by U7 |

The firmware stages the oldest byte in U12, then publishes status in U11. A
nonzero byte sets `READY`. A complete data read sets U7's acknowledgment;
firmware then consumes that byte, stages the next one, and toggles `SEQUENCE`.
It also toggles `SEQUENCE` when it first stages a byte after an empty queue.
The host should read status until `READY` is set, read data once, and then
wait for `SEQUENCE` to change before starting another data read. This avoids
reading the old latched byte while the AVR handles the acknowledgment. Status
reads have no side effects. No AVR interrupt has to meet a C68 bus-cycle time.

Return is 13, Backspace 8, Tab 9, Escape 27, and Control letters 1–26. If the
queue fills, the newest character is dropped and earlier input is retained.
The host must use the new status/data protocol; the old `vera/keyboard.s` reads
`$E080` and does not work with this board.

## U4 pins

| DIP pin(s) | Port | Use |
| --- | --- | --- |
| 2–6, 11–13 | PD0–PD7 | Byte bus to U11/U12 inputs only; never directly to C68 D0–D7 |
| 14 | PB0 | `/KBD_STATUS` input (available to firmware; not currently used) |
| 15 | PB1 | `/KBD_DATA` input (available to firmware; not currently used) |
| 16 | PB2 | Caps LED cathode output, active low |
| 17 | PB3 | U7 read acknowledgment input, high after a data read |
| 18 | PB4 | U11 status latch enable output |
| 19 | PB5 | U12 data latch enable output |
| 9 | PB6 | `/NMI` output, sinks low then floats |
| 10 | PB7 | System `/RESET` input/output, sinks low then floats |
| 23 | PC0 | Keyboard serial QS input |
| 24 | PC1 | Keyboard `/PL` output |
| 25 | PC2 | Keyboard CP output |
| 26–28 | PC3–PC5 | Keyboard row A0–A2 outputs |
| 1 | RESET/PC6 | AVR's own reset input with separate pull-up; RSTDISBL remains unprogrammed |

PB6/PB7 are available because the AVR uses its internal RC oscillator and
asynchronous Timer2 is not enabled. Both shared system lines require external
pull-ups. An externally asserted system reset on PB7 clears the key queue and
Caps Lock state. The AVR's own RESET input remains separate, so the keyboard
firmware can finish a system reset pulse.

## Build

Run `make -C keyboard_avr` from `src/`. It produces
`keyboard_avr/build/firmware.ino.hex` for the ATmega328P-P at 8 MHz.
`make -C keyboard_avr test` checks key translation, debounce, and queue logic.
The build does not flash the AVR or change fuses. Use ISP and the internal
8 MHz clock fuses in `fuses.conf`; do not program RSTDISBL. Hardware timing,
latch bit order and the status/data handshake still need bench testing.
