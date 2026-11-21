#!/usr/bin/env python3
"""Count the three logged original Ladder rock decision sites."""

import csv
import gzip
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SITES = {"474F": (1, 2, 3), "496C": (0, 1, 2), "4A63": (3, 4)}


def counts(path: Path) -> dict[str, Counter[int]]:
    result: dict[str, Counter[int]] = defaultdict(Counter)
    with gzip.open(path, "rt", newline="") as stream:
        for row in csv.DictReader(stream):
            pc = row["pc"]
            if pc not in SITES:
                raise ValueError(f"unexpected event site {pc} in {path}")
            value = int(row["result"], 16)
            if value not in SITES[pc]:
                raise ValueError(f"unexpected result {value} at {pc} in {path}")
            result[pc][value] += 1
    return result


def show(label: str, site_counts: dict[str, Counter[int]]) -> None:
    parts = []
    for pc, values in SITES.items():
        counter = site_counts[pc]
        parts.append(f"{pc} n={sum(counter.values())} " +
                     "/".join(str(counter[value]) for value in values))
    print(label + "  " + "  ".join(parts))


def main() -> None:
    total: dict[str, Counter[int]] = defaultdict(Counter)
    for speed in range(1, 6):
        path = ROOT / "analysis" / f"rock-events-frequency-ghost-s{speed}.csv.gz"
        sample = counts(path)
        show(f"speed {speed}", sample)
        for pc in SITES:
            total[pc].update(sample[pc])
    show("total  ", total)


if __name__ == "__main__":
    main()
