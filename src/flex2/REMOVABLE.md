# Mixed SRAM and removable disks

The buildable AVR project now lives in [../sd](../sd/README.md). Its pin map
matches the actual SD board's **two HCT574 latches**, with both PIA ports and
all four control signals. [Protocol v2](../sd/PROTOCOL.md) is the starting
firmware contract; the earlier single-port/transceiver options below are design
history, not the current board wiring. FLEX drive-2 dispatch and the MIKBUG
ROM transport are now implemented; hardware bring-up and SD boot remain.

## Current implementation

The 1 MiB image now contains two 512 KiB SRAM volumes, each 128 tracks by
16 sectors by 256 bytes. Drive 0 contains the former drives 0 and 1; drive 1
contains the former drives 2 and 3. SRAM page = `drive * 128 + track`.
Drive 2 uses the SD bridge through MIKBUG ROM; drive 3 remains unavailable.
With `DRIVE_LAYOUT=sd-first`, SD becomes drive 0 and SRAM units move to drives
1 and 2. The selected layout is compiled into FLEX and tested by `make test-sd`.
The SD volume is 1 MiB (128×32×256); SRAM volumes remain 512 KiB each.
Install both the rebuilt FLEX image and updated `mikbug2.rom`. An old ROM or
an absent bridge makes drive 2 unavailable, without aliasing an SRAM volume.
`make test-sd` runs the CPU/protocol and FMS integration tests.
The original four-volume generated image was backed up in `build/` before
conversion. This rebuild preserves the factory files, not arbitrary files
from an emulator session image; migrate any separate session image explicitly.

## Runtime dispatch belongs below FMS

FLEX's existing logical drive range is 0–3. Its per-drive FMS state already
supports four logical devices, regardless of the kind of hardware behind them.
Keep that range and the corrected DRVX6 per-drive indexing. The platform driver
accepts the two SRAM devices and SD drive 2.

The physical driver vectors in this build are:

| Entry  | Address | Contract / responsibility                                 |
| ------ | ------- | ------------------------------------------------------------------ |
| READ   | `$BE80` | A=track, B=sector, X=256-byte buffer; dispatch by selected backend |
| WRITE  | `$BE83` | Same registers; dispatch by selected backend                       |
| VERIFY | `$BE86` | Successful no-op; SD WRITE already checks checksum and sync    |
| RESTOR | `$BE89` | X=FCB; select/restore the appropriate device                       |
| DRVSEL | `$BE8C` | X=FCB, drive byte at `3,X`; validate/select and remember backend   |
| CDRRDY | `$BE8F` | X=FCB; check the requested device without changing selection       |
| QDRRDY | `$BE92` | Currently the same ready-check implementation                      |

These jump through the READ1/WRIT1/VER1/REST1/DRVS1/CDRR1 stubs installed by
`tools/prepare-c68.py`. Implement a platform dispatch layer there rather than
teaching Z68, BASIC or the FMS file/sector code about removable media.

Implemented mapping:

| FLEX drive | Backend               | Backend unit                          |
| ---------- | --------------------- | ------------------------------------- |
| 0          | SRAM                  | Base page 0                           |
| 1          | SRAM                  | Base page 128                         |
| 2          | Removable bridge      | First removable volume/image          |
| 3          | Unavailable initially | Future second removable volume/device |

DRVSEL changes the selected backend only after successful readiness validation.
READ/WRITE dispatch using that remembered selection; readiness checks preserve
it. SRAM retains its own track/sector bounds independently of the SD geometry.
The SD adapter checks the ROM signature before calling its fixed entry points.

