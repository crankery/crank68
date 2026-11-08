# C68 system build

From this directory (`src`), run `make`. It builds and verifies FLEX, MIKBUG2,
every `pld/*.gal`, the AVR SD bridge and the emulator, then gathers matching outputs in
`build/system/`:

| File | Use |
| --- | --- |
| `mikbug2.rom` | 8 KiB C68 monitor ROM, mapped at `$E000–$FFFF` |
| `flex2.dsk` | 1 MiB image for the two SRAM drives |
| `FLEX.DSK` | 1 MiB FAT32 SD-card volume for the configured SD drive |
| `sd_bridge.hex` | ATmega328P-PU firmware, compiled for internal 8 MHz |
| `avr-fuses.conf` | Minipro fuses for the internal 8 MHz clock |
| `emu` | Host emulator executable |
| `pld/*.jed` | JEDEC programming files for all GALasm sources in `pld/` |
| `pld/*.fus`, `pld/*.pin` | Fuse maps and pin reports for those GALs |
| `MANIFEST.txt` | File sizes and SHA-256 hashes for the packaged set |

Run `make pld` to build just the GALs. Their generated files also live in
`build/pld/`; the full system package copies them into `build/system/pld/`.

The default `make` layout is SRAM volumes at FLEX drives 0/1 and SD at drive 2.
Use `make DRIVE_LAYOUT=sd-first` for SD at drive 0 and SRAM at drives 1/2.
The drive numbers are compiled into FLEX; `MANIFEST.txt` records the selected
layout. `SD_VOLUME` selects which SRAM volume seeds the SD image: default 1 for
the usual layout, default 0 for `sd-first`. Override it explicitly if needed.
The converter expands the selected source to 32 sectors per track. This rebuilds
the packaged `FLEX.DSK` from the source image; keep any SD card with user files
separate. The build does not flash chips or write a card.

`make run` launches the emulator with the packaged ROM and writable SRAM and
SD images. The default SRAM image is `build/session.dsk`; the SD-first layout
uses `build/session-sram-sd-first.dsk`. The SD image is
`build/session-sd-<layout>.dsk`. Each session
image is copied from its factory image only the first time; later runs preserve
its files. Session preparation refreshes `FLEX2.SYS` in place when its build
changes and saves a full image backup named `*.pre-flex-*` first. The emulator
exposes the SD image through the PIA bridge protocol.
`make DRIVE_LAYOUT=sd-first run` puts SD at FLEX drive 0. MIKBUG's current `F`
command still starts from physical SRAM before FLEX selects its configured
drives. Use `make DRIVE_LAYOUT=sd-first test` to run its driver and FMS tests
without the SRAM boot smoke test.

For a raw TCP terminal, run `make run TCP_PORT=6800` and connect PuTTY in Raw
mode to `127.0.0.1:6800`. The emulator waits for the connection before running
the CPU. This uses the same persistent SRAM and SD session images. Continuous
instruction tracing is off by default; add `TRACE=1` to `make run` to enable it.
The emulator also runs without speed pacing by default; add `THROTTLE=1` to
pace the CPU at roughly 1 MHz.

`make test` also runs the MIKBUG boot, FLEX and emulator suites. `make` already
runs FLEX image verification, SD protocol tests, the SD board pin audit and AVR
compilation. The test suite boots the real emulator and catalogs the SD drive
through FLEX in the selected layout. The AVR hex is for ISP programming of an
internal-8-MHz target;
the build does not set clock fuses. See [SD bring-up](sd/README.md) and
[MIKBUG ROM API](roms/mikbug2/README.md#sd-bridge-rom-api).

For the socketed ATmega328P-PU in its narrow DIP-28 package,
`make program-avr-dry-run` prints the Minipro commands. `make program-avr`
explicitly writes the firmware and [fuses](sd/fuses.conf), then verifies both.
Ordinary `make`, `make run`, and `make test` do not contact a programmer.
For the new J3 header, use `make program-avr-isp-dry-run` to inspect the
commands or `make program-avr-isp` to program in circuit. Minipro's `-i`
option supplies target power; ensure the board has no second 5 V source.
