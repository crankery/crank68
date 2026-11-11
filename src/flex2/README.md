# C68 FLEX 2

`make` builds a C68 version of FLEX, packages `FLEX2.SYS`, `MSBASIC.CMD`, and historical utilities,
and constructs a linked, formatted **1,048,576-byte SRAM image containing two 512 KiB disks** at
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
| `build/Z68.CMD` | V3 story interpreter, load/entry `$0300`; source in `../z68` |
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

The image contains **two SRAM drives, each 128 tracks × 16 sectors × 256 bytes**.
Each track is one 4 KiB SRAM page. Both disks share the same 1 MiB image;
the emulator still takes a single `--sram-image` argument.

| Drive | Label | Contents | Files | Free sectors |
| --- | --- | --- | --- | --- |
| 0 | C68SYS | FLEX, Z68, utilities and BASIC interpreters/tools | 68 | 1616 |
| 1 | C68DATA | BASIC games, local stories and user files | 40 | 569 |

- Physical sector offset: `((drive * 128 + track) * 16 + sector - 1) * 256`.
- SRAM drive numbers are 0–1, tracks are 0–127, and sectors are 1–16.
- Each drive's track 0 reserves sectors 1–4 and links directory sectors 5–16.
  Sector 3 contains that drive's system information record. Each drive has its
  own file/free chains, with track numbers relative to the drive.
- Drive 0 sector 1 contains the bootloader; offsets 5 and 6 hold `FLEX2.SYS`'s
  starting track and sector, following `6800Flex/LINK.ASM`'s convention.
- File placement and geometry are described in `tools/disk_layout.py`;
  the SRAM backend implements this fixed two-drive layout.

At the FLEX prompt, `CAT` catalogs drive 0. Use `CAT 1` for the SRAM data drive
and `CAT 2` for the 1 MiB SD volume (updated MIKBUG ROM and AVR bridge required).
Command and filename lookup accepts lowercase at the FLEX prompt, including
`cat 1` and `z68 1.zork1.dat`. The input line retains its typed case for
programs to inspect.
At the prompt, both Backspace and DEL erase the preceding character on a
VT100-style terminal.
Drive 3 remains unavailable. FLEX starts with system and working drives both set to 0;
use a drive prefix to run a command from another disk:

```text
0.XBASIC
```

Then, inside XBASIC:

```text
LOAD "1.CRAPS"
RUN
```

Use `SAVE "1.MYPROG"` and `LOAD "1.MYPROG"` for your files on drive 1.
Build with `make DRIVE_LAYOUT=sd-first` to map SD to FLEX drive 0 and the two
SRAM volumes to drives 1 and 2. `make test-sd DRIVE_LAYOUT=sd-first` tests this
mapping through actual 6800 sector and FMS calls. The `F` monitor boot still
starts from SRAM; SD boot remains ahead.
This layout replaces the former four-drive format; refresh your emulator's
working copy from the new build after exiting any running emulator.

BIOS handoff (not yet added to the sibling BIOS project):

1. Initialize the first ACIA at `$E010/$E011` for polling, with interrupts off.
2. Select SRAM page zero through `$E002`.
3. Copy its first 256 bytes from `$C000` to `$0100`.
4. Jump to `$0100`.

The 162-byte bootloader establishes a stack at `$9FFF`, follows the linked
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

### Load the SRAM disk through MIKBUG

`tools/load_ramdisk.py` sends `build/flex2.dsk` to a running MIKBUG monitor over
the serial console. Install `pyserial` on the host and close any terminal
program using the port first:

```sh
python3 -m pip install pyserial
make verify-image
python3 tools/load_ramdisk.py /dev/tty.usbserial-XXXX
```

Run this from `src/flex2`, with the monitor at its `*` prompt. The script
uses 9600 baud, eight data bits, no parity, and two stop bits by default;
set `--baud` to match your serial adapter and monitor clock. It selects
adjacent 4 KiB SRAM pages with MIKBUG `M` writes to `$E002` and `$E003`,
then sends S1 records for `$C000–$DFFF` through `L`. It repeats this for
all 128 page pairs. MIKBUG may print `?` after an `M` write because its
readback check cannot verify a write-only latch; the write has already
happened. By default, the script uses MIKBUG `P` to read back and compare
each 8 KiB pair before proceeding. After success, reconnect the terminal
and type `F` to boot FLEX.

