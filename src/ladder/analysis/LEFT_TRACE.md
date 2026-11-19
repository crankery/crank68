# Right, up, left: fall and branch coverage

I ran the original CP/M `LADDER.COM` in instrumented iz-cpm, using temporary
copies of the COM and DAT files. The emulator supplied three one-shot keys
at the game's level-one poll site `$47ED`:

1. `6` at the first game poll, to run right.
2. `8` after the output drew the lad at row 19, column 58, to climb.
3. `4` after the output drew the lad at row 15, column 58, to run left.

The output-position triggers make the turn repeatable despite variations in
host timing. The injection points are in `left-injections.log`.

## What happened on screen

The lad is rendered as `p` while moving right or up, `q` while moving left,
and `b` while falling. The recovered Pascal port assigns those same glyphs
to those movement states, but the frames here come from the original game.

| Frame | Position and event |
| --- | --- |
| [Top of ladder](left-top.txt) | `p` at row 15, column 58 |
| [Edge of gap](left-gap.txt) | `q` at row 15, column 48 |
| [Falling](left-fall.txt) | `b` at row 17, column 48 |
| [Landed](left-land.txt) | `q` at row 19, column 47 |
| [Approaching rocks](left-rocks.txt) | `q` at row 19, column 20; `o` rocks at columns 16–17 |
| [Rock approaches lad](left-near-hit.txt) | `q` at row 19, column 1; `o` at column 2 |

The rock at column 26 in the earlier climb-only text capture is absent from
this fresh run's top-of-ladder frame; the moving rocks vary between runs.
After landing, the lad and the first bottom-row rocks travel left together:
at cursor frame 1200, `q` is at column 20 and rocks are at 16–17; at frame
1350, `q` is at 7 and rocks are at 4–5. Those rocks reach the left-edge `*`
and disappear. The lad then remains at column 1. Another rock approaches
from column 25 at frame 1500 to column 2 in the final linked capture. The lad
changes to `b` at column 1 in the next frame, and the
life counter changes from five to four soon after. This supports a collision
with the later rock, though the trace does not instrument the collision test.
The recovered Pascal instructions call the rolling `o` enemies **Der Rocks**;
`*` are rock eaters.

The full display stream is `left-run.ansi.gz`. The linked `.txt` files
preserve each frame's 80-by-24 character cells.

## Executed game-to-runtime calls

| Run | Instructions | Transfers | Sites | Targets |
| --- | ---: | ---: | ---: | ---: |
| No movement | 80,844,470 | 1,155,421 | 367 | 55 |
| Right (`6`) | 76,420,900 | 1,151,436 | 371 | 56 |
| Right, up (`6`, `8`) | 93,695,262 | 1,144,898 | 372 | 56 |
| Right, up, left (`6`, `8`, `4`) | 77,218,862 | 1,012,269 | 373 | 56 |

Each run includes every distinct site reached by the preceding run. Four
sites appeared with the first `6` (see [KEY_TRACE.md](KEY_TRACE.md)). Climbing
added `$4CD8 → $768E`; running left and falling added `$4D44 → $768E`.
Both sites were in the earlier static byte scan but not previously confirmed
by execution. No new runtime target appeared beyond the rightward run.

The nearby instructions give a useful clue about vertical motion:

```text
$4CCE  LD HL,($0FB6)   $4D3A  LD HL,($0FB6)
$4CD1  DEC HL          $4D3D  INC HL
$4CD2  LD ($0FB6),HL   $4D3E  LD ($0FB6),HL
$4CD5  LD HL,($0FB6)   $4D41  LD HL,($0FB6)
$4CD8  CALL $768E      $4D44  CALL $768E
```

At `$4CD8`, the first four observed HL values were `$0012`, `$0011`,
`$0010`, `$000F` during ascent. At `$4D44`, they were `$0010`, `$0011`,
`$0012`, `$0013` during the fall. This strongly connects `$0FB6` with a
proposed vertical position. Runtime routine `$768E` [multiplies HL by the inline word `$0051`](MULTIPLY_INLINE.md) at these sites, giving an 81-cell row offset.

These figures count only executed direct transfers from compiled game code
into the linked runtime. They are a useful branch-coverage proxy, not total
CPU branch coverage. Transfer counts vary with run duration; distinct sites
are the meaningful comparison here.

`climb_sites.csv` and `left_sites.csv` give per-site counts and first register
snapshots; matching `_targets.csv` files aggregate runtime targets. The full
event streams are `climb-session-2026-11-18.csv.gz` and
`left-session-2026-11-18.csv.gz`. `iz_cpm_ladder.patch` contains all three
input triggers and the selective call logger for iz-cpm commit
`5f6ee4d856bea1a17b4362badc178a181feddaa7`.

To repeat the leftward run after applying the patch and building iz-cpm:

```sh
iz-cpm --terminal adm3a --disk-a . --ladder-calls calls.csv \
  --ladder-inject-key 6 --ladder-inject-up-at-58 \
  --ladder-inject-left-at-top LADDER.COM >terminal.out 2>inject.log
```

Press `P` at the menu. Run from a directory containing copies of `LADDER.COM`
and `LADDER.DAT`, since the game writes the high-score file.
