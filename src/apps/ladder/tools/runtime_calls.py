"""Inventory direct Ladder game-to-runtime transfers in the original CP/M COM.

Run from src/apps/ladder: python3 tools/runtime_calls.py --csv RUNTIME_CALLS.csv
Addresses in the output are CP/M memory addresses, not file offsets.
"""

import argparse
import csv
from collections import Counter, deque
from pathlib import Path

ORIGIN = 0x0100
DATA_START = 0x58DF
RUNTIME_START = 0x617D
ROOTS = (0x0100, 0x100E)

CALLS = {0xCD, 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC}
JUMPS = {0xC3, 0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA}
RETURNS = {0xC9, 0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8}
WORD_OPS = CALLS | JUMPS | {0x01, 0x11, 0x21, 0x31, 0x22, 0x2A, 0x32, 0x3A}
BYTE_OPS = {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36, 0x3E,
            0xC6, 0xCE, 0xD6, 0xDE, 0xE6, 0xEE, 0xF6, 0xFE,
            0xD3, 0xDB, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38}
RELATIVE = {0x10, 0x18, 0x20, 0x28, 0x30, 0x38}

# Only labels from OBSLIB's Disk module are used. Its eleven independent
# literal runs agree on base $8574. Names remain provisional: OBSLIB is 5.3,
# while LADDER.COM identifies its linked BASLIB as 5.2.
DISK_LABELS = {
    0x8574: '$EOF', 0x85F4: '$DKC', 0x863F: '$LOC', 0x865E: '$LOF',
    0x89AF: '$DKK', 0x8993: '$RS2', 0x89F4: '$FIL', 0x8AB4: '$DKN',
    0x8ADC: '$DKM', 0x8AEC: '$DKC0', 0x8B09: '$PUT', 0x8B11: '$RPT',
    0x8B25: '$GET', 0x8B2D: '$RGT',
}


def word(memory, address):
    return memory[address + 1] | memory[address + 2] << 8


def reachable_transfers(memory):
    """Follow direct control flow only; runtime callbacks cannot be recovered."""
    queue = deque(ROOTS)
    seen = set()
    transfers = set()
    while queue:
        pc = queue.popleft()
        if pc in seen or not ORIGIN <= pc < DATA_START:
            continue
        seen.add(pc)
        op = memory[pc]
        if op in WORD_OPS:
            size = 3
        elif op in BYTE_OPS or op == 0xCB:
            size = 2
        elif op == 0xED:
            size = 4 if memory[pc + 1] in {
                0x43, 0x4B, 0x53, 0x5B, 0x63, 0x6B, 0x73, 0x7B
            } else 2
        elif op in (0xDD, 0xFD):
            # No index prefixes appeared on the reachable paths in this COM.
            raise ValueError(f'unhandled index prefix at ${pc:04X}')
        else:
            size = 1
        nxt = pc + size
        if op in CALLS | JUMPS:
            target = word(memory, pc)
            if RUNTIME_START <= target < len(memory):
                transfers.add((pc, op, target))
            elif ORIGIN <= target < DATA_START:
                queue.append(target)
            if op != 0xC3:
                queue.append(nxt)
        elif op in RELATIVE:
            delta = memory[pc + 1]
            if delta >= 128:
                delta -= 256
            queue.append(nxt + delta)
            if op != 0x18:
                queue.append(nxt)
        elif op in RETURNS:
            if op != 0xC9:
                queue.append(nxt)
        elif op not in (0x76, 0xE9):  # HALT and indirect JP
            queue.append(nxt)
    return transfers, seen


def candidates(memory, confirmed):
    """Scan possible code bytes; rows outside the trace are candidates only."""
    rows = []
    for pc in range(ORIGIN, DATA_START - 2):
        op = memory[pc]
        if op not in CALLS | JUMPS:
            continue
        target = word(memory, pc)
        if not RUNTIME_START <= target < len(memory):
            continue
        rows.append({
            'source': f'${pc:04X}',
            'opcode': f'${op:02X}',
            'kind': 'CALL' if op in CALLS else 'JP',
            'target': f'${target:04X}',
            'trace': 'reachable' if (pc, op, target) in confirmed else 'byte_scan',
            'obslib_disk_candidate': DISK_LABELS.get(target, ''),
        })
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--com', type=Path,
                        default=Path(__file__).resolve().parent.parent / 'cpm/LADDER.COM',
                        help='original LADDER.COM image')
    parser.add_argument('--csv', type=Path, help='write complete candidate inventory')
    args = parser.parse_args()
    memory = bytes(ORIGIN) + args.com.read_bytes()
    confirmed, seen = reachable_transfers(memory)
    rows = candidates(memory, confirmed)
    assert len(confirmed) == sum(row['trace'] == 'reachable' for row in rows)
    if args.csv:
        with args.csv.open('w', newline='') as out:
            writer = csv.DictWriter(out, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
    print(f'{len(seen)} traced instructions; {len(confirmed)} confirmed transfers; '
          f'{len(rows)} total candidates; {len(set(row["target"] for row in rows))} targets')
    print('by kind:', dict(Counter(row['kind'] for row in rows)))
    print('top targets (all / traced):')
    counts = Counter(row['target'] for row in rows)
    traced = Counter(row['target'] for row in rows if row['trace'] == 'reachable')
    for target, count in counts.most_common(15):
        print(target, count, traced[target], DISK_LABELS.get(int(target[1:], 16), ''))


if __name__ == '__main__':
    main()
