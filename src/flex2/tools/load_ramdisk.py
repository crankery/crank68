#!/usr/bin/env python3
"""Load the 1 MiB FLEX SRAM disk through MIKBUG M/L/P over a serial port."""

import argparse
from pathlib import Path
import re
import sys
import time


IMAGE_BYTES = 1024 * 1024
PAIR_BYTES = 8192
PAGE_BYTES = 4096
PAIR_COUNT = IMAGE_BYTES // PAIR_BYTES
RECORD_BYTES = 64
SECTOR_BYTES = 256
SECTORS_PER_TRACK = 16
TRACKS_PER_DRIVE = 128
SECTORS_PER_DRIVE = TRACKS_PER_DRIVE * SECTORS_PER_TRACK
S1_RE = re.compile(rb"S1([0-9A-Fa-f]{2})")


def s1(address: int, data: bytes) -> bytes:
    if not 1 <= len(data) <= 252 or not 0 <= address <= 0xffff - len(data) + 1:
        raise ValueError("Invalid S1 address or payload length")
    count = len(data) + 3
    body = bytes((count, address >> 8, address & 255)) + data
    return b"S1" + body.hex().upper().encode() + f"{(~sum(body)) & 255:02X}".encode()


def free_sectors(image: bytes) -> set[int]:
    """Follow each FLEX SIR free chain; return physical sector indexes."""
    if len(image) != IMAGE_BYTES:
        raise ValueError(f"Image must be exactly {IMAGE_BYTES:,} bytes")
    free = set()
    for drive in range(2):
        first = drive * SECTORS_PER_DRIVE
        sir = image[(first + 2) * SECTOR_BYTES + 16:(first + 2) * SECTOR_BYTES + 40]
        link = sir[13:15]
        tail = sir[15:17]
        count = int.from_bytes(sir[17:19], "big")
        previous = b"\0\0"
        found = 0
        while link != b"\0\0":
            track, sector = link
            if not 0 <= track < TRACKS_PER_DRIVE or not 1 <= sector <= SECTORS_PER_TRACK:
                raise ValueError(f"Drive {drive}: invalid free-sector link {list(link)}")
            local = track * SECTORS_PER_TRACK + sector - 1
            if local < SECTORS_PER_TRACK:
                raise ValueError(f"Drive {drive}: reserved track-zero sector in free chain")
            physical = first + local
            if physical in free:
                raise ValueError(f"Drive {drive}: free-sector chain has a loop")
            free.add(physical)
            found += 1
            if found > count:
                raise ValueError(f"Drive {drive}: free-sector chain exceeds SIR count")
            previous = link
            offset = physical * SECTOR_BYTES
            link = image[offset:offset + 2]
        if found != count or tail != previous:
            raise ValueError(f"Drive {drive}: free-sector chain disagrees with SIR")
    return free


def pair_records(pair: int, image: bytes, record_bytes: int = RECORD_BYTES,
                 free: set[int] | None = None):
    if not 0 <= pair < PAIR_COUNT or not 1 <= record_bytes <= 252:
        raise ValueError("Invalid page pair or record size")
    chunk = image[pair * PAIR_BYTES:(pair + 1) * PAIR_BYTES]
    if len(chunk) != PAIR_BYTES:
        raise ValueError("Image is incomplete")
    if free is None:
        for window, base in enumerate((0xC000, 0xD000)):
            part = chunk[window * PAGE_BYTES:(window + 1) * PAGE_BYTES]
            for offset in range(0, PAGE_BYTES, record_bytes):
                yield s1(base + offset, part[offset:offset + record_bytes])
    else:
        for offset in range(0, PAIR_BYTES, SECTOR_BYTES):
            sector = (pair * PAIR_BYTES + offset) // SECTOR_BYTES
            data = chunk[offset:offset + SECTOR_BYTES]
            if sector in free:
                yield s1(0xC000 + offset, data[:2])
            else:
                for part in range(0, SECTOR_BYTES, record_bytes):
                    yield s1(0xC000 + offset + part, data[part:part + record_bytes])