The Video board's `VRAM/~BANK` bit resets low, leaving banked SRAM selected
for this loader and for FLEX boot. To retry from a verified page pair, use
`--start-pair N`; `--pairs 1` limits a run to one pair. `--no-verify` skips
readback, and `--record-gap` adds time between S1 records if the monitor
needs it. `--skip-free-payload` follows each drive's FLEX free-sector chain
and sends only the two next-sector link bytes in each free sector. This
roughly halves the upload for the initial image. Readback still covers each
8 KiB pair, but comparison ignores the omitted payload bytes, so it does
not reduce verification time. The resulting SRAM disk has valid free chains;
its free-sector payloads retain whatever was already in SRAM. Use the
default full load when an exact byte-for-byte image is needed. Loading
overwrites the current 1 MiB SRAM disk image.

For a sparse load:

```sh
python3 tools/load_ramdisk.py /dev/tty.usbserial-XXXX --skip-free-payload
```

For example, from this directory:

```sh
make rebuild-image
cp build/flex2.dsk build/session.dsk
../emu/build/bin/emu --load ../roms/mikbug2/mikbug2_trim.bin@E100 --sram-image build/session.dsk
```

Only refresh `session.dsk` when you want to discard changes from that session.
No emulator startup/reset-vector integration is supplied here.

## Removable SD media

Drive 2 dispatches through `platform/sdcard.asm` to the SD transport in the
updated MIKBUG ROM. `make` builds `../roms/mikbug2/mikbug2.rom` alongside FLEX;
install that ROM as well as the new FLEX system image. Earlier ROMs are detected
and drive 2 reports unavailable. Drives 0/1 continue to use SRAM.

