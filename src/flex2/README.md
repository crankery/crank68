# C68 FLEX 2

`make` builds a C68 version of FLEX, packages `FLEX2.SYS`, `MSBASIC.CMD`, and historical utilities,
and constructs a linked, formatted **1,048,576-byte SRAM image containing four 256 KiB disks** at
`build/flex2.dsk`. The downloaded sources remain unchanged.

Uses `../tools/bin/vasm6800_oldstyle`, as in `../roms/basic680`.
BASIC is built from `../roms/basic680/c68basic.s`; no sibling project files
are modified. `VASM_BIN`, `BASIC_SRC`, `PYTHON`, and `CXX` can be overridden.

```sh
make
make test
```

## Build outputs

| File | Purpose |
| --- | --- |
| `build/flex2.dsk` | Complete SRAM disk image, ready to preload into banked SRAM |
| `build/FLEX2.SYS` | FLEX binary load records, entry `$AD00` |
| `build/Z68.CMD` | V3 story memory loader, load/entry `$0300`; source in `../z68` |
| `build/MSBASIC.CMD` | BASIC binary load records, load/entry `$0000` |
| `build/boot.bin` | Boot code assembled for `$0100`; the image contains its linked copy |
| `build/image.json` | Geometry, file locations, sector counts, free-space count |
| `build/c68flex.asm`, `.bin`, `.lst` | Platform source, flat binary based at `$A100`, listing |
| `build/msbasic.asm`, `.bin`, `.lst` | Adapted BASIC source and assembly output |
| `build/flex21.asm`, `.bin`, `.lst` | Syntax-only reference build |

`FLEX2.SYS` and `.CMD` files use FLEX's binary record format, not flat memory
images: `$02`, two-byte big-endian address, one-byte length, data; and `$16`
followed by a two-byte entry address. Sector padding is zero-filled.

The reference build still matches **all 5,230 emitted bytes** in
`6800Flex/FLEX21.LST`; its 1,091 gap bytes are excluded. Compatibility changes
are made by `tools/prepare-flex21.py`. `tools/prepare-c68.py` then applies the
hardware changes separately. The unused `DTEMP5 EQU $` symbol differs from
the original listing's zero value; this does not affect emitted bytes.

## Disk layout and boot contract

The image contains **four drives, each 64 tracks × 16 sectors × 256 bytes**.
Each track is one 4 KiB SRAM page. All four disks share the same 1 MiB image;
the emulator still takes a single `--sram-image` argument.

| Drive | Label | Contents | Files | Free sectors |
| --- | --- | --- | --- | --- |
| 0 | C68SYS | FLEX, Z68, and utilities | 61 | 801 |
| 1 | C68BASIC | BASIC interpreters, renumbering tools, CONVERT.BAS | 6 | 827 |
| 2 | C68GAMES | BASIC games | 34 | 507 |
| 3 | C68FILES | Your files and local stories | varies | varies |

- Physical sector offset: `((drive * 64 + track) * 16 + sector - 1) * 256`.
- Drive numbers are 0–3, tracks are 0–63, and sectors are 1–16.
- Each drive's track 0 reserves sectors 1–4 and links directory sectors 5–16.
  Sector 3 contains that drive's system information record. Each drive has its
  own file/free chains, with track numbers relative to the drive.
- Drive 0 sector 1 contains the bootloader; offsets 5 and 6 hold `FLEX2.SYS`'s
  starting track and sector, following `6800Flex/LINK.ASM`'s convention.
- File placement and geometry are described in `tools/disk_layout.py`;
  the driver currently implements this fixed four-drive layout.

At the FLEX prompt, `CAT` catalogs drive 0. Use `CAT 1`, `CAT 2`, or `CAT 3`
for the other drives. FLEX starts with system and working drives both set to 0;
use a drive prefix to run a command from another disk:

```text
1.XBASIC
```

Then, inside XBASIC:

```text
LOAD "2.CRAPS"
RUN
```

Use `SAVE "3.MYPROG"` and `LOAD "3.MYPROG"` for your files on drive 3.
This layout replaces the former single-drive format; refresh your emulator's
working copy from the new build after exiting any running emulator.

BIOS handoff (not yet added to the sibling BIOS project):

1. Initialize the first ACIA at `$E010/$E011` for polling, with interrupts off.
2. Select SRAM page zero through `$E002`.
3. Copy its first 256 bytes from `$C000` to `$0100`.
4. Jump to `$0100`.

The 158-byte bootloader establishes a stack at `$9FFF`, follows the linked
system-file sectors directly through SRAM, interprets load records, and jumps
to `$AD00`. It makes no ROM calls and needs no directory search. A broken chain
stops in its `BOOTERROR` loop. This loader is specific to the C68 SRAM mapping.