def first_difference(pair: int, actual: bytes, expected: bytes,
                     free: set[int] | None = None) -> int | None:
    """Ignore payload bytes deliberately omitted from free sectors."""
    if len(actual) != PAIR_BYTES or len(expected) != PAIR_BYTES:
        raise ValueError("Readback pair is incomplete")
    for offset, (found, wanted) in enumerate(zip(actual, expected)):
        if found == wanted:
            continue
        sector = (pair * PAIR_BYTES + offset) // SECTOR_BYTES
        if free is None or sector not in free or offset % SECTOR_BYTES < 2:
            return offset
    return None


def parse_punch(raw: bytes) -> bytes:
    """Extract C000-DFFF bytes from MIKBUG P output and check every S1 checksum."""
    result = bytearray(PAIR_BYTES)
    seen = bytearray(PAIR_BYTES)
    pos = 0
    while True:
        match = S1_RE.search(raw, pos)
        if not match:
            break
        count = int(match.group(1), 16)
        end = match.start() + 2 + 2 * (count + 1)
        if count < 3 or end > len(raw):
            raise ValueError("Truncated MIKBUG P record")
        record = bytes.fromhex(raw[match.start() + 2:end].decode("ascii"))
        if len(record) != count + 1 or (sum(record) & 255) != 255:
            raise ValueError("Bad MIKBUG P record checksum")
        address = (record[1] << 8) | record[2]
        data = record[3:-1]
        offset = address - 0xC000
        if offset < 0 or offset + len(data) > PAIR_BYTES:
            raise ValueError(f"MIKBUG P returned out-of-window address ${address:04X}")
        if any(seen[offset:offset + len(data)]):
            raise ValueError(f"MIKBUG P returned duplicate data at ${address:04X}")
        result[offset:offset + len(data)] = data
        seen[offset:offset + len(data)] = b"\x01" * len(data)
        pos = end
    if not all(seen):
        raise ValueError(f"MIKBUG P returned only {sum(seen)} of {PAIR_BYTES} bytes")
    return bytes(result)


