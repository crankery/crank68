# Start an original Ladder run on displayed level N

The patched iz-cpm and [state runner](../tools/run_ladder_state.py) now accept
`--start-level N` (1–255). At the first gameplay-loop entry `$47EA` on each
board below N, the emulator redirects the CPU to the original level-advance
code at `$520C`. That code increments the displayed level word `$0F69` and
enters the original board loader at `$43A8`. The runner records updates and
sends scheduled gameplay keys only after reaching the requested board.
The original COM and DAT are copied to a temporary CP/M drive; no project
binary is changed.

For example, to start on displayed level 9 and collect 100 update samples:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-level9 --speed 1 --start-level 9 --updates 100
```

`--first-key` and `--when` apply on the selected board. A level-2 check with
`--first-key 6` read that key in its first state row and moved Lad right in
the next row. Skipped boards do not award treasure points or consume bonus;
the selected board starts with score 0 and five Lads. This is a gameplay
analysis fixture, not a claim that the original menu offers level selection.

## Verified board sequence

The [level 1–12 summary](start-levels-1-12.csv), saved state and terminal
captures for levels 1, 2, 5, 9, and 12, and runs for every intervening level
establish this sequence. Map names are matched by their visible terrain,
spawn positions, and dispenser/treasure locations against the Pascal layouts. Bonuses and
Lad positions below are from the original COM state rows.

| Displayed level | Map | Initial bonus | Lad start |
| ---: | --- | ---: | --- |
| 1 | Easy Street | 35 | `(6,19)` |
| 2 | Long Island | 45 | `(7,19)` |
| 3 | Easy Street | 33 | `(6,19)` |
| 4 | Long Island | 43 | `(7,19)` |
| 5 | Ghost Town | 33 | `(6,3)` |
| 6 | Easy Street | 31 | `(6,19)` |
| 7 | Long Island | 41 | `(7,19)` |
| 8 | Ghost Town | 31 | `(6,3)` |
| 9 | Tunnel Vision | 32 | `(77,17)` |
| 10 | Easy Street | 29 | `(6,19)` |
| 11 | Long Island | 39 | `(7,19)` |
| 12 | Ghost Town | 29 | `(6,3)` |

The map order and two-point bonus reduction through level 12 match the
Pascal rewrite's `levelCycle` progression. A simple patch to `$0F69` only
changed the HUD, as [the earlier experiment](LEVEL_DISPLAY_PATCH.md) showed.
Setting `$0F75` at the first loader entry also failed to select a map: it
changed the bonus cycle but still loaded Easy Street. Using the original
advance path preserves the loader's other state.

For an independent comparison, [two ordinary treasure transitions](state-natural-level3.csv.gz)
reached level 3 with bonus 33, Lad `(6,19)`, and the same first three rock
states as the shortcut's level-3 run. The natural run had score 78 from
the two completed levels, whereas the shortcut retained score 0. The
level 1–57 sweep below uses the shortcut. Controlled treasure completions
at three later boundaries also agree with its next-board results.

## Full seven-board waves and bonus adjustment

The [level 1–57 summary](start-levels-1-57.csv) comes from one-update
state rows and full 1,600-cell map dumps on every displayed level in that
range. [`summarize_level_cycle.py`](../tools/summarize_level_cycle.py)
compares each dump cell-for-cell against the seven original reference maps
and rejects an unknown or incomplete map. The
[capture archive](level-cycle-captures.tar.gz) preserves the raw state and
map CSVs, including the later boundary samples described below.

The original runs a **27-level wave** containing board prefixes of length
2, 3, 4, 5, 6, and 7:

| Displayed levels | Board sequence | Easy Street starting bonus |
| --- | --- | ---: |
| 1–27 | `E L`; `E L G`; `E L G T`; `E L G T P`; `E L G T P B`; `E L G T P B A` | 35, 33, 31, 29, 27, 25 |
| 28–54 | Same six prefixes | 25, 23, 21, 19, 17, 15 |
| 55–57 sampled | `E L`; then `E` of the next prefix | 15, then 13 |

Here `E` is Easy Street, `L` Long Island, `G` Ghost Town, `T` Tunnel
Vision, `P` Point of No Return, `B` Bug City, and `A` GangLand. Every
captured board uses the same original tile table as its reference map;
all 57 starting scores are zero and all 57 Lad counts are five because the
shortcut skips treasure awards. The first two complete waves show that
the board prefix length resets after GangLand, while the bonus baseline
falls by ten points per wave. At the boundary, level 27 is GangLand with
bonus 22, level 28 is Easy Street with bonus 25, level 29 is Long Island
with bonus 35, and level 30 starts the next `E L G` prefix with Easy
Street and bonus 23. Level 54 is GangLand with bonus 12; level 55 again
starts at Easy Street with bonus 15.

The compiled advance path at `$520C..$5213` increments the displayed
level and enters the original loader at `$43A8`. That loader's
`$43AE..$4408` branches select the board and apply the bonus adjustment;
the summary records its actual results. The Pascal rewrite's
`levelCycle` in `Ladder/src/ladmain.pas` continues to grow after its
seventh board, so its source predicts Easy Street bonus 23 at displayed
level 28 and Ghost Town at level 30. The original shortcut gives Easy
Street bonus 25 at 28 and Easy Street again at 30.

### Controlled GangLand treasure completions

GangLand has a treasure cell at `(62,15)` and supported empty cell
`(61,15)` immediately to its left. Starting at displayed level 27, the
fixture places Lad at `(61,15)` after update 1, then sends `6` (right) on
update 2. The unmodified movement and treasure paths take him into the
treasure, tally the remaining bonus, and load the next board before the
update-3 sample. This avoids manually jumping to the advance code at the
boundary. The traces for [27→28](state-gangland-to-level28.csv.gz),
[54→55](state-gangland-to-level55.csv.gz), and
[81→82](state-gangland-to-level82.csv.gz) give:

| GangLand level | Bonus before treasure | Next level | Score after tally | Next bonus | Next Lad start and first dispenser |
| ---: | ---: | ---: | ---: | ---: | --- |
| 27 | 22 | 28 | 22 | 25 | `(6,19)`, `(40,2)` |
| 54 | 12 | 55 | 12 | 15 | `(6,19)`, `(40,2)` |
| 81 | 2 | 82 | 2 | 5 | `(6,19)`, `(40,2)` |

The next position and dispenser match Easy Street, and each next bonus
matches the shortcut's first row. This confirms that the wave reset occurs
through normal treasure completion at all three sampled boundaries. The
fixture still places Lad near the treasure; it does not play all preceding
boards or measure whether a player can survive to these levels.

Reproduce level 27→28 with `--start-level 27 --speed 1 --updates 7
--poke-after 1:0F89:003D,1:0F8B:000F --key-at 2:36
--name gangland_to_28`. Use starting level 54 or 81 for the other two
captures. Pass these options to `tools/run_ladder_state.py` with
`--emulator` and `--output`.

Additional shortcut samples show the reset again at levels 81–82,
matching the controlled treasure run. At levels 107–109,
the raw 16-bit bonus word wraps below zero: Bug City is `65533`,
GangLand `65528`, and Easy Street `65531`. The loader subtraction at
`$4408..$4415` has no visible clamp. The
[level-109 countdown probe](BONUS_TIMEOUT_PROBES.md#negative-bonus-after-many-level-waves)
shows that the next 25-update decrement continues from this negative
signed value without costing a life. These high levels were reached by
the shortcut; ordinary-play reachability is unverified.

To repeat the level sweep, run `tools/run_ladder_state.py` once for each
desired `N` with `--start-level N --updates 1 --map --name levelN`, saving
all captures in one output directory. Then run
`python3 tools/summarize_level_cycle.py --captures OUTPUT --first 1
--last 57` and compare its CSV with the saved summary. The runner copies
COM and DAT before every capture.

Representative captures: [level 1 state](start-level1.csv.gz) and
[screen](start-level1.ansi.gz), [level 2 state](start-level2.csv.gz) and
[screen](start-level2.ansi.gz), [level 5 state](start-level5.csv.gz) and
[screen](start-level5.ansi.gz), [level 9 state](start-level9.csv.gz) and
[screen](start-level9.ansi.gz), [level 12 state](start-level12.csv.gz) and
[screen](start-level12.ansi.gz). The CSVs have ten updates each; the screen
captures are ADM-3A output translated to ANSI by iz-cpm.
