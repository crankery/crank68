# Original Ladder fire and map probes

The [Ghost Town tile dump](tile-ghost-map.csv.gz) records tile code `8` at
`(20,8)`. The Pascal layout has `^` at that coordinate, identifying code `8`
as fire in this case. The original table has empty tile `0` at `(20,7)`.

The [fire contact trace](state-ghost-fire-fall.csv.gz) starts displayed level
5 and, after update 1, places Lad at `(20,7)` with downward movement status
`2` and score `42`. On the next update, the original movement and death code
run; the sampled state is back at the level start `(6,3)` with Lads `5→4`,
bonus restored to `33`, score still `42`, and displayed level still `5`.
This confirms fire contact costs a Lad and restarts the same board without
changing score. The compiled destination-tile check at `$50AA..$50B3`
compares against tile code `8` and branches to the common death path at
`$5216`, matching the trace.

Reproduce the fixture with the patched emulator:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-fire --speed 1 --start-level 5 --updates 8 \
  --poke-after 1:0F89:0014,1:0F8B:0007,1:0F9F:0002,1:0F05:002A \
  --name ghost-fire-fall
```

The tile dump also exposes a map difference. The Pascal Ghost Town layout
has `^` at `(33,18)` and `(32,19)`–`(34,19)`, but the original Ghost Town
tile table has code `0` at all four cells. Both maps have the 22-flame band
on row 8. This difference is relevant to later gameplay on the lower part
of the board. The [seven-board comparison](MAP_PARITY.md) found more
functional tile differences and separately confirmed a lethal Point of No
Return fire cell where Pascal shows a rock eater.
