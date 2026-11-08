# SD bridge TODO

## Possible direct-bus successor

- [ ] Review [DIRECT_BUS.md](DIRECT_BUS.md) against the CPU bus timing and
  available I/O address space before drawing a board. This is a separate
  proposed ATmega328P interface; the PIA board and protocol v2 remain current.
- [ ] Decide the status bits, command framing, write-event latch, read-consume
  flag, AVR pin budget, reset defaults, and any media-change signal.
- [ ] If built, adapt the AVR link, MIKBUG ROM transport, and emulator while
  keeping the storage engine and FLEX disk API stable.

## Bring-up and host integration

- [ ] Audit the real IO board address decode before connecting the SD bridge.
  With U1's default slot `01`, U2B appears to select PIA 1 at `$E014–$E017`
  (and PIA 2 at `$E01C–$E01F`), but `roms/mikbug2/sdcard.s` and the emulator
  currently use `$E020–$E023` for PIA 1. Confirm against the assembled board,
  then align the ROM, FLEX driver, emulator and tests to the actual address.
- [ ] Bench-test the latches, strobe timing and CA1/CB1 flag clearing.
- [x] Implement the FLEX drive-2 backend and MIKBUG ROM transport, including
  protocol-v2 payload checksums. CPU/protocol and FMS tests pass; hardware
  bring-up is still required.
- [x] Emulate the PIA/AVR SD bridge in the C68 emulator with PIA handshakes,
  protocol-v2 checksums and a 1 MiB host image. FLEX can catalog it in both
  drive layouts.
- [ ] Add emulator fault injection and timeout recovery for removable-media
  driver testing. The separate CPU fixture covers absent media, bad checksums
  and a disconnected bridge.
- [ ] Measure runtime stack usage on the ATmega328P under SD-error paths.
- [ ] Add explicit eject/remount and media/write-protect handling.
- [ ] Add removable-media boot support after ordinary sector I/O works.

## Future boot and drive layout

- [ ] Make MIKBUG `F` boot from SD D0 using a new SD-aware boot sector/link.
  The first SD-only layout can fail back to MIKBUG if D0 is absent; no SRAM
  disk or SRAM fallback is required.
- [ ] Extend the direct-bus protocol and ROM/FLEX API with a drive number;
  today's SD ROM API addresses only one image and FLEX's drive layout is
  compiled in. Keep the boot image and FLEX drive 0 identical.
- [ ] Parse `VOLUMES.INI` on the AVR to map D0–D3 to named FLEX images, with
  blank entries reporting absent drives. Validate each image's SIR geometry
  against its length. See [DIRECT_BUS.md](DIRECT_BUS.md#sd-only-boot-and-volume-map).
- [ ] As a separate experiment, define `D3=RAM,VOL3.DSK`: decide whether it
  is a read-only snapshot, explicitly saved, or written through. A power
  cycle loses RAM writes without a persistence rule.
- [ ] Allow the banked SRAM to serve as general banked memory when no SRAM
  drive claims those pages. Document page ownership so a disk operation
  cannot overwrite an experiment's memory.

The current PIA firmware build uses 9,966/32,768 bytes of flash and 1,198/2,048
bytes of static SRAM. Recheck the direct-bus build independently. Keep a future
config parser streaming with a short fixed line buffer and a small drive table;
avoid holding whole config files or FAT cluster maps in AVR RAM. Measure stack
headroom before adding multiple open SD files or larger buffers.

## Deferred conveniences

- [ ] Optional SD-card error log (for example `ERROR.LOG`): record protocol
  errors, checksum mismatches, timeouts and storage error details. Keep logging
  bounded and outside the per-byte handshake/interrupt path.
- [ ] Logging must be best-effort: if the card itself is missing/faulted, skip
  the log rather than recursively trying to report a logging failure. Define
  buffering/flush policy and the extra RAM budget before implementing it.
- [ ] Consider counters or an error-query command for faults that cannot be
  logged to the card.
- [ ] Consider a CRC and protected headers/request IDs if additive payload
  checksums prove insufficient. Version changes must be explicit.

Error logging is deliberately not implemented in this round. The current
firmware still accesses only FLEX.DSK and never creates a log file.
