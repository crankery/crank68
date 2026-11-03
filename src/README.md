# C68 system build

From this directory (`src`), run `make`. It builds and verifies FLEX, MIKBUG2,
the AVR SD bridge and the emulator, then gathers matching outputs in
`build/system/`:

| File | Use |
| --- | --- |
| `mikbug2.rom` | 8 KiB C68 monitor ROM, mapped at `$E000–$FFFF` |
| `flex2.dsk` | 1 MiB image for the two SRAM drives |
| `FLEX.DSK` | 1 MiB FAT32 SD-card volume for the configured SD drive |
| `sd_bridge.hex` | ATmega328P-PU firmware, compiled for internal 8 MHz |
| `avr-fuses.conf` | Minipro fuses for the internal 8 MHz clock |
| `emu` | Host emulator executable |
| `MANIFEST.txt` | File sizes and SHA-256 hashes for the packaged set |

The default `make` layout is SRAM volumes at FLEX drives 0/1 and SD at drive 2.
Use `make DRIVE_LAYOUT=sd-first` for SD at drive 0 and SRAM at drives 1/2.
The drive numbers are compiled into FLEX; `MANIFEST.txt` records the selected
layout. `SD_VOLUME` selects which SRAM volume seeds the SD image: default 1 for
the usual layout, default 0 for `sd-first`. Override it explicitly if needed.
The converter expands the selected source to 32 sectors per track. This rebuilds
the packaged `FLEX.DSK` from the source image; keep any SD card with user files
separate. The build does not flash chips or write a card.

`make run` launches the emulator with the packaged ROM and a writable
`build/session.dsk`. The session image is copied from the factory SRAM image
only the first time; later runs preserve its files. The interactive emulator
does not emulate the SD bridge yet, so `make run` requires the default layout.
The `sd-first` layout is ready for the SD boot work; MIKBUG's current `F` command
still starts from SRAM. Use `make DRIVE_LAYOUT=sd-first test` to run its driver
and FMS tests without the SRAM boot smoke test.

`make test` also runs the MIKBUG boot, FLEX and emulator suites. `make` already
runs FLEX image verification, SD protocol tests, the SD board pin audit and AVR
compilation. The AVR hex is for ISP programming of an internal-8-MHz target;
the build does not set clock fuses. See [SD bring-up](sd/README.md) and
[MIKBUG ROM API](roms/mikbug2/README.md#sd-bridge-rom-api).

For the socketed ATmega328P-PU in its narrow DIP-28 package,
`make program-avr-dry-run` prints the Minipro commands. `make program-avr`
explicitly writes the firmware and [fuses](sd/fuses.conf), then verifies both.
Ordinary `make`, `make run`, and `make test` do not contact a programmer.
For the new J3 header, use `make program-avr-isp-dry-run` to inspect the
commands or `make program-avr-isp` to program in circuit. Minipro's `-i`
option supplies target power; ensure the board has no second 5 V source.
