# MIKBUG2

`make` builds the 8 KiB `mikbug2.rom` image mapped at `$E000–$FFFF`.
The first bytes of the image contain a readable chip ID: monitor name, ROM
version, UTC build date and time, SD ABI version, and sound-board revision.
These physical bytes correspond to `$E000–$E0FF`, where the CPU selects I/O
instead of ROM; inspect them in the HEX/binary file or with an EPROM programmer.
The ID is not a runtime CPU address. Set `ROM_VERSION=...` when building a new
release. `SOURCE_DATE_EPOCH` can fix the build timestamp for reproducible images.

Type `F` or `f` at the monitor prompt to cold boot FLEX 2 from banked SRAM.
Type `?`, `H`, or `h` to list the monitor commands.

Monitor command letters are case insensitive. The EXORTAPE audio cassette command and its PIA tape routines have been
removed. The monitor's `L` and `P` commands remain: they transfer S-records
over the serial terminal connection.
The same handoff is available at the fixed address `$FFC0` (`G FFC0`,
or `JMP $FFC0` from a program). It does not return to its caller.

Preload the raw disk image built by `src/flex2` into banked SRAM first.
The routine masks interrupts, initializes the first ACIA at `$E010/$E011`
for polling, selects SRAM page zero through `$E002`, copies its first
256 bytes to `$0100–$01FF`, then jumps to `$0100`. The sector loader follows
the linked FLEX system file and starts FLEX. No disk validation is performed
by the ROM handoff; it requires a valid bootable image.

Booting clobbers A, X, SP and the sector buffer. FLEX takes over the monitor
workspace and stack. The NMI vector now jumps directly into MIKBUG's handler.
If MIKBUG still owns its workspace, it displays the interrupted registers;
if FLEX has replaced that workspace, NMI reinitializes MIKBUG and abandons
the running FLEX session. `C`, `N`, and `T` require a saved interrupted
context; after a fresh start or a return from FLEX they report
`NO SAVED CONTEXT` and return to the prompt. Existing monitor entry addresses
are preserved.

After building the sibling FLEX project, `make test` uses its generated disk
and the sibling emulator's 6800 CPU to test both reset → `F` → FLEX and the
direct `$FFC0` entry. Each path loads MSBASIC and checks `PRINT 2+2`. The
tests also cover NMI from MIKBUG and from the FLEX prompt, plus `?` and `h`
help output.
Test binaries are temporary; the disk image is read into memory.

## SD bridge ROM API

`sdcard.s` implements the Instore direct-register protocol-v3 transport in
ROM at `$F000`, using `$E080` for command/status and `$E081` for data.
Existing monitor entry addresses and the SRAM boot entry are unchanged.

| Entry | Address | Inputs |
| --- | --- | --- |
| READ | `$F000` | A=track 0–127, B=sector 1–32, X=256-byte buffer |
| WRITE | `$F003` | Same; success requires matching checksum and checked SD sync |
| READY | `$F006` | No input required; X preserved |
| INIT | `$F009` | Wait for a write slot; call once before first use after reset |

`$F00C..$F00E` holds `53 44 03` ("SD", ABI version 3). Callers must check
this signature before calling an entry; the old PIA ROM uses ABI version 2.
READ/WRITE check INFO version/geometry and card status before each sector.
READY checks availability without selecting a FLEX drive. INIT only waits for
an AVR write slot; READY's INFO/STATUS exchange verifies the connection.

All entries return B=0, Z=1, C=0 on success; B nonzero, Z=0, C=1 on failure.
READ checksum errors return B=$08; other failures return B=$10. READ may have
filled the buffer before detecting an invalid checksum; discard it on error.
A and X may be clobbered except READY preserves X. INIT also preserves X.
WRITE does not alter the caller's buffer. VERIFY is not a separate ROM entry:
FLEX retains its successful no-op after a checked, synchronized WRITE.

The transport reserves **18 bytes at `$9B00..$9B11`**, above FLEX's `$7FFF`
application limit. It uses the caller's stack and is not reentrant. Each
command/data write waits for RX_SEQUENCE to change; each data read waits for
TX_SEQUENCE to change. `SD_CPU_MHZ` in `sdcard.s` defaults to 1; set it to the
host clock (1–4 MHz) for the bounded polling loop. Hardware latch timing and
reset/startup behavior still need bench validation. If the AVR is resetting,
a first request may time out; a later READY retries the exchange.

`make -C ../../flex2 test-sd` executes the actual FLEX/ROM driver against a
direct-register fixture connected to the AVR protocol engine. It covers sector
boundaries, checksums, absent/old ROMs, missing media, timeout, drive isolation,
and FMS file create/write/read/delete. The interactive emulator SD device and
booting FLEX from SD are not implemented yet; the ROM API is ready for a
future bootloader to use.
