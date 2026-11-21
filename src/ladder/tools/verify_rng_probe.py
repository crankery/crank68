#!/usr/bin/env python3
"""Verify original Ladder's RNG recurrence and integer-choice traces."""

import bisect
import csv
import gzip
import io
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "analysis"
MASK = (1 << 24) - 1


def read_gzip(name: str) -> list[dict[str, str]]:
    with gzip.open(ROOT / name, "rt", newline="") as stream:
        return list(csv.DictReader(stream))


def state(row: dict[str, str]) -> int:
    return (int(row["seed_6805"], 16) << 16) | int(row["seed_6807"], 16)


def check_recurrence(rows: list[dict[str, str]]) -> int:
    assert len(rows) % 2 == 0
    for before, after in zip(rows[::2], rows[1::2]):
        assert (before["pc"], after["pc"]) == ("6C31", "6C77")
        assert state(after) == (5 * state(before) + 3) & 0xFFFFFFFF
    return len(rows) // 2


def result_from_state(value: int, choices: int, offset: int) -> int:
    return ((value & MASK) * choices >> 24) + offset


def main() -> None:
    rng = read_gzip("ghost-rng-s3-400.rng.csv.gz")
    zero = read_gzip("seed-zero.rng.csv.gz")
    print("RNG calls checked:", check_recurrence(rng) + check_recurrence(zero))

    post = [row for row in rng if row["pc"] == "6C77"]
    steps = [int(row["instructions"]) for row in post]
    events = read_gzip("ghost-rng-s3-400.rock.csv.gz")
    site_rules = {"474F": (3, 1), "496C": (3, 0), "4A63": (2, 3)}
    checked = {site: 0 for site in site_rules}
    for row in events:
        site = row["pc"]
        if row["level"] != "0005" or site not in site_rules:
            continue
        index = bisect.bisect_right(steps, int(row["instructions"])) - 1
        assert index >= 0
        choices, offset = site_rules[site]
        assert int(row["result"], 16) == result_from_state(
            state(post[index]), choices, offset)
        checked[site] += 1
    print("Choice events checked:", checked)

    boundaries = {
        "third_lo": (1, "474F", 0x12555555, 1),
        "third_hi": (1, "474F", 0x12555556, 2),
        "two_thirds_lo": (1, "474F", 0x12AAAAAA, 2),
        "two_thirds_hi": (1, "474F", 0x12AAAAAB, 3),
        "half_lo": (9, "4A63", 0x127FFFFF, 3),
        "half_hi": (9, "4A63", 0x12800000, 4),
    }
    with tarfile.open(ROOT / "rng-boundary-captures.tar.gz", "r:gz") as archive:
        for name, (update, site, expected_state, expected_choice) in boundaries.items():
            rng_member = archive.extractfile(f"{name}.rng.csv")
            rock_member = archive.extractfile(f"{name}.rock.csv")
            assert rng_member is not None and rock_member is not None
            rng_rows = list(csv.DictReader(io.TextIOWrapper(rng_member)))
            rock_rows = list(csv.DictReader(io.TextIOWrapper(rock_member)))
            check_recurrence(rng_rows)
            post_rows = [row for row in rng_rows
                         if row["pc"] == "6C77" and
                         int(row["completed_updates"]) == update]
            choices = [row for row in rock_rows
                       if row["pc"] == site and
                       int(row["completed_updates"]) == update and
                       row["level"] == "0005"]
            assert len(post_rows) == len(choices) == 1
            assert state(post_rows[0]) == expected_state
            assert int(choices[0]["result"], 16) == expected_choice
    print("Boundary cases checked:", len(boundaries))

    low = 0
    for period in range(1, (1 << 24) + 1):
        low = (5 * low + 3) & MASK
        if low == 0:
            break
    assert period == 1 << 24
    print("Low-24-bit period:", period)


if __name__ == "__main__":
    main()
