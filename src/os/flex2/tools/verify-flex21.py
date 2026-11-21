#!/usr/bin/env python3
"""Compare every emitted byte in the original listing with the vasm binary."""
from pathlib import Path
import re

expected = {}
next_address = None
for line in Path('6800Flex/FLEX21.LST').read_text().splitlines():
    match = re.match(r'^\d{4} ([0-9a-f]{4}) (.{22})', line)
    if match:
        address = int(match[1], 16)
        field = match[2].strip()
    elif re.fullmatch(r' {10}(?:[0-9a-f]{2} ?)+', line):
        assert next_address is not None
        address = next_address
        field = line.strip()
    else:
        next_address = None
        continue
    if not field:
        next_address = None
        continue
    assert re.fullmatch(r'[0-9a-f]{2}(?: [0-9a-f]{2})*', field), repr(line)
    payload = bytes.fromhex(field)
    for offset, value in enumerate(payload):
        location = address + offset
        assert location not in expected or expected[location] == value
        expected[location] = value
    next_address = address + len(payload)

assert expected, 'No reference bytes found'
base = min(expected)
binary = Path('build/flex21.bin').read_bytes()
assert len(binary) == max(expected) - base + 1, 'Unexpected binary extent'
errors = [(address, value, binary[address-base]) for address, value in sorted(expected.items())
          if binary[address-base] != value]
for address, want, got in errors[:20]:
    print(f'${address:04X}: reference {want:02X}, vasm {got:02X}')
assert not errors, f'{len(errors)} byte mismatches'
print(f'All {len(expected)} reference bytes match (${base:04X}-${max(expected):04X}); '
      f'{len(binary)-len(expected)} gap bytes excluded.')
