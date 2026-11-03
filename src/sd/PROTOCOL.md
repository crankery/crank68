# PIA / SD bridge protocol v2

This contract is implemented by the AVR firmware and the MIKBUG ROM host
transport (`../roms/mikbug2/sdcard.s`), used by FLEX drive 2.
Port A stays output on the C68; port B stays input. The AVR uses the two external
latches to share its own Port D without connecting two output drivers together.
All fields and payloads are bytes. A logical sector is exactly 256 bytes.

## PIA configuration

For a 6821-compatible PIA, use manual CA2/CB2 outputs, idle high; configure CA1
and CB1 to latch **rising** edges, with CPU interrupts disabled for initial
polling code. DDRA=$FF; DDRB=$00. With ordinary register selection this means:
select each DDR with control `$3A`, write its direction, then select its port
with control `$3E`. Pulse its manual output low with `$36`, then back to `$3E`.
AVR input pull-ups hold CA2/CB2 high when the host is disconnected or reset.
Use the configured PIA base on the IO board; firmware does not assume its CPU
address. Clear stale input flags by reading PA and PB during initialization.

### C68 sends a byte

1. Write PA. Lower CA2, then raise it (a low pulse of at least 10 microseconds
   is a conservative initial host setting). U2 captures PA on the rising edge.
2. AVR pin-change IRQ records the request; main code enables U2 only while its
   shared Port D is input, samples the byte, then disables U2.
3. AVR processes the byte and pulses CA1 high for 4 microseconds. C68 polls
   CRA bit 7, then **reads PA to clear the flag**, before sending another byte.

The final checksum-byte ACK on WRITE can be delayed by SD write/sync. The host
must allow blocking storage latency rather than assuming fixed strobe spacing.
A new PA write must not overwrite U2 before the previous byte was acknowledged.

### AVR sends a byte

1. AVR disables U2, drives Port D, and pulses PB_CLK to load U3. It then returns
   Port D to input mode. U3 continues holding the response byte on PIA B.
2. AVR raises CB1 and holds it high. C68 polls CRB bit 7, reads PB (clearing that
   flag), then pulses CB2 low and high to acknowledge consumption.
3. AVR lowers CB1, advances the response and publishes the next byte, if any.
   It never overwrites an unacknowledged output byte.

The two handshake channels are separate. Reading PB does not clear a CA1 flag;
reading PA does not clear a CB1 flag. Automatic PIA handshake modes are not
used. During a response the host sends only CB2 ACKs, not a new CA2 request,
until the final byte is consumed. The final response ACK and first new request
may arrive together; firmware handles that ordering.

## Requests and responses

Every request starts with five bytes:

```text
A5 5A opcode track sector
```

Track is 0–127 and sector 1–32 for READ/WRITE. Other commands require both fields
zero. The two sync bytes are not interpreted inside a WRITE payload.

| Opcode | Command | Request tail | Response |
| --- | --- | --- | --- |
| 00 | INFO | none | `00 02 80 20 00 01`: OK, version, tracks, sectors/track, 256-byte size little-endian |
| 01 | STATUS | none | One storage-status byte |
| 10 | READ | none | Status; 256 data bytes + checksum high/low only if status is zero |
| 11 | WRITE | 256 data bytes + checksum high/low | One status after write and sync complete |
| 12 | SYNC | none | One status after checked sync |

An invalid WRITE address still consumes all 256 payload bytes and both checksum
bytes, then returns
BAD_ADDRESS without touching storage. INFO works without a mounted image;
STATUS reports the mount/error state. No serial text or unsolicited replies
are emitted on either PIA channel.

| Status | Meaning |
| --- | --- |
| 00 | OK |
| 01 | SD initialization failed / no card |
| 02 | FAT/root initialization failed |
| 03 | Existing FLEX.DSK could not be opened read/write |
| 04 | FLEX.DSK is not exactly 1,048,576 bytes |
| 05 | Invalid track/sector or nonzero reserved address fields |
| 06 | Seek/read/write/sync error; storage stays faulted until AVR reset |
| 07 | Unknown opcode |
| 08 | Payload checksum mismatch; no storage write was attempted |

FLEX.DSK must be exactly 1,048,576 bytes (128 tracks × 32 sectors × 256 bytes).
Other files on FAT32 are ignored. The volume file is never created, appended,
truncated or extended. Offset = `((uint32_t)track * 32 + sector - 1) * 256`.

## Payload checksum

Version 2 adds a **16-bit additive sum** of the 256 unsigned payload bytes,
starting at zero. Transmit the raw sum **high byte, then low byte**. The request
header, response status and checksum bytes themselves are not included.
READ success is 259 response bytes total (status + 256 + 2). WRITE takes a
258-byte request tail and returns success only after both checksum bytes match
and the storage write/sync succeeds. No card write occurs on BAD_CHECKSUM.
This is a recoverable transfer error, not a latched SD-card I/O fault.
An incomplete checksum times out exactly like an incomplete data payload.

Known sums: 256 zero bytes → `$0000`; bytes `$00` through `$FF` → `$7F80`;
256 `$FF` bytes → `$FF00`. This sum is cheap to calculate on the 6800:

```asm
        clra                    ; A:B = high:low sum
        clrb
        ldx #BUFFER
sum256: addb 0,x
        adca #0
        inx
        cpx #BUFFER+256
        bne sum256
        ; Send/compare A, then B, preserving them across handshake routines.
```

On READ the C68 must verify the received checksum before accepting the sector.
Byte-consumption ACKs are not an integrity verdict; the receiver still ACKs the
checksum bytes. A mismatch can be reported to FLEX or retried as a new READ.
The sum detects single-byte changes but cannot detect byte swaps or compensating
changes; it is not a CRC. Request headers/status remain unchecksummed.
Version-1 hosts are incompatible with the new byte counts: check INFO's version
before sector transfers. INFO's existing sector-size field remains little-endian;
the new checksum is deliberately high-byte first for the 6800.

## Recovery and scope

Two seconds without progress in a partial request or unconsumed response resets
the parser and lowers ready/ack outputs. It does not remount the card or undo a
completed write. An incomplete write has only reached the private RAM buffer
and is discarded. Overlapping/unexpected strobes or a pending-event overrun
also isolate/reset the link. The host should wait for the timeout, clear PIA
flags, and begin again with A5 5A; it must not expect a RESET opcode to escape
from the middle of a 256-byte payload. Inspect STATUS after recovery if an I/O
failure is suspected. Rewriting the same sector after an uncertain completion
must be a deliberate host retry decision.

Timeouts are configurable in `protocol.h`; the host should use a longer SD-I/O
timeout than the between-byte timeout. The library can block while accessing
SD, and its internal timeout behavior also applies. This implementation uses the payload sum above, with no
CRC or request IDs yet. Hardware timing and missed-edge behavior still require
bench tests; passing host tests does not validate the electrical handshake.
