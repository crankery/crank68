# C68 SD bridge firmware

AVR project for the daughterboard in `../../SD`, connected to IO board PIA 1
through J2. Target: **ATmega328P-PU, 5 V, internal 8 MHz**, with two HCT574
latches and a level-shifted SPI SD card. This implements the proposed byte/sector
protocol; it has been compiled and host-tested, **not tested on assembled hardware**.
FLEX uses the transport in MIKBUG ROM as drive 2 by default, or drive 0 with
`DRIVE_LAYOUT=sd-first`; see
[the ROM API](../roms/mikbug2/README.md#sd-bridge-rom-api). Building this AVR
project alone does not update the host ROM or FLEX image. Removable boot
support remains future work.

## Build and test

```sh
cd src/sd                 # from the repository root
make check               # host tests, read-only board audit, AVR compilation
make firmware            # compile only
make test                # no AVR tools or card needed
```

Use the plain `build/sd_bridge.ino.hex` (or `.elf`), not an Arduino-generated
`with_bootloader` artifact. Ordinary `make`, `make check`, and `make firmware`
only build and test. The build uses Arduino CLI, Arduino AVR core and Arduino SD.
Tested with **arduino-cli 1.3.1, arduino:avr 1.8.8, SD 1.2.4**. The script finds
Arduino CLI on PATH or inside the macOS Arduino IDE; override `ARDUINO_CLI` and
`SD_LIBRARY` with absolute paths as needed. On a fresh development setup:

```sh
arduino-cli core install arduino:avr@1.8.8
arduino-cli lib install SD@1.2.4
```

The Uno profile supplies the standard ATmega328P pin mapping only. The project
overrides `F_CPU` to 8000000 and allows the full 32 KiB application flash;
this is **not** an instruction to use Uno clock fuses or its serial bootloader.
Select the internal 8 MHz clock in fuses. Setup removes CKDIV8 through CLKPR;
that cannot fix a fuse selection for an absent external clock. Keep RESET and
SPI programming enabled. Use ISP for this board; PD0/PD1 belong to the data bus,
so firmware deliberately does not initialize Serial. The board now has J3, a
six-pin ISP header. Check its physical orientation before attaching the cable.

For the socketed narrow DIP-28 ATmega328P-PU, `make program-dry-run` prints the
Homebrew Minipro commands, and `make program` executes them. The wrapper writes
the plain application HEX, then [fuses.conf](fuses.conf), then verifies both.
The fuse bytes are low `$E2` (internal 8 MHz, no divide by eight), high `$D9`
(RESET and SPI programming enabled, reset to application), extended `$FF`
(brown-out detection disabled), and lock `$FF` (unlocked). It selects
`ATMEGA328P@DIP28` for Minipro's ZIF socket. Flash programming erases the chip,
including any EEPROM contents. The installed `minipro` must be on PATH.
Use `make program-isp-dry-run` and `make program-isp` for the J3 header.
These add Minipro's `-i` option, which supplies target power; disconnect any
other 5 V source while using that mode.

The checked build currently uses 9,966 bytes of flash and 1,198 bytes of static SRAM,
leaving about 850 bytes for stack/runtime use. This is a linker report, not a
measured stack high-water mark. The protocol owns one 256-byte payload buffer;
Arduino SD owns a separate 512-byte card cache. No dynamic strings or payload
copies are used by the protocol.

## SD card

Use a FAT32-formatted card with one existing **`/FLEX.DSK`**, exactly **1,048,576
bytes** (one 128-track × 32-sector × 256-byte FLEX volume). Other files are
ignored. The Arduino SD library handles FAT and partial 512-byte card blocks.
This firmware uses its lower-level `SdFile` interface to check `sync()` errors.
It opens the existing file read/write without append/create/truncate flags.
Successful WRITE means the 16-bit payload checksum matched, all 256 bytes were
written and `sync()` succeeded. READ replies include the same checksum.

To prepare a data-volume image from the existing two-volume SRAM build:

```sh
make -C ../flex2 image
make image                # expand SRAM drive 1 to build/FLEX.DSK
# or: make image SD_VOLUME=0   # expand the system/BASIC volume instead
```

The extractor refuses to overwrite an existing output; remove/rename it or
invoke `tools/extract_image.py --force` deliberately. Copy the expanded file
to the SD card yourself. The converter preserves existing track/sector addresses, adds the new sectors
to the free chain and updates the SIR. A whole 1 MiB SRAM image contains two
volumes and cannot be copied directly as the SD drive image.
A system-volume copy does not make this hardware bootable: its current sector
bootstrap still reads SRAM directly.

Mount happens once at startup. There is no card-detect/write-protect connection
on the current schematic. After removal, insertion or an I/O fault, reset the
AVR before using another card; automatic hot remount is not implemented. An I/O
fault latches failure and stops further storage operations. Sector writes are
not power-fail atomic. A link timeout aborts an incomplete payload without
writing it, but cannot undo a write already committed by the SD library.

## Board and protocol

[PINOUT.md](PINOUT.md) records the inspected nets and connector. `make
check-board` compares PCB nets and schematic HCT values against the firmware;
it is read-only and does not modify either KiCad project. It checks logical
pin numbering, not the mechanical orientation of the proposed back-mounted
socket. Verify the mating pin-1/row orientation in the board assembly view.

[PROTOCOL.md](PROTOCOL.md) defines version 2, including PIA setup, strobes,
status codes, data lengths, the 16-bit sector checksum and recovery. This is a concrete starting contract
for the FLEX backend, not a pre-existing device standard.

[DIRECT_BUS.md](DIRECT_BUS.md) sketches a possible **new** two-register
memory-mapped SD board with its own AVR. It lists the external latches and
ready flags needed to use the C68 data bus without a PIA. It does not describe
the current board or firmware.

Source organization:

- `firmware/sd_bridge/sd_bridge.ino`: initialization, pin-change interrupt and loop.
- `src/avr_board.h` under the sketch: latch isolation, clocks, controls and LEDs.
- `src/protocol.h`: fixed-size request/response and sector state machine.
- `src/link.h`: handshake ordering, backpressure and timeout recovery.
- `src/sd_storage.h`: existing image, bounded offsets and checked SD sync.
- `tests/`: host tests of the same protocol/link templates plus image extraction.

Remaining features, including deferred SD error logging: [TODO.md](TODO.md).

## Next hardware work

- Bench-test latch bit order, request/ack flags and both handshake channels with
  INFO/STATUS before enabling disk writes.
- Scope /PA_OE and PD0–7 around AVR direction changes; U2 is disabled first.
- Test SD faults and real call-stack usage; keep command timeouts long enough
  for blocking SD operations.
- Check the direct SD MISO path against the actual card's output levels and
  the 5 V AVR's input threshold; U5 shifts CS/MOSI/SCK down, not MISO up.
- Bench-test the MIKBUG/FLEX drive-2 backend, then add SD boot support.
- Decide on write protection, explicit eject/remount, stronger CRC protection,
  and physical programming/reset access before treating this as finished firmware.
