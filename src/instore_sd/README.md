# Instore direct-bus SD AVR

Firmware for U1 on [`../../Instore/SD.kicad_sch`](../../Instore/SD.kicad_sch).
This is a separate successor to the inactive PIA-based SD daughterboard firmware
in `../sd/`. It retains that project's FAT32 `/FLEX.DSK` storage behavior,
256-byte sectors, status codes and additive payload checksum, but uses
Instore's four 74HCT573 latches and three hardware pending flip-flops. The
current MIKBUG ROM, FLEX driver and emulator speak this direct-register protocol.

The first firmware version supports one existing root-directory `FLEX.DSK`,
exactly 1,048,576 bytes (128 tracks × 32 sectors × 256 bytes). It does not
create or resize the file. Media is mounted once at startup; after card removal
or an I/O fault, reset the AVR before trying another card. A successful WRITE
includes a checked `sync()`. Sector writes are not power-fail atomic.

## Register map

With the Instore slot jumpers set for `$E080`, the SD registers are:

| Address | Read | Write |
| --- | --- | --- |
| `$E080` | Status byte | Command opcode |
| `$E081` | One response byte | One parameter, payload or checksum byte |

The keyboard occupies `$E082/$E083`. The processor board's `/IO_SEL` already
qualifies `$E000–$E0FF`, VMA and Φ2. All bus reads and writes are handled by
external latches; the AVR does not respond within a C68 bus cycle.

Status bits:

| Bit | Name | Meaning |
| --- | --- | --- |
| 0 | RX_SPACE | Firmware expects a command or data byte |
| 1 | TX_VALID | A response byte is staged in U10 |
| 2 | BUSY | A request or response is in progress |
| 3 | ERROR | Current/last response was nonzero, or link recovery occurred |
| 4 | MEDIA_READY | `/FLEX.DSK` mounted successfully |
| 5 | RX_SEQUENCE | Toggles after firmware accepts each command or data write |
| 6 | TX_SEQUENCE | Toggles after firmware handles each data read |
| 7 | Reserved | Zero |

**The sequence bits are required.** RX_SPACE and TX_VALID are firmware-loaded
latch bits, so they can remain stale for a short time after a C68 access. To
send a byte: read status, require RX_SPACE, remember RX_SEQUENCE, write to the
appropriate register, then poll until RX_SEQUENCE changes. Do not send another
byte before that change. To receive a byte: require TX_VALID, remember
TX_SEQUENCE, read `$E081` once, then poll until TX_SEQUENCE changes before
reading the next byte. The byte and other status fields are staged before the
sequence change. Reading status never acknowledges a byte. These one-bit
sequence fields acknowledge one bus access; they are not command IDs or
idempotency tokens. Give each poll a timeout. If a WRITE times out after its
last checksum byte, the host cannot infer whether the SD sync completed; it
must inspect status and choose explicitly whether to retry the sector write.

After reset, wait for a valid status with RX_SPACE before the first command.
During AVR reset or early startup the external 573 status latch has no reset
input and its output may be undefined. A timeout/retry is required for startup
and mid-operation AVR resets. The board can be strengthened by gating the two
C68 read output-enables with AVR readiness, but this firmware does not depend
on that for protocol recovery.

## Commands

Write one opcode to `$E080`. READ and WRITE then take track and one-based
sector number as data writes. WRITE also takes 256 payload bytes and a 16-bit
unsigned-byte additive sum, high byte then low byte. There are no `A5 5A`
synchronization bytes: the command register frames a request. Every command
returns at least one response byte through `$E081`.

| Opcode | Command | Data writes | Response reads |
| --- | --- | --- | --- |
| `$00` | INFO | None | `00 03 80 20 00 01`: OK, version 3, 128 tracks, 32 sectors/track, 256-byte size little-endian |
| `$01` | STATUS | None | Storage status code |
| `$10` | READ | Track, sector | Status; if OK, 256 bytes and checksum high/low |
| `$11` | WRITE | Track, sector, 256 bytes, checksum high/low | Status after checked card sync |
| `$12` | SYNC | None | Status after checked card sync |

Track is 0–127; sector is 1–32. A bad WRITE address still consumes the payload
and checksum before returning BAD_ADDRESS, without writing the card. The status
codes match [the legacy bridge table](../sd/PROTOCOL.md#requests-and-responses).
A partial request or unconsumed response times out after two seconds and
returns to command mode with ERROR set. A new command clears ERROR.

## AVR wiring and latch ownership

| U1 pins | Use |
| --- | --- |
| PD0–PD7 | Shared latch-side byte bus; inputs while U5/U9 output, outputs while U8/U10 load |
| PB2–PB5 | SD CS, MOSI, MISO, SCK |
| PB6 | C68 R/W input, currently unused by firmware |
| PB7 | U17 `/OE`; high during AVR reset, low after safe 595 state is loaded |
| PC0–PC2 | Command-write, data-write and data-read pending Q inputs |
| PC3–PC5 | U17 serial data, shift clock and storage clock outputs |
| U17 QH | Active-low activity LED: on when idle, off during SD read/write/sync and for 50 ms afterward |

U5 and U9 capture C68 writes. U8 and U10 hold status and response bytes for
C68 reads. U17 selects only one incoming latch at a time, clears each pending
flip-flop after service, and pulses output-latch load. The AVR returns PD0–PD7
to inputs after every output load. The output latches retain their bytes across
SD card delays. The default 595 controls are chosen so resistor pull-ups keep
incoming latch outputs disabled while the AVR resets.

## Build and verification

From `src/instore_sd`, run `make check` to run the direct-register protocol test
and compile the AVR firmware. The build uses Arduino CLI, the Arduino AVR core
and Arduino SD library. It only builds; it does not flash a chip or set fuses.
Use the internal 8 MHz oscillator fuses in `fuses.conf`, with CKDIV8, RESET and
ISP configured as documented there. Program a plain firmware HEX, without an
Arduino bootloader. U1 is socketed; the Instore schematic has no dedicated ISP
header. Verify the installed microSD adapter's SPI voltage behavior before
powering a card. Hardware latch timing, pending flags, reset/startup behavior,
byte order and full-sector read/write still need bench testing.
