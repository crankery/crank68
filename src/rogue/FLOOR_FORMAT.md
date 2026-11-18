# ROGUE floor files

`generate_floors.py` creates `RFL01.DAT` through `RFL26.DAT` during the FLEX
disk build. They are binary files on drive 1. The generator uses a fixed seed,
so rebuilding produces the same 26 floor layouts.

| Offset | Bytes | Meaning |
| --- | ---: | --- |
| 0 | 4 | ASCII `RFL1` format marker |
| 4 | 1 | Depth, 1–26 |
| 5 | 1 | Upstairs room number, 0–8 |
| 6 | 1 | Downstairs room number, 0–8 |
| 7 | 54 | Nine records of left, right, top, bottom, centre x, centre y |
| 61 | 1200 | 60×20 row-major map tiles |
| 1261 | 1 | XOR of bytes 4–1260 |

Room and map coordinates are zero based. The screen boundary remains empty.
The map contains walls (`-`, `|`), doors (`+`), corridors (`#`), floor (`.`),
gold (`*`), upstairs (`<`), and downstairs (`%`). The upstairs room on floor
`n+1` equals the downstairs room on floor `n`.

These files are read-only terrain. The current game keeps discovered cells and
collected gold in RAM. A future save format will need separate mutable state
and a version for it.
