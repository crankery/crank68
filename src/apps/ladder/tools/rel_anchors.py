"""Find relocated LINK-80 library code fragments in a CP/M .COM image.

Run from src/apps/ladder: python3 tools/rel_anchors.py cpm/BASCOM53/OBSLIB.REL
Only uniquely occurring absolute-byte runs are used as anchors. Candidate
entry addresses should be checked against a disassembly before being treated
as confirmed symbols.
"""

from collections import defaultdict
from pathlib import Path
import sys

class Bits:
    def __init__(self, data):
        self.data = data
        self.pos = 0
    def get(self, n):
        value = 0
        for _ in range(n):
            value = (value << 1) | ((self.data[self.pos // 8] >> (7 - self.pos % 8)) & 1)
            self.pos += 1
        return value
    def align(self):
        self.pos = (self.pos + 7) & ~7

def word(bits):
    raw = bits.get(16)
    return ((raw & 255) << 8) | (raw >> 8)

if not 2 <= len(sys.argv) <= 3:
    raise SystemExit('usage: rel_anchors.py LIBRARY.REL [PROGRAM.COM]')
lib = Path(sys.argv[1]).read_bytes()
com = Path(sys.argv[2] if len(sys.argv) == 3 else 'cpm/LADDER.COM').read_bytes()
b = Bits(lib)
modules = []
module = None
area = None
lc = {1: 0, 2: 0, 3: 0}
run = bytearray()
run_at = None
def flush():
    global run, run_at
    if module and len(run) >= 12 and run_at:
        module['runs'].append((run_at[0], run_at[1], bytes(run)))
    run = bytearray()
    run_at = None
while b.pos < len(lib) * 8:
    if b.get(1) == 0:
        value = b.get(8)
        if area in lc:
            if not run:
                run_at = (area, lc[area])
            run.append(value)
            lc[area] += 1
        continue
    typ = b.get(2)
    flush()
    if typ:
        value = word(b)
        if area in lc:
            lc[area] += 2
        continue
    ctl = b.get(4)
    addr = None
    name = None
    if ctl in (5, 6, 7, 8, 9, 10, 11, 12, 13, 14):
        addr = (b.get(2), word(b))
    if ctl in (0, 1, 2, 3, 4, 5, 6, 7, 8):
        name = bytes(b.get(8) for _ in range(b.get(3))).decode('ascii', 'replace')
    if ctl == 2:
        module = dict(name=name, runs=[], symbols=[], sizes={})
        modules.append(module)
        lc = {1: 0, 2: 0, 3: 0}
        area = 1
    elif module and ctl == 7:
        module['symbols'].append((name, addr))
    elif module and ctl in (10, 13):
        module['sizes'][ctl] = addr
    elif ctl == 11:
        area, value = addr
        if area in lc:
            lc[area] = value
    elif ctl == 14:
        b.align()
        area = None
    elif ctl == 15:
        break
flush()

results = []
for module in modules:
    anchors = defaultdict(list)
    for area, offset, piece in module['runs']:
        if len(set(piece)) < 6:
            continue
        at = com.find(piece)
        if at < 0:
            continue
        if com.find(piece, at + 1) >= 0:
            continue
        base = at + 0x100 - offset
        anchors[(area, base)].append((len(piece), at + 0x100, offset))
    if not anchors:
        continue
    for (area, base), runs in anchors.items():
        results.append((module['name'], area, base, len(runs), sum(n for n, _, _ in runs),
                        max(n for n, _, _ in runs), module['symbols'], runs))
results.sort(key=lambda r: (-r[3], -r[4]))
print('modules', len(modules), 'module/area/base anchor groups', len(results))
for name, area, base, count, total, longest, symbols, runs in results[:35]:
    print(f'{name:8s} area={area} base=${base:04X} runs={count} total={total} longest={longest}')
    for symbol, (typ, offset) in symbols:
        if typ == area and 0 <= base + offset < 0x10000:
            print(f'  {symbol:8s} -> ${base + offset:04X} (offset ${offset:04X})')