The AVR uses one 1 MiB FAT32 file, FLEX.DSK, with 128 tracks × 32 sectors.
Prepare it using the [SD project's image converter](../sd/README.md).
`make test-sd` tests the real 6800 driver and FMS file operations against the
AVR protocol engine through a PIA fixture. This is not the interactive emulator
SD device; hardware handshakes still need bench tests. The ROM's clock-dependent
timeout setting is documented in [the ROM API](../roms/mikbug2/README.md#sd-bridge-rom-api).

[REMOVABLE.md](REMOVABLE.md) records the mapping and remaining boot/media-change
work. The monitor's F command still boots SRAM; an SD-aware first-sector loader
and boot-drive handoff are future work.

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
(0 or 128); sector access adds a validated track in the range 0–127.
Drive 2 dispatches to the ROM SD bridge; other drive numbers are rejected.
Ready checks preserve the selected drive, including when checking the other backend.
The C000 window belongs to the disk driver; it does not restore its prior page.

The C68 extension at `$BFF8–$BFF9` holds a wrapping 16-bit input-poll counter.
Each iteration of the blocking console-input loop increments it, preserving
FLEX's A/B/X input convention. It is an entropy source, not a wall-clock API;
Z68 combines it with the FLEX date to seed normal random-number mode. Timer
interrupts and the RTC are still unused. The counter is outside application RAM.

The added routines and scratch variables live at `$BF00`, in space freed by
the removed floppy driver. Thin SD ROM adapters occupy `$A980..$A9FF`, after
the complete startup FCB. The ROM transport reserves 18 bytes at `$9B00..$9B11`.
This leaves `$A100` available for utility commands. The reference FLEX user-memory limit remains `$7FFF`.
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

## Identifying the loaded image

Run `LIST 0.BUILD.TXT` in FLEX to see the image packaging time in UTC, source
revision (marked modified for local changes), content ID and Z68 binary hash.
The matching host file is `build/BUILD.TXT`; `build/image.json` also records the
metadata. The stamp is regenerated when the image is packaged, including
`make rebuild-image`. `SOURCE_DATE_EPOCH` can supply a fixed UTC timestamp for
reproducible packaging. The content ID covers packaged file contents and the
boot sector, excluding the stamp itself.

## Z68 command

The build assembles `../z68` and installs `Z68.CMD` on drive 0. Run
`Z68 1.ZORK1.DAT` to inspect and load the writable region of a raw Version 3 story through
FLEX file I/O. The `.DAT` extension is the default. `Z68 1.ZORK1.DAT RUN` executes its title, opening room description and first
`>` prompt, where it reads one console line with echo and backspace. It then
fills the story text/parse buffers, and resumes the game. `OPEN MAILBOX` and
`READ LEAFLET` work in Zork; Deadline accepts `LOOK`. Use the game’s `QUIT`
command to return to FLEX. Save/restore remains future work.
The builder imports local `.DAT`/`.z3` files from `../z68/stories` to drive 1
as uppercase `NAME.DAT` files, preserving raw bytes and adding only FLEX sector
padding. Only V3 files with valid FLEX names are accepted. The folder can be
absent or empty. No stories are downloaded. Adding, removing, or editing files
in that folder updates the build dependencies. With the current local
`ZORK1.DAT` and `deadline.z3`, drive 1 has 40 files and 569 free sectors, including acceptance fixtures.

For an 80×24 VT100-compatible terminal, `Z68 1.ZORK1.DAT RUN VT100` adds a
reverse-video status bar on row 1, with the room and score/moves or game clock.
Story output scrolls in rows 2–24. Z68 restores full-screen scrolling on return
to FLEX. Plain `RUN` keeps the escape-free console output. Both modes wrap story
text at word boundaries to 80 columns, preserving explicit paragraph breaks.

Z68 loads at `$0300`, uses its own FCB and header buffer, reserves a 512-byte
6800 stack below the lower of FLEX `MEMEND` and `$7FFF`, plus 2,048 bytes for
Z-stack/call frames, 1,042 bytes for a sector index and 504 bytes for a
story cache, and restores FLEX's incoming stack on return. Packaging verifies that its code/data fit below `$7E00`.
The story-memory budget excludes code/data and all reservations. Packed text
can now be inspected with an optional hex byte address (or `P` plus a packed
address); without an address it prints three object-name samples. Static reads
use a lazy file-sector index and cache. Use `RUN` to execute the story. See `../z68/README.md`
for details. `Z68_SRC_DIR` and `VASM_STD_BIN` can override its source directory
and assembler.

## MSBASIC command

At FLEX's `+++` prompt, type `0.MSBASIC`. For a simple startup, accept the default
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
verified in the emulator. Start it with `0.XBASIC` at the FLEX prompt:

```text
10 PRINT 123*100+45
SAVE "1.MYPROG"
NEW
LOAD "1.MYPROG"
RUN
```

Game files are preserved as supplied. CRAPS startup in XBASIC is tested;
the rest of the game collection has not been individually tested.

The generated CAT command converts ASCII drive digits by subtracting `'0'`
instead of masking with 3. This lets the driver reject unavailable or invalid drive numbers
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
  checks, truncated-read recovery, binary header reads from drive 1, default extensions,
  missing/unsupported/invalid stories, repeated invocations, and RAM limits
  below physical RAM using synthetic headers, plus any local story headers.
- Reference assembly bytes against `6800Flex/FLEX21.LST`.
- Every directory/file/free-sector chain, counts, sequence numbers, end links,
  sector ownership, boot link, and decoded load records in the image.
  Imported file payloads are compared with their expected source payloads,
  including the documented CAT adaptation.
- Execution of the linked boot sector using the sibling emulator's real 6800 CPU
  with a small SRAM/ACIA test bus, starting without a preloaded FLEX binary.
- XBASIC loading from drive 0, program SAVE/LOAD and CRAPS loading
  from drive 1 followed by execution through its opening prompt.
- CAT on both SRAM drives and rejection of unavailable drives, then MSBASIC loading from drive 0 and `PRINT 2+2`.
- Simultaneous identically named files with different contents on both SRAM drives:
  creation, 1,400-byte binary write/read, deletion, and free-count recovery.
- SRAM read/write at each drive's track 127, sector 16 (including physical page
  255), rejection of sectors 0/17, tracks 128/255, and unavailable drives 2/3/4/255.
- Ready checks do not change the selected drive.
- Structural validation of the disk after those filesystem operations.

The CPU test builds into this directory; it does not modify the sibling emulator.
These are emulator checks, not a physical-hardware boot test.


`make clean` removes generated build files.

CZECH V3 is compiled locally using vendored Inform 6.44 source and installed as
`1.CZECH.DAT`. `make acceptance` runs six bootstrap gates, the full V3 suite
(349 automatic passes, zero failures; 19 visual print checks), and the local
Zork startup when present. Results are recorded in `build/acceptance.json`.
`make czech` enforces the automatic conformance count. `make zork` runs the
local story with a short instruction trace and asserts the first prompt.
See `../z68/README.md` for commands, provenance and the distinction between
bootstrap tests and conformance checks.
