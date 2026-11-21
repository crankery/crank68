#!/usr/bin/env python3
"""Wrap a raw 6800 binary in FLEX load and transfer records."""

from pathlib import Path

data = Path("ladder.bin").read_bytes()
assert 0 < len(data) <= 0x7E00 - 0x0300
records = bytearray()
for offset in range(0, len(data), 255):
    part = data[offset:offset + 255]
    records += b"\x02" + (0x0300 + offset).to_bytes(2, "big")
    records += bytes([len(part)]) + part
records += b"\x16\x03\x00"
Path("LADDER.CMD").write_bytes(records)