class Monitor:
    def __init__(self, port, timeout: float):
        self.port = port
        self.timeout = timeout

    def send(self, data: bytes):
        self.port.write(data)
        self.port.flush()

    def until(self, marker: bytes, timeout: float | None = None) -> bytes:
        deadline = time.monotonic() + (self.timeout if timeout is None else timeout)
        output = bytearray()
        while time.monotonic() < deadline:
            piece = self.port.read(1)
            if piece:
                output += piece
                if output.endswith(marker):
                    return bytes(output)
        raise TimeoutError(f"Waiting for {marker!r}; last output: {bytes(output[-80:])!r}")

    def prompt(self, timeout: float | None = None) -> bytes:
        return self.until(b"*", timeout)

    def synchronize(self):
        self.send(b"\r")
        self.prompt()

    def set_byte(self, address: int, value: int):
        """MIKBUG M writes, then may print '?' on a write-only latch readback."""
        self.send(f"M{address:04X}".encode())
        self.until(f"{address:04X} ".encode())
        old = self.until(b" ")
        if not re.fullmatch(rb"[0-9A-Fa-f]{2} ", old):
            raise RuntimeError(f"Unexpected MIKBUG M value prompt: {old!r}")
        self.send(f"{value:02X}".encode())
        try:
            self.prompt(timeout=0.35)
            return  # MIKBUG rejected its readback and already reprompted.
        except TimeoutError:
            self.send(b"\r")  # Matching readback: CR exits M's edit loop.
            self.prompt()

    def upload(self, records, record_gap: float):
        self.send(b"L")
        self.until(b"\x11")  # MIKBUG's reader-on/XON byte.
        for record in records:
            self.send(record + b"\r\n")
            if record_gap:
                time.sleep(record_gap)
            response = self.port.read_all()
            if b"?" in response:
                raise RuntimeError("MIKBUG rejected an S1 record: " + repr(response[-80:]))
        self.send(b"S9")  # MIKBUG returns on these two bytes; no S9 body.
        response = self.prompt()
        if b"?" in response:
            raise RuntimeError("MIKBUG reported a load error: " + repr(response[-80:]))

    def readback(self) -> bytes:
        self.send(b"P")
        self.until(b"BEG ADDR ?")
        self.send(b"C000")
        self.until(b"END ADDR ?")
        self.send(b"DFFF")  # MIKBUG P's end address is inclusive.
        # P sends 512 short S1 records: roughly 250,000 serial bits per pair.
        raw = self.until(b"S9030000FC",
                         timeout=max(self.timeout, 60.0, 500_000 / self.port.baudrate))
        self.prompt()
        return parse_punch(raw)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("port", help="Serial device, for example /dev/tty.usbserial-XXXX")
    parser.add_argument("image", nargs="?", type=Path,
                        default=Path(__file__).resolve().parents[1] / "build/flex2.dsk")
    parser.add_argument("--baud", type=int, default=9600)
    parser.add_argument("--start-pair", type=int, default=0,
                        help="Resume at this 8 KiB page pair (0..127)")
    parser.add_argument("--pairs", type=int, default=None,
                        help="Number of page pairs to load; default is through pair 127")
    parser.add_argument("--record-gap", type=float, default=0.005,
                        help="Seconds between S1 records (default: 0.005)")
    parser.add_argument("--timeout", type=float, default=10.0)
    parser.add_argument("--no-verify", action="store_true",
                        help="Skip MIKBUG P readback after each 8 KiB pair")
    parser.add_argument("--skip-free-payload", action="store_true",
                        help="Send only the two link bytes of each FLEX free sector")
    args = parser.parse_args()
    if not 0 <= args.start_pair < PAIR_COUNT:
        parser.error("--start-pair must be 0..127")
    count = PAIR_COUNT - args.start_pair if args.pairs is None else args.pairs
    if count < 1 or args.start_pair + count > PAIR_COUNT:
        parser.error("--pairs exceeds the 128 page pairs")
    if args.baud <= 0 or args.record_gap < 0 or args.timeout <= 0:
        parser.error("Baud, record gap, and timeout must be positive")
    image = args.image.read_bytes()
    if len(image) != IMAGE_BYTES:
        parser.error(f"Image must be exactly {IMAGE_BYTES:,} bytes; got {len(image):,}")
    try:
        free = free_sectors(image) if args.skip_free_payload else None
    except ValueError as exc:
        parser.error(str(exc))
    if free is not None:
        print(f"Sparse load: {len(free)} free sectors; sending links, skipping payloads.",
              flush=True)
    try:
        import serial  # pyserial; imported here so the record helpers need no dependency.
    except ImportError as exc:
        raise SystemExit("Install pyserial first: python3 -m pip install pyserial") from exc
    with serial.Serial(args.port, args.baud, timeout=0.1, write_timeout=10,
                       stopbits=serial.STOPBITS_TWO,
                       xonxoff=False, rtscts=False, dsrdtr=False) as connection:
        monitor = Monitor(connection, args.timeout)
        monitor.synchronize()
        for pair in range(args.start_pair, args.start_pair + count):
            monitor.set_byte(0xE002, 2 * pair)
            monitor.set_byte(0xE003, 2 * pair + 1)
            monitor.upload(pair_records(pair, image, free=free), args.record_gap)
            if not args.no_verify:
                actual = monitor.readback()
                expected = image[pair * PAIR_BYTES:(pair + 1) * PAIR_BYTES]
                first = first_difference(pair, actual, expected, free)
                if first is not None:
                    raise RuntimeError(f"Pair {pair} differs at ${0xC000 + first:04X}: "
                                       f"read ${actual[first]:02X}, expected ${expected[first]:02X}")
            print(f"pair {pair + 1}/{PAIR_COUNT}: pages {2*pair:02X}/{2*pair+1:02X} "
                  + ("verified" if not args.no_verify else "sent"), flush=True)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, TimeoutError, RuntimeError, ValueError) as exc:
        sys.exit(f"Upload stopped: {exc}")
