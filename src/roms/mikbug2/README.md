# MIKBUG2

`make` builds the 8 KiB `mikbug2.rom` image mapped at `$E000–$FFFF`.

Type `F` or `f` at the monitor prompt to cold boot FLEX 2 from banked SRAM.

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
workspace and stack; return to MIKBUG through reset. Existing monitor entry
addresses are preserved.

After building the sibling FLEX project, `make test` uses its generated disk
and the sibling emulator's 6800 CPU to test both reset → `F` → FLEX and the
direct `$FFC0` entry. Each path loads MSBASIC and checks `PRINT 2+2`.
Test binaries are temporary; the disk image is read into memory.

## SD bridge ROM API

`sdcard.s` implements the PIA/AVR protocol-v2 transport in ROM at `$F000`.
Existing monitor entry addresses and the SRAM boot entry are unchanged.

| Entry | Address | Inputs |
| --- | --- | --- |
| READ | `$F000` | A=track 0–127, B=sector 1–32, X=256-byte buffer |
| WRITE | `$F003` | Same; success requires matching checksum and checked SD sync |
| READY | `$F006` | No input required; X preserved |
| INIT | `$F009` | Configure PIA 1; call once before first use after reset |

`$F00C..$F00E` holds `53 44 02` ("SD", ABI version 2). Callers must check this
signature before calling an entry; earlier ROMs have no SD services. INIT
waits roughly three seconds for any partial AVR transaction to expire.
READ/WRITE also check INFO version/geometry and card status before each sector.
READY checks availability without selecting a FLEX drive.

All entries return B=0, Z=1, C=0 on success; B nonzero, Z=0, C=1 on failure.
READ checksum errors return B=$08; other failures return B=$10. READ may have
filled the buffer before detecting an invalid checksum; discard it on error.
A and X may be clobbered except READY preserves X. INIT also preserves X.
WRITE does not alter the caller's buffer. VERIFY is not a separate ROM entry:
FLEX retains its successful no-op after a checked, synchronized WRITE.

The transport reserves **18 bytes at `$9B00..$9B11`**, above FLEX's `$7FFF`
application limit. It uses the caller's stack, is not reentrant, and polls
rather than enabling PIA interrupts. PIA 1 is `$E020..$E023`: PA outputs,
PB inputs, manual CA2/CB2 strobes. `SD_CPU_MHZ` in `sdcard.s` defaults to 1;
set it to the host clock (1–4 MHz) for the timeout/settling loops. The strobe
low interval accommodates up to 4 MHz. Hardware timing needs bench validation.
A timeout forces reinitialization/settling on the next operation.

`make -C ../../flex2 test-sd` executes the actual FLEX/ROM driver against a
PIA test fixture connected to the AVR protocol engine. It covers sector
boundaries, checksums, absent/old ROMs, missing media, timeout, drive isolation,
and FMS file create/write/read/delete. The interactive emulator SD device and
booting FLEX from SD are not implemented yet; the ROM API is ready for a
future bootloader to use.
