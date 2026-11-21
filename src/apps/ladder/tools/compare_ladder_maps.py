#!/usr/bin/env python3
"""Report terrain differences between original Ladder and Pascal maps."""

import csv
import gzip
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
BOARDS = (
    ("Easy Street", 1, "tile-easy-map.csv.gz"),
    ("Long Island", 2, "tile-long-island-map.csv.gz"),
    ("Ghost Town", 5, "tile-ghost-map.csv.gz"),
    ("Tunnel Vision", 9, "tile-tunnel-vision-map.csv.gz"),
    ("Point of No Return", 14, "tile-point-of-no-return-map.csv.gz"),
    ("Bug City", 20, "tile-bug-city-map.csv.gz"),
    ("GangLand", 27, "tile-gang-land-map.csv.gz"),
)
TILE = {
    " ": 0, "-": 1, "=": 2, "$": 3, "|": 4,
    "V": 5, "H": 6, "*": 7, "^": 8, ".": 9,
    "&": 10, "p": 0,
}


def pascal_layouts() -> dict[str, list[str]]:
    source = (ROOT / "Ladder/src/ladicons.pas").read_text()
    parts = re.split(r"Name : '([^']+)';", source)[1:]
    result = {}
    for name, body in zip(parts[::2], parts[1::2]):
        rows = re.findall(r"^\s*'(.{79})'[,)]?\s*$", body, re.MULTILINE)
        if len(rows) != 20:
            raise ValueError(f"{name}: expected twenty 79-cell rows, got {len(rows)}")
        result[name] = rows
    return result


def original_tiles(filename: str, level: int) -> dict[tuple[int, int], int]:
    with gzip.open(ROOT / "analysis" / filename, "rt") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) != 1600 or any(int(row["level"]) != level for row in rows):
        raise ValueError(f"{filename}: wrong map size or displayed level")
    return {(int(row["x"]), int(row["y"])): int(row["tile"], 16)
            for row in rows}


def main() -> None:
    layouts = pascal_layouts()
    writer = csv.writer(sys.stdout)
    writer.writerow(("board", "displayed_level", "x", "y", "pascal_tile",
                     "expected_code", "original_code"))
    for name, level, filename in BOARDS:
        tiles = original_tiles(filename, level)
        for y, row in enumerate(layouts[name], 1):
            for x, char in enumerate(row, 1):
                # Pascal prints level names in otherwise empty map cells.
                # A printed letter may conceal original terrain underneath.
                expected = TILE.get(char, 0)
                if tiles[x, y] != expected:
                    writer.writerow((name, level, x, y, char,
                                     expected, tiles[x, y]))


if __name__ == "__main__":
    main()
