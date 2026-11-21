# Original versus Pascal map tiles

The patched emulator dumped the original game's 80×20 tile table on the
first update of displayed levels 1, 2, 5, 9, 14, 20, and 27. Those boards
match the seven Pascal layouts by their distinctive dispensers, ladders,
and terrain. The raw dumps are `tile-easy-map.csv.gz`,
`tile-long-island-map.csv.gz`, `tile-ghost-map.csv.gz`,
`tile-tunnel-vision-map.csv.gz`, `tile-point-of-no-return-map.csv.gz`,
`tile-bug-city-map.csv.gz`, and `tile-gang-land-map.csv.gz`.

[`compare_ladder_maps.py`](../tools/compare_ladder_maps.py) maps Pascal's
functional glyphs to the observed original codes: space/`p`=`0`, `-`=`1`,
`=`=`2`, `$`=`3`, `|`=`4`, `V`=`5`, `H`=`6`, `*`=`7`, `^`=`8`, `.`=`9`, and
`&`=`10`. It compares columns 1–79 of each 20-row Pascal layout with the
original table. Pascal's decorative letters are treated as empty terrain;
column 80 is excluded. The complete 58-cell mismatch list is
[map-parity.csv](map-parity.csv).

| Board | Displayed level | Terrain mismatches | Examples |
| --- | ---: | ---: | --- |
| Easy Street | 1 | 2 | Pascal `|` at `(69,9)` and `(77,9)`; original empty. |
| Long Island | 2 | 28 | Pascal floor at `(1,18)`–`(14,18)`; original empty. Several edge floor and vertical-bar cells also differ. |
| Ghost Town | 5 | 4 | Pascal lower flames at `(33,18)` and `(32,19)`–`(34,19)`; original empty. |
| Tunnel Vision | 9 | 0 | No difference among the compared cells. |
| Point of No Return | 14 | 4 | Pascal `*` at `(75,19)`; original fire code `8`. Pascal floor at `(74,17)`; original empty. The title letters at `(73,19)` and `(74,19)` conceal an original eater and fire cell. |
| Bug City | 20 | 1 | Original floor at `(24,9)` where Pascal has space. |
| GangLand | 27 | 19 | Nine Pascal `&` statue cells at X=65–69, Y=9–11 are empty in the original. Eight title letters at X=22–25 and 27–30, Y=1 conceal original floor. Original also has a floor and a trampoline where Pascal has spaces. |

The Point of No Return mismatch affects Lad directly. A controlled fixture
places him above `(75,19)` after update 1. On the next update, the original
game takes a life and restarts level 14 with score preserved; see
[the contact trace](state-point-fire-versus-eater.csv.gz). The original
code's tile-`8` death branch at `$50B3` explains that result. Pascal's `*`
there is a rock eater and would not have the same effect on Lad.

The missing GangLand statues also change scoring. In a
[controlled movement trace](state-gangland-missing-statues.csv.gz), Lad
starts at `(64,11)` with score `42`, then walks right through X=65–69 on
updates 3–7. Pascal has five `&` cells along that row, but the original
score remains `42` at each cell. The original tile dump marks them all
empty, consistent with the direct run. The fixture uses `--start-level 27`,
`--poke-after 1:0F89:0040,1:0F8B:000B,1:0F05:002A`, and `--key-at 2:36`.

Long Island's missing lower floor changes falling. The original tile table
has code `0` at `(7,18)`, while Pascal has `=`. A controlled placement at
`(7,17)` with downward status `2` falls to `(7,18)` and then `(7,19)` on
the next two updates before stopping; see
[the gap trace](state-long-gap-fall.csv.gz). The
[supported control](state-long-supported-fall.csv.gz) starts at `(7,15)`
above original floor code `2` at `(7,16)` and remains at row 15. Pascal's
floor at `(7,18)` would support Lad at row 17 instead.

The sampled repeat boards use identical original tile codes: displayed
level 3 matches Easy Street level 1, level 4 matches Long Island level 2,
and Ghost Town levels 8 and 12 both match level 5 across all 1,600 dumped
cells. Their saved dumps are `tile-easy-repeat-3.csv.gz`,
`tile-long-repeat-4.csv.gz`, `tile-ghost-repeat-8.csv.gz`, and
`tile-ghost-repeat-12.csv.gz`. Later repeats remain untested. The comparison
covers all 79 Pascal columns, including decorative text. Re-run it with:

```sh
python3 tools/compare_ladder_maps.py > analysis/map-parity.csv
```