The [ROM API](../roms/mikbug2/README.md#sd-bridge-rom-api) exposes READ, WRITE,
READY and INIT at `$F000..$F009`. The transport is in ROM and needs 18 bytes of
scratch at `$9B00..$9B11`, outside FLEX application RAM. Thin adapters fit at
`$A980..$A9FF`, beyond the full startup FCB. SRAM/console code remains at `$BF00`.
Both backends return B=0/Z=1/C=0 on success and B!=0/Z=0/C=1 on failure.
SD checksum errors return B=$08, other bridge errors B=$10. Polling/settling
loops have a configurable host-clock setting and need physical timing checks.

The following interface alternatives are retained as design history. The
actual board uses two unidirectional PIA ports and HCT574 latches, as described
in the protocol and pinout above.

## Intended hardware

The intended device is an SD card behind an AVR, connected to port A of the
first PIA on the C68 I/O board: PA0–PA7 plus CA1 and CA2. Exact timing and
command framing are not fixed yet; this is a proposed protocol shape.

- PA0–PA7: bidirectional eight-bit data bus, with one side driving at a time.
- CA2: C68-to-AVR request/strobe, under software control initially.
- CA1: AVR-to-C68 acknowledgment/data-ready event; poll its latched PIA flag
  initially rather than requiring interrupts.

The compatible [W65C21 datasheet](https://www.wdc65xx.com/wdc/documentation/w65c21.pdf)
documents CA1 as an input, manual output control for CA2, and an input-oriented
hardware handshake on port A. Manual CA2 control makes a symmetric byte protocol
possible without assuming port A's automatic strobes also handle writes.
The flag-clearing port reads must be part of the eventual byte-transfer design.

Use byte acknowledgments rather than fixed delays: the AVR/SD may take time
between bytes or while committing a sector. Commands can be small packets such
as READ(track,sector), WRITE(track,sector), and STATUS, with an explicit response
status. READ transfers 256 payload bytes AVR-to-C68; WRITE transfers 256 bytes
C68-to-AVR and returns completion only after storage succeeds. The AVR can map
track/sector to a logical sector and handle the SD card's 512-byte block packing.

Define a bus-turnaround phase before changing PIA/AVR directions. In particular,
after the final READ byte the AVR must know the C68 has consumed it before it
releases the bus; the C68 must receive confirmation of release before driving
its next command. Commands/status bytes and payload use the same eight wires.
Timeout/reset recovery must return both ends to a known idle ownership state.

## AVR and SD-file plan

The chosen controller is an ATmega328P-PU at 5 V using its internal 8 MHz
oscillator, with SPI SD access and 3.3 V level shifting at the card. The SD card
is FAT32, and the AVR opens only `/FLEX.DSK`; other card files are ignored.
The Arduino SD library owns FAT and card-block buffering. Keep the disk file
open and fixed-size rather than creating/extending it during sector writes.
For the SD 128×32 geometry, FLEX.DSK is one 1,048,576-byte raw FLEX volume,
not the entire two-volume SRAM image. File offset is:

```cpp
uint32_t offset = (uint32_t(track) * 32 + (sector - 1)) * 256;
```

Validate track, sector, file size and seek/read/write results. A single 256-byte
staging buffer is sufficient for the PIA payload; the library handles partial
512-byte card-block accesses. The classic SD library has its own 512-byte cache,
so payload plus card cache starts at 768 bytes before objects, stack and other
buffers. Measure SRAM use with the chosen core/library; keep diagnostic strings
in flash and avoid unnecessary dynamic strings.

Open an existing image with `O_READ | O_WRITE` (`O_RDWR`), **not FILE_WRITE**:
Arduino SD defines FILE_WRITE with O_APPEND, which moves each write to EOF even
after a seek. Check a complete 256-byte write and flush/sync before acknowledging
completion. Standard File::flush() returns void and discards the lower-level
sync result; reliable final write-error reporting may justify using the
underlying SdFile API. Clock fuses/prescaler and F_CPU must agree on 8 MHz.

Sources: [Arduino SD open flags](https://github.com/arduino-libraries/SD/blob/master/src/SD.h),
[SD cache](https://github.com/arduino-libraries/SD/blob/master/src/utility/SdFat.h),
[File flush](https://github.com/arduino-libraries/SD/blob/master/src/File.cpp),
and [ATmega328P datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf).

## One PIA port versus two

One bidirectional eight-bit bus needs 8 data + 2 handshake + 4 SPI signals =
14 AVR GPIO. Direction changes happen between command/data/status bursts, not
between every payload byte. For direct wiring this leaves
pins for debugging and recovery; the buffered two-port option below is another
compact-pin-count candidate.

Two fixed-direction eight-bit buses simplify ownership, but need 16 data +
2 shared handshake + 4 SPI signals = 22 GPIO. That exactly consumes the
non-reset GPIO available with the internal oscillator, including PB6/PB7 and
the UART pins. PB6/PB7 also need deliberate firmware/core pin handling; standard
Uno pin numbering does not expose them. Giving each PIA port its own handshake
pair would require 24 GPIO and does not fit this pin budget.

A possible two-bus allocation (a proposal, not a selected schematic):

| AVR pins             | Proposed role                   |
| -------------------- | ------------------------------- |
| PD0–PD7              | Eight data bits from C68        |
| PC0–PC5 plus PB6/PB7 | Eight data bits to C68          |
| PB0/PB1              | Shared request/acknowledgment   |
| PB2–PB5              | SD chip select and hardware SPI |

If selecting two buses, choose which PIA control port receives ACK deliberately:
its flag is cleared by reading its associated data port. The two data directions
can share a handshake pair, but that detail still needs a defined state machine.

## One transceiver with two fixed-direction PIA ports

A useful alternative needs only one 74HCT245 (or a suitable unidirectional
three-state buffer), because PIA port B is already an input:

```text
PIA A (outputs) -- [245, fixed A-to-B] --+-- AVR shared eight-bit data bus
                                       +-- PIA B (inputs)
```

The AVR controls the buffer's active-low output enable; strap DIR for PIA-A to
AVR. For a C68-to-AVR byte, the AVR data pins are inputs and the buffer is
enabled. For an AVR-to-C68 byte, disable the buffer before the AVR drives the
shared bus, and read PIA B. PIA A can remain configured as outputs throughout;
its drivers are isolated from the shared bus when the buffer is disabled.
The AVR still switches its own data direction between bursts. Enable sequencing
must disable the buffer before AVR output mode, and return the AVR to input
mode before enabling the buffer. Pull /OE high so reset defaults to isolation.

This takes 8 data + 1 enable + 2 shared handshake + 4 SPI = **15 AVR GPIO**,
leaving seven non-reset GPIO on the internally clocked 328P. It uses one more
pin than the single-PIA-port design but avoids changing PIA direction. A second
transceiver is optional for buffering/isolation of the return path, not required
for sharing the AVR pins. Handshake ownership/flag clearing still needs the
same explicit protocol design as above.

The [SN74HCT245 datasheet](https://www.ti.com/lit/ds/symlink/sn74hct245.pdf)
describes its fixed-direction selection, three-state output enable and
TTL-compatible inputs. HCT is a sensible candidate on the 5 V legacy-PIA side;
this is separate from the SD card's 3.3 V level shifting. Pin allocation and the
exact PIA part's electrical requirements must be checked before a schematic is
finalized. This makes the two-port option practical on the 328P without spending
all its GPIO; the wiring choice remains open.

## Removable transport still to define

- Expose a reliable read/write of one **256-byte FLEX sector**, plus readiness
  and write-protect/media-change information. The Arduino/USB adapter may hide
  its own filesystem and expose a raw `.dsk` image; FLEX need not understand FAT.
- Define commands, addresses, handshake, completion/error responses and finite
  timeouts for the PIA/bridge protocol before writing its 6800 backend.
- If the underlying media uses 512-byte blocks, pack two FLEX sectors per block
  and preserve the other half on a write (preferably inside the bridge).
- Put backend code in protected OS/ROM storage. The existing `$BF00` console and
  disk routines leave little spare room, and `$BFF8` is the entropy counter.
  `$A100` padding is used by utilities; it is not safe driver storage by default.
- Handle media changes deliberately. Open FCBs and FLEX's cached directory/free
  chain state refer to the old volume; reject unsafe swaps or close/invalidate
  the affected state before accepting a replacement disk.
- Test interleaved files on drives 0/1/2, the same filename on different devices,
  boundary sectors, absent/protected media, transport timeouts and failed drive
  selection. Continue using the SRAM isolation/invalid-address tests as a base.

## Booting either type

The current BIOS contract copies SRAM drive 0's track 0 sector 1 to `$0100`
and jumps there. `platform/boot.asm` follows FLEX2.SYS's linked sectors by
writing `$E002` and reading `$C000`. It has no FMS or removable-driver services
available yet; changing only the installed FLEX vectors cannot make it boot
from removable media. It currently boots only SRAM drive 0.

Two reasonable designs:

1. A different first-sector loader for each medium. The monitor/BIOS selects
   the medium and loads its bootstrap; that bootstrap reads FLEX2.SYS using its
   own SRAM or bridge routine. The SRAM loader remains usable as a fallback.
2. A common ROM block-read entry, with a selected boot-device ID. The BIOS and
   first-sector loader use that entry for either medium. This avoids fitting a
   full bridge protocol into a 256-byte boot sector and can share transport
   code with the running FLEX backend.

Both approaches need a defined boot-device handoff. On entry to FLEX cold start,
initialize the platform selector and the system/working drive bytes (SASN at
`$AC0B`, WASN at `$AC0C`) to the logical boot drive, e.g. 2, before automatic
command loading. The current image initializes both to 0. A small cold-start
stub can consume the BIOS handoff and then enter the existing startup path.
Do not rely on the SRAM driver's initially zero C68BASE to represent a
removable boot. Preserve the boot drive across resets/warm starts as intended.

The removable volume must contain a compatible FLEX2.SYS, boot link, SIR and
directory/free chains, plus the desired system commands. The easiest initial
SD format is 128×32; SRAM retains its 128×16 logical geometry. A mixed driver must support
ordinary cross-device file operations first; then test cold boots from each
medium, followed by command loading and file I/O on both kinds of disk.
