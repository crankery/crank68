# SD bridge TODO

## Bring-up and host integration

- [ ] Bench-test the latches, strobe timing and CA1/CB1 flag clearing.
- [x] Implement the FLEX drive-2 backend and MIKBUG ROM transport, including
  protocol-v2 payload checksums. CPU/protocol and FMS tests pass; hardware
  bring-up is still required.
- [ ] Emulate the PIA/AVR SD bridge in the C68 emulator: model the latch and
  handshake behavior and protocol-v2 checksums, backed by a 1 MiB FLEX.DSK
  host file, so the same FLEX removable-disk driver runs in the emulator.
  Include absent-media, checksum-error and timeout cases for driver testing.
- [ ] Measure runtime stack usage on the ATmega328P under SD-error paths.
- [ ] Add explicit eject/remount and media/write-protect handling.
- [ ] Add removable-media boot support after ordinary sector I/O works.

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
