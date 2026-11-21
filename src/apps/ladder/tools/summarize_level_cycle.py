#!/usr/bin/env python3
"""Compare captured original levels with the seven reference tile maps."""

import argparse
import csv
import gzip
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REFERENCE_MAPS = {
    "Easy Street": "tile-easy-map.csv.gz",
    "Long Island": "tile-long-island-map.csv.gz",
    "Ghost Town": "tile-ghost-map.csv.gz",
    "Tunnel Vision": "tile-tunnel-vision-map.csv.gz",
    "Point of No Return": "tile-point-of-no-return-map.csv.gz",
    "Bug City": "tile-bug-city-map.csv.gz",
    "GangLand": "tile-gang-land-map.csv.gz",
}


def read_tiles(path: Path) -> tuple[tuple[int, int, int], ...]:
    opener = gzip.open if path.suffix == ".gz" else open
    with opener(path, "rt", newline="") as source:
        tiles = tuple(sorted((int(row["x"]), int(row["y"]),
                              int(row["tile"], 16))
                             for row in csv.DictReader(source)))
    if len(tiles) != 1600 or len({(x, y) for x, y, _ in tiles}) != 1600:
        raise ValueError(f"{path}: expected 1600 unique cells")
    return tiles


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--captures", type=Path, required=True)
    parser.add_argument("--first", type=int, default=1)
    parser.add_argument("--last", type=int, default=57)
    args = parser.parse_args()
    if args.first < 1 or args.last < args.first:
        parser.error("choose a positive first level and last >= first")

    names = {read_tiles(ROOT / "analysis" / filename): name
             for name, filename in REFERENCE_MAPS.items()}
    writer = csv.writer(sys.stdout, lineterminator="\n")
    writer.writerow(("display_level", "board", "bonus_word", "player_x",
                     "player_y", "score", "lads"))
    for level in range(args.first, args.last + 1):
        stem = args.captures / f"level{level}"
        tiles = read_tiles(stem.with_suffix(".map.csv"))
        if tiles not in names:
            raise ValueError(f"level {level}: map differs from all seven references")
        with stem.with_suffix(".csv").open(newline="") as source:
            state = next(csv.DictReader(source))
        if int(state["level"], 16) != level:
            raise ValueError(f"level {level}: state row has level {state['level']}")
        writer.writerow((level, names[tiles], int(state["bonus"], 16),
                         int(state["player_x"], 16),
                         int(state["player_y"], 16),
                         int(state["score"], 16), int(state["lads"], 16)))


if __name__ == "__main__":
    main()
