# Original Ladder disposable floor

On Tunnel Vision, tile code `1` is disposable floor (`-`). The
[tile dump](tile-tunnel-vision-map.csv.gz) has code `1` at `(25,8)` and
`(26,8)`, code `2` at `(24,8)`, and empty cells above and below the strip.

The player movement path at `$4DA1..$4DDF` checks the tile one row below
Lad's **old** horizontal position. If it is code `1`, it writes zero to
that map cell. The branch to this path is reached when Lad leaves the old
position horizontally. This matches the Pascal rewrite's `x <> lad.X` and
`y = lad.Y` test in `ladmain.pas`.

The [return trace](state-disposable-floor-return.csv.gz) starts displayed
level 9 and, after update 1, places Lad at `(24,7)` moving right. Lad reaches
`(25,7)` on update 2 and `(26,7)` on update 3; the floor at `(25,8)` is
removed as Lad leaves it. A left key on update 3 reverses horizontal motion.
Lad returns to `(25,7)` on update 4, then falls to `(25,8)` on update 5 and
`(25,9)` on update 6. Thus the disposable tile supports Lad while standing
on it and disappears when Lad moves horizontally away, leaving a hole on
return. The fall starts on the update after Lad returns to the now empty
position.

Reproduce with the patched emulator:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-floor --speed 1 --start-level 9 --updates 9 \
  --poke-after 1:0F89:0018,1:0F8B:0007,1:0F9D:0004,1:0F9F:0004 \
  --key-at 3:34 --name floor-return
