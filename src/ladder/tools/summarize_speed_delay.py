#!/usr/bin/env python3
"""Recount the original Ladder speed-delay emulator probes."""

import csv
import gzip
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "analysis"


def update_gap(filename: str, update: int = 8) -> int:
    with gzip.open(ROOT / filename, "rt", newline="") as stream:
        rows = {int(row["update"]): int(row["instructions"])
                for row in csv.DictReader(stream)}
    return rows[update] - rows[update - 1]


def main() -> None:
    baseline = update_gap("state-speed5.csv.gz")
    one = update_gap("state-delay-one-s5.csv.gz")
    per_count = one - baseline
    assert per_count == 16
    print("speed  original_gap  zero_gap  delay_word")
    for speed in range(1, 6):
        original = update_gap(f"state-speed{speed}.csv.gz")
        zero = (update_gap(f"state-delay-zero-s{speed}.csv.gz")
                if speed < 5 else baseline)
        assert zero == baseline
        assert (original - zero) % per_count == 0
        print(f"{speed:5}  {original:12}  {zero:8}  "
              f"{(original - zero) // per_count:10}")


if __name__ == "__main__":
    main()
