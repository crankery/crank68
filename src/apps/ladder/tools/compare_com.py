"""Find long exact runs shared by two CP/M load images."""
from collections import defaultdict
from pathlib import Path
import sys

a = Path(sys.argv[1]).read_bytes()
b = Path(sys.argv[2]).read_bytes()
seed = 16
index = defaultdict(list)
for j in range(len(b) - seed + 1):
    index[b[j:j + seed]].append(j)
matches = set()
for i in range(len(a) - seed + 1):
    candidates = index.get(a[i:i + seed], ())
    if len(candidates) > 3:
        continue
    for j in candidates:
        left = 0
        while i - left > 0 and j - left > 0 and a[i - left - 1] == b[j - left - 1]:
            left += 1
        right = seed
        while i + right < len(a) and j + right < len(b) and a[i + right] == b[j + right]:
            right += 1
        length = left + right
        if length < 24:
            continue
        aa = i - left
        bb = j - left
        run = a[aa:aa + length]
        if len(set(run)) < 8:
            continue
        matches.add((aa, bb, length))
matches = sorted(matches, key=lambda m: -m[2])
print(f'{Path(sys.argv[1]).name} vs {Path(sys.argv[2]).name}: '
      f'{len(matches)} distinct exact runs >=24 bytes')
for aa, bb, length in matches[:30]:
    sample = a[aa:aa + min(length, 24)]
    print(f'  {length:4d} bytes  ${aa + 0x100:04X} -> ${bb + 0x100:04X}  {sample.hex()}')