```

This branch and trace confirm the rule for an ordinary horizontal departure
and return. The Pascal rewrite uses the same condition. FLEX now clears the
departed tile in its ordinary sideways movement path; the assembled CPU
probe checks the return fall.

## Jump from a disposable floor

Two more fixtures start Lad at `(25,7)` and inject space on update 2. In the
[stationary-jump trace](state-disposable-floor-jump-still.csv.gz), Lad rises
and lands back at `(25,7)` on update 8, then remains supported through
update 12. Jumping straight up leaves the disposable tile in place.

In the [running-jump trace](state-disposable-floor-jump-moving.csv.gz), Lad
starts moving right. Update 2 moves him from `(25,7)` to `(26,7)` and arms
the six-step jump. After the jump completes, the fixture places him back at
`(25,7)` following update 8. On update 9 he falls to `(25,8)`, then to
`(25,9)` on update 10: the horizontal departure removed the floor even
though Lad was starting a jump. The corresponding stationary-jump fixture
uses the same return placement and does not fall.

Reproduce either capture by using `--start-level 9 --speed 1 --updates 12`,
`--key-at 2:20`, and the following placement after updates 1 and 8:

```text
still:  1:0F89:0019,1:0F8B:0007,1:0F9D:0000,1:0F9F:0000,8:0F89:0019,8:0F8B:0007,8:0F9D:0000,8:0F9F:0000
moving: 1:0F89:0019,1:0F8B:0007,1:0F9D:0004,1:0F9F:0004,8:0F89:0019,8:0F8B:0007,8:0F9D:0000,8:0F9F:0000
```

These cases show that the ordinary horizontal step before a running jump
consumes its floor. A pure vertical jump preserves the floor. Both match the
Pascal rewrite's horizontal-departure test.

## Sideways motion during a jump apex

The [apex departure trace](state-disposable-apex-depart.csv.gz) places Lad
at Tunnel Vision `(25,7)` moving right. Space on update 2 arms the jump.
At update 4 he is at `(28,5)`; the fixture puts a disposable tile at
`(28,6)`. Update 5 moves Lad sideways to `(29,5)` at the jump's flat apex.
After the jump ends, placing him back at `(28,5)` after update 8 leaves him
supported at that row on updates 9–11. The
[removed-floor control](state-disposable-apex-removed-control.csv.gz) also
clears `(28,6)` after update 5; Lad falls to `(28,6)` on update 9 and
`(28,7)` on update 10. The original jump path therefore does **not** consume
a disposable floor during a same-row apex step. It uses the ordinary
horizontal departure path for floor removal, rather than every X change.

Reproduce both with `--start-level 9 --speed 1 --updates 11`,
`--key-at 2:20`, and `--poke-after
1:0F89:0019,1:0F8B:0007,1:0F9D:0004,1:0F9F:0004,4:050E:0001,8:0F89:001C,8:0F8B:0005,8:0F9D:0000,8:0F9F:0000`.
For the control add `5:050E:0000` to the poke list. FLEX's assembled
`move_jump` preserves the tile in a CPU probe; Pascal's `x <> lad.X` and
`y = lad.Y` condition appears to predict removal at the apex, a difference
from the original.

## Climb vertically away from a disposable floor

A controlled Tunnel Vision fixture adds temporary ladder code `6` at
`(25,7)` and `(25,6)` above the existing disposable tile `(25,8)`.
After update 1, Lad is placed at `(25,7)` with an up request. He climbs to
`(25,6)` on update 2. The fixture then removes the temporary ladder at
`(25,7)` and returns Lad there stopped. In the
[climb trace](state-disposable-climb-floor-kept.csv.gz), he stays at
`(25,7)` on updates 3–5, supported by the preserved disposable floor.
The [floor-removed control](state-disposable-climb-floor-removed-control.csv.gz)
also clears `(25,8)` after update 2; Lad falls to `(25,8)` and `(25,9)` on
updates 3–4. The control shows the return state would expose a missing tile.

Reproduce with `--start-level 9 --speed 1 --updates 5` and these
`--poke-after` entries (map words use address `$010A+2*(x+81*y)`):

```text
1:0F89:0019,1:0F8B:0007,1:0F9D:0001,1:0F9F:0001,1:0508:0006,1:05AA:0006,2:05AA:0000,2:0F89:0019,2:0F8B:0007,2:0F9D:0000,2:0F9F:0000
```

Add `2:064C:0000` for the floor-removed control. The result confirms that
vertical climbing leaves the disposable tile intact. Pascal's `x <> lad.X`
condition has the same consequence; FLEX's ordinary sideways path clears
the tile, while its vertical climb leaves the tile intact.

## Removed floor survives a life restart

A controlled Tunnel Vision fixture starts Lad at `(25,7)` moving right.
Update 2 moves him to `(26,7)` and removes the disposable floor at
`(25,8)`. In the [timeout restart trace](state-floor-timeout-restart.csv.gz),
the fixture then sets bonus and its countdown counter to 1, causing a
life loss and same-board restart on update 3. It places Lad back at
`(25,7)` after that update. He falls to `(25,8)` on update 4 and
`(25,9)` on update 5: the removed floor was **not restored**. A
[no-restart control](state-floor-no-restart-control.csv.gz) has the same
fall, while an [intact-floor timeout control](state-floor-intact-timeout-control.csv.gz)
does not remove the floor before death and remains supported after the
same restart.

A second [fire restart trace](state-floor-fire-restart.csv.gz) removes the
floor on update 2, injects fire code `8` at `(27,7)`, and lets Lad walk
into it on update 3. After the fire death and return to `(25,7)`, he
again falls through the missing floor on updates 4–5. Both death paths
therefore preserve the current board's mutable terrain. They still reset
Lad and the bonus clock, as the separate death probes show.

For the timeout fixture, use `--start-level 9 --speed 1 --updates 6`
and `--poke-after
1:0F89:0019,1:0F8B:0007,1:0F9D:0004,1:0F9F:0004,2:0F77:0001,2:0FA1:0001,3:0F89:0019,3:0F8B:0007,3:0F9D:0000,3:0F9F:0000`.
For the fire fixture replace the two update-2 timer pokes with
`2:05AE:0008`. The intact control starts with direction and request `0`
instead of `4`. Pass the options to `tools/run_ladder_state.py` with
`--emulator`, `--output`, and `--name`.

Pascal's `restartLevel` label is below `newLevel: LoadMap`, so a life
restart redraws the current `m.Field` without reloading the level layout.
That matches the original persistence. FLEX's current fire reset likewise
keeps the mutated map in RAM; an assembled CPU probe confirms its removed
floor stays absent after the reset. A future FLEX new-level path must
create a fresh mutable map for the next board.