The emulator's `--sram-image` format is the same raw image layout. Use a working
copy for an emulator session: rebuilding the generated disk recreates its
initial contents. The emulator saves its SRAM image on exit; pointing it at
`build/flex2.dsk` can overwrite a newer build with an older running session's
contents. That saved file can be newer than the build inputs, so `make` alone
will not regenerate it. Exit the emulator before refreshing its working copy.
Use `make rebuild-image` to recreate and verify the initial image regardless
of timestamps; this discards any changes made to `build/flex2.dsk`. Back up
wanted files first. A full `make clean` is not needed.
For example, from this directory:

```sh
make rebuild-image
cp build/flex2.dsk build/session.dsk
../emu/build/bin/emu --load ../roms/mikbug2/mikbug2_trim.bin@E100 --sram-image build/session.dsk
```

Only refresh `session.dsk` when you want to discard changes from that session.
No emulator startup/reset-vector integration is supplied here.

## C68 hardware changes

`platform/console.asm` contains local MC6850 polling routines based on the
MIKBUG2 routines. They use the first ACIA at `$E010/$E011`. FLEX character I/O
uses A, preserving B and X. `C68IN` does not echo; the `C68ECHO` wrapper provides
the echo expected by this FLEX version's terminal-input entries. `C68POLL`
returns availability in carry with B clobbered. `MON` jumps through the installed
reset vector at `$FFFE`, without a hard-coded monitor routine address.

`platform/ramdisk.asm` replaces the floppy-controller driver. It uses the
write-only page latch at `$E002` and the `$C000–$CFFF` window. The `$D000` window
and `$E003` latch are untouched. Drive selection stores a base SRAM page
(0, 64, 128, or 192); sector access adds a validated track in the range 0–63.
Drives outside 0–3 are rejected. Ready checks preserve the selected drive.
The C000 window belongs to the disk driver; it does not restore its prior page.

The C68 extension at `$BFF8–$BFF9` holds a wrapping 16-bit input-poll counter.
Each iteration of the blocking console-input loop increments it, preserving
FLEX's A/B/X input convention. It is an entropy source, not a wall-clock API;
Z68 combines it with the FLEX date to seed normal random-number mode. Timer
interrupts and the RTC are still unused. The counter is outside application RAM.

The added routines and scratch variables live at `$BF00`, in space freed by
the removed floppy driver. This leaves `$A100` available for utility commands. The reference FLEX user-memory limit remains `$7FFF`.
The platform preparation also corrects the historical `DRVX6` routine's final
`TBA` to `TAB`, transferring the computed drive-times-six offset into B.
Without this fix, nonzero drives overlap the FMS free-chain caches. The
syntax-only reference assembly remains unchanged.

Timer accesses are disabled and the print scheduler is disabled; background
printing is unsupported. Normal foreground operation uses no timer or IRQs.
The old SWTBUG RAM-vector assignments are not an interrupt interface to MIKBUG2:
this build assumes polling devices with no active interrupt sources. MIKBUG2's
workspace and stack overlap resident FLEX, so returning to the monitor means a
reset, not preserving a resumable monitor/FLEX session.

## Z68 command

The build assembles `../z68` and installs `Z68.CMD` on drive 0. Run
`Z68 3.ZORK1.DAT` to inspect and load the writable region of a raw Version 3 story through
FLEX file I/O. The `.DAT` extension is the default. This milestone fills writable story RAM and reports the full memory layout; explicit `RUN` supports four bring-up operations; save/restore and general
story execution are not implemented.
The builder imports local `.DAT`/`.z3` files from `../z68/stories` to drive 3
as uppercase `NAME.DAT` files, preserving raw bytes and adding only FLEX sector
padding. Only V3 files with valid FLEX names are accepted. The folder can be
absent or empty. No stories are downloaded. Adding, removing, or editing files
in that folder updates the build dependencies. With the current local
`ZORK1.DAT`, drive 3 has five files and 557 free sectors, including acceptance fixtures.

Z68 loads at `$0300`, uses its own FCB and header buffer, reserves a 512-byte
6800 stack below the lower of FLEX `MEMEND` and `$7FFF`, plus 2,048 bytes for
future Z-stack/call frames, 1,042 bytes for a sector index and 504 bytes for a
story cache, and restores FLEX's incoming stack on return. Packaging verifies that its code/data fit below `$7E00`.
The story-memory budget excludes code/data and all reservations. Packed text
can now be inspected with an optional hex byte address (or `P` plus a packed
address); without an address it prints three object-name samples. Static reads
use a lazy file-sector index and cache. Use `RUN` to exercise the limited execution core. See `../z68/README.md`
for details. `Z68_SRC_DIR` and `VASM_STD_BIN` can override its source directory
and assembler.

## MSBASIC command

At FLEX's `+++` prompt, type `1.MSBASIC`. For a simple startup, accept the default
MEMORY SIZE and TERMINAL WIDTH with Return, then answer `N` to the trig-function
question. `PRINT 2+2` prints `4`.

This is the existing MITS/ Microsoft BASIC port, packaged as a FLEX-loadable
command. It retains its own B-register console convention and direct ACIA I/O.
Generated adaptations limit automatic RAM probing and explicit memory-size
answers to `$7FFF`, and strip BASIC's string-marker high bits on output.

