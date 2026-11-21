#!/usr/bin/env python3
"""Check original trampoline choices against saved RNG traces."""

import bisect
import csv
import io
import tarfile
from pathlib import Path

from verify_rng_probe import check_recurrence, result_from_state, state


ARCHIVE = Path(__file__).resolve().parents[1] / "analysis/trampoline-rng-captures.tar.gz"
EXPECTED = {
    "moving-s1": (1, None),
    "moving-s2": (2, None),
    "moving-s5": (0, None),
    "third_lo": (0, 0x12555555),
    "third_hi": (1, 0x12555556),
    "two_thirds_lo": (1, 0x12AAAAAA),
    "two_thirds_hi": (2, 0x12AAAAAB),
}


def read_member(archive: tarfile.TarFile, name: str) -> list[dict[str, str]]:
    stream = archive.extractfile(name)
    assert stream is not None
    return list(csv.DictReader(io.TextIOWrapper(stream)))


def main() -> None:
    calls = 0
    with tarfile.open(ARCHIVE, "r:gz") as archive:
        for name, (expected_choice, expected_state) in EXPECTED.items():
            rng = read_member(archive, f"{name}.rng.csv")
            tiles = read_member(archive, f"{name}.tile.csv")
            calls += check_recurrence(rng)
            assert len(tiles) == 1
            event = tiles[0]
            assert event["pc"] == "50D6"
            post = [row for row in rng if row["pc"] == "6C77"]
            steps = [int(row["instructions"]) for row in post]
            index = bisect.bisect_right(steps, int(event["instructions"])) - 1
            assert index >= 0
            value = state(post[index])
            choice = int(event["result"], 16)
            assert choice == expected_choice == result_from_state(value, 3, 0)
            if expected_state is not None:
                assert value == expected_state
            print(name, f"state={value:08X}", f"choice={choice}")
    print(f"Verified {len(EXPECTED)} trampoline choices and {calls} RNG calls")


if __name__ == "__main__":
    main()
