# C68 BIOS trial ROM

This 8 KiB ROM at `$E000–$FFFF` prints `Starting OS...` after the power-on
banner, with about two seconds across the three dots to press any key for the
monitor. With no key, it cold boots FLEX from SRAM page zero. The selecting
key is consumed. The key window remains open briefly after the third dot.
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
`$9B40–$9B65`, an input buffer at `$9C00–$9CFF`, and its own stack above
FLEX. It prints `(Interrupt)` immediately before the first prompt. Enter `R`
to return through the saved frame and continue the interrupted
program. A second NMI while the monitor is open leaves that frame intact.
Reset, FLEX's `MON` command, or `F` discards the saved frame. The monitor
offers `H`/`?` for help, `F` to boot FLEX again, hexadecimal addresses to
examine memory, `address: bytes` to write hex bytes, `: bytes` to continue at
the next address, and `addressG` to run code. A program reached through `G`
returns to the monitor with `RTS`; reset or NMI also enters the monitor.
An empty `address:` sets the continuation address without writing a byte.
`addressU` enters binary upload mode at that address (for example, `C000U`).
Range dumps show 16 bytes per row with
an ASCII column. The high bit is ignored; controls and DEL appear as spaces.
FLEX's `MON` command goes through the reset vector and enters the warm monitor;
it does not create a resumable NMI frame.

## Binary upload

Start the monitor, then run the host tool from `src`. For example, with the
emulator's TCP console on port 6800:

```sh
python3 hw/roms/c68bios/tools/upload.py --tcp 127.0.0.1:6800 \
  --address 0xC000 --set 0xE002=7 image.bin
```

For a physical serial link, use `--serial /dev/tty... --baud 9600` instead of
`--tcp`. Serial mode needs `pyserial`. The monitor must already be waiting at its
prompt. The tool sends `addressU` itself, and leaves the monitor at a prompt
after the upload. `--set ADDRESS=BYTE` may be repeated to write registers in
the given order before the image. The image must fit before `$FFFF` and must
not overlap the monitor's `$9B40–$9B65` scratch RAM or `$9C00–$9CFF` staging
buffer.

To fill both 512 KiB SRAM disks from the 1 MiB FLEX image, use the SRAM image
mode. It selects each pair of 4 KiB pages through `$E002/$E003`, writes the
first page at `$C000` and the second at `$D000`, and repeats for all 128 pairs:

```sh
python3 hw/roms/c68bios/tools/upload.py --tcp 127.0.0.1:6800 \
  --sram-image os/flex2/build/flex2.dsk
```

The same mode works over serial. To resume at pair 37, add `--start-pair 37`;
`--pairs 1` limits the run to one pair. Every block receives a CRC
acknowledgement before the next block is sent. The current protocol does not
read SRAM back for comparison, so completion confirms transfer acceptance,
not a separate memory readback.

In upload mode, all values below are raw bytes. The monitor sends `K` after
entering the mode and after each successful command. It sends `C` for a block
CRC failure; the host may retry the same block because no bytes or target
address are changed. `?` denotes an unknown command. There is no echo in
binary mode.

| Command | Request bytes | Effect |
| --- | --- | --- |
| Set address | `A` high low | Set the 16-bit block target. |
| Upload block | `B` count data… crc-high crc-low | Write `count` bytes, then advance the target. Count zero means 256 bytes. |
| Set byte | `W` high low value | Write one byte at an absolute address, without changing the block target. |
| Quit | `Q` | Return to the text monitor. |

The CRC is CRC-16/CCITT-FALSE (polynomial `$1021`, initial `$FFFF`, no
reflection or final xor) over the count byte followed by the block data. The
CRC bytes are sent high first. A block is staged and checked before writing;
the protocol has no timeout or resynchronization marker, so an interrupted
transfer should be restarted by resetting or reentering the monitor.

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
- [x] `addressU` — enter the CRC-checked binary upload procedure.

The [Apple II Reference Manual](https://www.applelogic.org/files/AIIREF.pdf),
chapter 3, documents the address, range, deposit, and continuation syntax.

Run `make -C hw/roms/c68bios test` from `src` to exercise reset → FLEX, NMI →
monitor, `R` → interrupted FLEX, and monitor `F` → FLEX on the assembled ROM
and current disk image.

## Future BIOS services

- [ ] Define BIOS calls for reading the RTC date and time so operating systems
      and applications can request a fresh value without knowing the RTC ports.
- [ ] Investigate the RTC's CMOS RAM and reserve a versioned layout for
      persistent C68 configuration, with defaults when the stored data is
      absent or invalid.