This is not yet a FLEX disk-I/O port of BASIC: program SAVE/LOAD through FLEX and
a clean BASIC exit back to FLEX are not implemented. The build imports `ERRORS.SYS` and 23 commands from
`6800Flex/6800FLEX.DSK`, preserving their sector payloads except for CAT's drive-number adaptation:

`CAT`, `LIST`, `COPY`, `TTYSET`, `RENAME`, `DELETE`, `ASN`, `APPEND`, `EDIT`,
`ASMB`, `BUILD`, `P`, `JUMP`, `SAVE`, `PROT`, `EXEC`, `DATE`, `I`, `O`,
`QCHECK`, `VERIFY`, `VERSION`, and `XOUT`.

The build also imports all 35 additional command names from
`6800Flex/6800UTL1.DSK` and `6800Flex/6800UTL2.DSK`, without their `.TXT`
documentation. The original `DATE.CMD` takes precedence over UTL2's duplicate.
These include FIND, WORDS, DUMP, DIR, FREE, REPLACE, FILES, ECHO, CONCAT,
RECOVER, and the memory utilities. Changes to any source disk rebuild the image.

The `.BAS` files from `GAMES_5.DSK` and `MYGAMES.DSK` are included (34
programs), along with `XBASIC.CMD`, `BASIC.CMD`, `RENUMX.CMD`,
`RENUMBER.CMD`, and `CONVERT.BAS` from `XBASIC_1.DSK`. The existing CAT
wins over that disk's duplicate. Other game-disk files and `.TXT` files
are omitted.

Unlike MSBASIC, XBASIC supports program SAVE/LOAD through FLEX; this is
verified in the emulator. Start it with `1.XBASIC` at the FLEX prompt:

```text
10 PRINT 123*100+45
SAVE "3.MYPROG"
NEW
LOAD "3.MYPROG"
RUN
```

Game files are preserved as supplied. CRAPS startup in XBASIC is tested;
the rest of the game collection has not been individually tested.

The generated CAT command converts ASCII drive digits by subtracting `'0'`
instead of masking with 3. This lets the driver reject `CAT 4` through `CAT 9`
rather than silently wrapping them to valid disks. The source disk is unchanged.

The original system images and `SAVE.LOW` are omitted. `LINK` and `NEWDISK`
target the original boot/floppy hardware; `PRINT.CMD` and `PRINT.SYS` require
unsupported printing support, so they are omitted too. Imported utilities
are historical binaries; CAT is exercised in the emulator,
but the full command set has not been individually tested. VERSION expects
the original system file and reports error 21 with this custom system image.

## Verification

`make test` checks:

- All 68 V1–V3 opcode stubs, version gates, reserved slots, dispatch metadata,
  and remaining unimplemented-opcode diagnostics.
- Z68 random-number reference sequences, deterministic negative seeds, normal
  date/poll-timing reseeding, unbiased range reduction and console counter wrap.
- Z68 packed-text decoding, abbreviation restoration, binary escapes, static
  file reads, sector boundaries, and 17-bit addresses using synthetic strings.
- Z68 command loading, writable-story byte comparisons, exact-fit/overflow
  checks, truncated-read recovery, binary header reads from drive 3, default extensions,
  missing/unsupported/invalid stories, repeated invocations, and RAM limits
  below physical RAM using synthetic headers, plus any local story headers.
- Reference assembly bytes against `6800Flex/FLEX21.LST`.
- Every directory/file/free-sector chain, counts, sequence numbers, end links,
  sector ownership, boot link, and decoded load records in the image.
  Imported file payloads are compared with their expected source payloads,
  including the documented CAT adaptation.
- Execution of the linked boot sector using the sibling emulator's real 6800 CPU
  with a small SRAM/ACIA test bus, starting without a preloaded FLEX binary.
- XBASIC loading from drive 1, program SAVE/LOAD on drive 3, and CRAPS loading
  from drive 2 followed by execution through its opening prompt.
- CAT on all four drives, then MSBASIC loading from drive 1 and `PRINT 2+2`.
- Simultaneous identically named files with different contents on all four drives:
  creation, 1,400-byte binary write/read, deletion, and free-count recovery.
- SRAM read/write at each drive's track 63, sector 16 (including physical page
  255), rejection of sectors 0/17, tracks 64/255, and drive 4.
- Ready checks do not change the selected drive.
- Structural validation of the disk after those filesystem operations.

The CPU test builds into this directory; it does not modify the sibling emulator.
These are emulator checks, not a physical-hardware boot test.


`make clean` removes generated build files.

CZECH V3 is compiled locally using vendored Inform 6.44 source and installed as
`3.CZECH.DAT`. `make acceptance` runs six bootstrap gates and records its blocked
state in `build/acceptance.json`; `make czech` is the strict upstream gate and
currently fails at unimplemented `call`. No upstream CZECH checks have passed.
See `../z68/README.md` for commands, provenance and the distinction between
bootstrap tests and conformance checks.
