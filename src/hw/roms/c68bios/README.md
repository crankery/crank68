# C68 BIOS trial ROM

This 8 KiB ROM at `$E000–$FFFF` prints `Starting OS...` after the power-on
banner, with about one second across the three dots to press any key for the
monitor. With no key, it cold boots FLEX from SRAM page zero. The selecting
key is consumed.
Later RESET presses and FLEX's `MON` command enter the monitor directly. A
four-byte signature at `$9B20–$9B23` distinguishes a warm reset while RAM is
retained; a cold power-on normally lacks it. The signature sits above FLEX's `$7FFF`
application limit and beyond the SD transport's `$9B00–$9B11` scratch area.
Before boot, it prints `C68 BIOS v0.01` and `Dave Hamilton 2026`. The monitor's
`H`/`?` help shows a build tag containing the UTC build date and an eight-digit
source hash. NMI prints the banner on a new line when it opens the monitor.
Set `SOURCE_DATE_EPOCH` before building
to choose a reproducible build date.
Cold start and monitor entry select SRAM page zero in both `$C000–$CFFF`
(`$E002`) and `$D000–$DFFF` (`$E003`) windows. FLEX handoff selects both
pages again, then copies the first 256-byte boot sector to `$0100` and jumps
to it, using the same boot contract as MIKBUG2. The handoff is also available
at `$FFC0`.
The raw SRAM image must already contain a bootable FLEX disk.

From `src`, try it with:

```sh
make run-c68bios THROTTLE=1 TCP_PORT=6800
```

`run-c68bios` uses the usual persistent `SRAM_SESSION` setting. Use the default
`sram-first` drive layout: this trial ROM does not yet provide the `$F000` SD
transport API, so FLEX's SD drive is unavailable. It does not replace the
default MIKBUG ROM in `make run` or the packaged system. FLEX keeps using its
own polling console at `$E010/$E011`.
The IO board schematic decodes its two ACIAs and two PIAs at offsets
`$0/$4/$8/$C` within the selected slot. With the board set to slot 1, these
start at `$E010/$E014/$E018/$E01C`. The emulator uses the same layout;
C68 BIOS uses only the first ACIA.

NMI opens the C68 BIOS monitor while preserving the CPU's interrupt frame,
the SRAM page selections, and FLEX's low RAM. The monitor uses scratch RAM at
`$9B40–$9B61`, an input buffer at `$9C00–$9CFF`, and its own stack above
FLEX. It prints `(Interrupt)` immediately before the first prompt. Enter `R`
to return through the saved frame and continue the interrupted
program. A second NMI while the monitor is open leaves that frame intact.
Reset, FLEX's `MON` command, or `F` discards the saved frame. The monitor
offers `H`/`?` for help, `F` to boot FLEX again, hexadecimal addresses to
examine memory, `address: bytes` to write hex bytes, `: bytes` to continue at
the next address, and `addressG` to run code. A program reached through `G`
returns to the monitor with `RTS`; reset or NMI also enters the monitor.
An empty `address:` sets the continuation address without writing a byte.
Range dumps show 16 bytes per row with
an ASCII column. The high bit is ignored; controls and DEL appear as spaces.
FLEX's `MON` command goes through the reset vector and enters the warm monitor;
it does not create a resumable NMI frame.

## Monitor TODO

Use Apple II monitor style input: hexadecimal addresses precede the action.
Accept one to four hex digits for an address and one or two for a byte; omitted
leading zeroes have the usual value. For example, `100: 5` stores `$05` at
`$0100`. Press Return to execute a line. This is a deliberately small command
set, not a full Apple II monitor parser.

Implement examine, deposit, and go first:

- [x] `address` — show the single byte at that address (`F800`).
- [x] `start.end` — show the inclusive byte range (`F800.F807`).
- [x] `address: byte1 byte2 ...` — store bytes at consecutive addresses
      (`100: 86 05 39`).
- [x] `: byte1 byte2 ...` — continue depositing at the next address after
      the previous deposit (`: 01 02`).
- [x] `addressG` — call that address (`100G`); `RTS` returns to the monitor.

Then add the larger monitor features:

- [ ] Interactive byte editor after `address:`; currently it only sets the
      continuation address for a later `: bytes` command.
- [ ] `addressL` — disassemble 6800 instructions from that address (`F800L`);
      decide the listing length and continuation behavior.
- [ ] `addressU` — enter an upload procedure. Design the transfer protocol
      when this is implemented.

The [Apple II Reference Manual](https://www.applelogic.org/files/AIIREF.pdf),
chapter 3, documents the address, range, deposit, and continuation syntax.

Run `make -C hw/roms/c68bios test` from `src` to exercise reset → FLEX, NMI →
monitor, `R` → interrupted FLEX, and monitor `F` → FLEX on the assembled ROM
and current disk image.
