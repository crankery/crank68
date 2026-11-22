#!/usr/bin/env python3
"""Send a CRC checked binary image to the C68 BIOS monitor."""

import argparse
import socket
import sys
from pathlib import Path


PAGE_BYTES = 4096
PAIR_BYTES = 2 * PAGE_BYTES
PAIR_COUNT = 128
SRAM_BYTES = PAIR_COUNT * PAIR_BYTES


def number(value):
    return int(value, 0)


def byte(value):
    result = number(value)
    if not 0 <= result <= 255:
        raise argparse.ArgumentTypeError("byte must be between 0 and 255")
    return result


def address(value):
    result = number(value)
    if not 0 <= result <= 0xffff:
        raise argparse.ArgumentTypeError("address must be between 0 and 0xffff")
    return result


def assignment(value):
    try:
        key, val = value.split("=", 1)
        return address(key), byte(val)
    except (ValueError, argparse.ArgumentTypeError) as exc:
        raise argparse.ArgumentTypeError("expected ADDRESS=BYTE") from exc


def crc16(data):
    crc = 0xffff
    for value in data:
        crc ^= value << 8
        for _ in range(8):
            crc = ((crc << 1) ^ (0x1021 if crc & 0x8000 else 0)) & 0xffff
    return crc


class Link:
    def __init__(self, stream, tcp):
        self.stream = stream
        self.tcp = tcp

    def write(self, data):
        if self.tcp:
            self.stream.sendall(data)
        else:
            if self.stream.write(data) != len(data):
                raise OSError("short serial write")

    def read(self):
        data = self.stream.recv(1) if self.tcp else self.stream.read(1)
        if not data:
            raise TimeoutError("upload link timed out or closed")
        return data

    def expect(self, expected):
        got = self.read()
        if got != expected:
            raise RuntimeError(f"expected {expected!r}, received {got!r}")

    def enter(self, target):
        self.write(f"{target:04X}U\r".encode("ascii"))
        suffix = bytearray()
        for _ in range(1024):
            suffix += self.read()
            if suffix.endswith(b"\r\nK"):
                return
            if len(suffix) > 3:
                del suffix[:-3]
        raise RuntimeError("BIOS upload acknowledgement not found")

    def set_address(self, target):
        self.write(b"A" + target.to_bytes(2, "big"))
        self.expect(b"K")

    def poke(self, target, value):
        self.write(b"W" + target.to_bytes(2, "big") + bytes([value]))
        self.expect(b"K")

    def block(self, data, retries):
        count = len(data)
        assert 1 <= count <= 256
        payload = bytes([count & 0xff]) + data
        packet = b"B" + payload + crc16(payload).to_bytes(2, "big")
        for attempt in range(retries + 1):
            self.write(packet)
            reply = self.read()
            if reply == b"K":
                return
            if reply != b"C":
                raise RuntimeError(f"unexpected block response {reply!r}")
        raise RuntimeError(f"block CRC rejected after {retries + 1} attempts")

    def quit(self):
        self.write(b"Q")
        self.expect(b"K")


def upload_blocks(link, data, target, block_size, retries):
    link.set_address(target)
    for offset in range(0, len(data), block_size):
        link.block(data[offset:offset + block_size], retries)


def upload_sram(link, image, start_pair, pairs, block_size, retries):
    """Load consecutive 4 KiB pages into the two SRAM windows per pair."""
    if len(image) != SRAM_BYTES:
        raise ValueError(f"SRAM image must be exactly {SRAM_BYTES:,} bytes")
    for pair in range(start_pair, start_pair + pairs):
        link.poke(0xe002, 2 * pair)
        link.poke(0xe003, 2 * pair + 1)
        base = pair * PAIR_BYTES
        upload_blocks(link, image[base:base + PAGE_BYTES], 0xc000,
                      block_size, retries)
        upload_blocks(link, image[base + PAGE_BYTES:base + PAIR_BYTES],
                      0xd000, block_size, retries)
        print(f"pair {pair + 1}/{PAIR_COUNT}: pages "
              f"{2 * pair:02X}/{2 * pair + 1:02X} sent", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    transport = parser.add_mutually_exclusive_group(required=True)
    transport.add_argument("--tcp", metavar="HOST:PORT")
    transport.add_argument("--serial", metavar="DEVICE")
    parser.add_argument("--baud", type=int, default=9600)
    parser.add_argument("--address", type=address,
                        help="target address for a single image upload")
    parser.add_argument("--sram-image", action="store_true",
                        help="fill all 128 SRAM page pairs from a 1 MiB image")
    parser.add_argument("--start-pair", type=int, default=0,
                        help="first SRAM page pair to send (0..127)")
    parser.add_argument("--pairs", type=int,
                        help="number of SRAM page pairs; default: through pair 127")
    parser.add_argument("--set", type=assignment, action="append", default=[],
                        metavar="ADDRESS=BYTE", help="write a register before uploading; repeatable")
    parser.add_argument("--block-size", type=int, default=256)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument("--timeout", type=float, default=5)
    parser.add_argument("image", type=Path)
    args = parser.parse_args()
    if not 1 <= args.block_size <= 256 or args.retries < 0 or args.timeout <= 0:
        parser.error("block size must be 1..256, retries >= 0, and timeout > 0")
    data = args.image.read_bytes()
    if args.sram_image:
        if args.address is not None or args.set:
            parser.error("--sram-image selects its own addresses and bank latches")
        if len(data) != SRAM_BYTES:
            parser.error(f"SRAM image must be exactly {SRAM_BYTES:,} bytes; "
                         f"got {len(data):,}")
        if not 0 <= args.start_pair < PAIR_COUNT:
            parser.error("--start-pair must be 0..127")
        pairs = PAIR_COUNT - args.start_pair if args.pairs is None else args.pairs
        if not 1 <= pairs <= PAIR_COUNT - args.start_pair:
            parser.error("--pairs exceeds the remaining SRAM page pairs")
    else:
        if args.address is None:
            parser.error("--address is required for a single image upload")
        if args.start_pair or args.pairs is not None:
            parser.error("--start-pair and --pairs require --sram-image")
        if args.address + len(data) > 0x10000:
            parser.error("image crosses the 16-bit address boundary")
        for start, end in ((0x9b40, 0x9b66), (0x9c00, 0x9d00)):
            if data and args.address < end and args.address + len(data) > start:
                parser.error(f"image overlaps BIOS working RAM at "
                             f"0x{start:04x}..0x{end-1:04x}")
    if args.tcp:
        try:
            host, port = args.tcp.rsplit(":", 1)
            stream = socket.create_connection((host, int(port)), args.timeout)
        except ValueError as exc:
            parser.error(f"invalid TCP endpoint: {exc}")
    else:
        try:
            import serial
        except ImportError as exc:
            parser.error("serial transport needs pyserial (pip install pyserial)")
        stream = serial.Serial(args.serial, args.baud, timeout=args.timeout,
                               write_timeout=args.timeout)
    with stream:
        link = Link(stream, bool(args.tcp))
        link.enter(0xc000 if args.sram_image else args.address)
        if args.sram_image:
            upload_sram(link, data, args.start_pair, pairs,
                        args.block_size, args.retries)
        else:
            for target, value in args.set:
                link.poke(target, value)
            upload_blocks(link, data, args.address,
                          args.block_size, args.retries)
        link.quit()
    if args.sram_image:
        print(f"Uploaded {pairs * PAIR_BYTES:,} SRAM bytes")
    else:
        print(f"Uploaded {len(data)} bytes at 0x{args.address:04X}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, TimeoutError, RuntimeError) as exc:
        sys.exit(f"upload: {exc}")
