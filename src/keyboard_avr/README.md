# VERA board keyboard AVR

This is firmware for U4, the ATmega328P-P on `../../Vera/Vera.kicad_sch`.
It scans the `../../Keyboard` 6-row, 11-column matrix using the two chained
74LS165 shift registers and the 74LS138 row selector. It debounces each
complete matrix for three scans spaced 5 ms apart, translates newly pressed
keys to 7-bit ASCII, and queues up to 15 characters. There is no key repeat.
The Caps LED follows the Caps Lock state. Ctrl+backslash pulses `/NMI` once
per press, even if the character queue is full; that backslash does not enter
the queue. Ctrl+Backspace similarly pulses `/RESET` without queuing Backspace.
Either Control key works for both combinations. Reset takes precedence if
both combinations are pressed together.

## Address and byte protocol

Bridge the eight address comparator jumpers for **`$E080`** (A7 set, A6–A0
clear). The 74LS688 compares those eight bits with A7–A0; its `/G` input
uses `/IO_SEL`. This byte is outside the SRAM latches at `$E002/$E003`, the
first ACIA at `$E010`, the IO board at `$E020`, VERA at `$E040–$E05F`, and
the sound board at `$E060`. The keyboard address is independent of VERA's
slot switches.

Read `$E080`: zero means no character; a nonzero value is the oldest queued
ASCII byte, removed after that read cycle. Return is 13, Backspace is 8,
Tab is 9, Escape is 27, and Control letters are 1–26. Firmware drops the
newest character when its queue fills; existing queued input is preserved.
The address is read-only. Give consecutive reads at least one ordinary 6800
instruction between them so the AVR can stage the next byte.

## Required schematic changes before connecting to the C68 bus

The current sketch directly connects U4 PD0–PD7 to the shared C68 D0–D7.
That cannot safely drive a bus read: setting PD as outputs causes bus
contention on other cycles, while changing PD direction after a decode is
too slow for a 6800 read. **Do not run this firmware on that wiring.**

Add an eight-bit **74HCT573 transparent latch** between U4 PD0–PD7 and C68
D0–D7. Its latch enable and active-low output enable can both use
`/KEY_READ`: while idle, the latch follows the next byte on PD with outputs
disabled; during a read, it freezes that byte and drives the bus. This
also keeps a newly arriving key from changing the byte midway through a CPU
read. Generate active-low `/KEY_READ` from all three
conditions:

* `/KEY_SEL` from the 74LS688 is low;
* `R/W` is high (read);
* `BUS_OK` is high (valid bus cycle).

Use `/KEY_READ` for the latch's LE and `/OE`, and for U4 PC1, replacing
the current raw `/KEY_SEL` connection to PC1. U4's PC1 pin-change interrupt
records the short read pulse, waits for its end, then removes the byte from
the queue. U4 PC0 and PC2 may retain their existing BUS_OK and R/W wiring;
the hardware qualification handles the read timing. The latch must be
disabled during reset and whenever `/KEY_READ` is high. The firmware treats
U4 PC4 `/NMI` and PC5 `/RESET` as open-drain outputs: each drives low for
100 µs and then floats. The processor board supplies the `/RESET` pull-up;
`/NMI` also needs a pull-up. PC5's system `/RESET` net must be distinct from
U4 pin 1's own reset input if the AVR is to complete its pulse independently.

The pin assignments are:

| U4 port | Connection |
| --- | --- |
| PD0–PD7 | buffered data byte, D0–D7 |
| PB0 | keyboard QS input |
| PB1 | keyboard `/PL` output |
| PB2 | keyboard CP output |
| PB3–PB5 | keyboard A0–A2 row outputs |
| PC0 | BUS_OK input |
| PC1 | qualified `/KEY_READ` input |
| PC2 | R/W input |
| PC3 | Caps LED cathode output |
| PC4 | `/NMI` open-drain output |
| PC5 | `/RESET` open-drain output |

## Build

Run `make -C keyboard_avr` from `src/`. It uses the installed Arduino AVR
toolchain and produces `keyboard_avr/build/firmware.ino.hex` for the
ATmega328P-P clocked from its internal 8 MHz oscillator. This build does not
flash or change fuses. `fuses.conf` copies the SD bridge AVR's settings:
internal 8 MHz clock with the divide-by-eight fuse disabled. Program the
firmware HEX without the Arduino bootloader. `make -C keyboard_avr test` runs the matrix/debounce/
translation/queue checks on the host. The bus interface still needs a real
hardware timing check after the buffer and qualified strobe are added.
