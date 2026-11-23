# Original Ladder scoring probes

The original `LADDER.COM` keeps the numeric score in the word at `$0F05`.
The [state logger](STATE_TRACE.md) samples it after each game update. The
first controlled award is the Easy Street statue at `(17,9)`.

To reach it from the start, the capture sends `6` at the first gameplay poll,
then the following ordered one-shot keys at the listed coordinates:

| Position | Key | Purpose |
| --- | --- | --- |
| `(58,19)` | `8` | Climb the first ladder |
| `(58,15)` | `4` | Travel left across the upper platform |
| `(50,15)` | Space | Jump the first gap |
| `(27,15)` | Space | Jump the second gap |
| `(17,15)` | `8` | Climb to the short ladder's top |
| `(17,11)` | Space | Jump through the gap to the statue |

The [control trace](state-statue-route.csv.gz) omits the last space. Lad
reaches `(17,11)` and stops there, with score 0. In the [statue
trace](state-statue-route-jump.csv.gz), space is read at update 102, Lad
reaches `(17,9)` at update 104, and the score changes from 0 to 31 on that
same update. Bonus is 31 before and after the award. It had fallen from 32
to 31 on update 100. The score stays 31 while Lad remains at the statue
cell on updates 105–106, showing the award is not repeated on those updates.

Compiled code at `$5069..$507D` tests the destination tile and adds the
current bonus word `$0F77` to score `$0F05`. The following code clears the
tile. The observed position, exact score delta, and unchanged bonus confirm
that the statue pays the **remaining bonus once**. This agrees with the
Pascal rewrite's `ScoreStatue` path. FLEX now awards the remaining bonus for
statues and treasure; rock-jump points and extra-Lad awards remain open.

The [map comparison](MAP_PARITY.md) shows that Pascal's GangLand layout has
nine statues absent from the original tile table. A controlled walk through
five of those cells leaves the original score unchanged; matching the
statue award formula therefore also requires matching the original board's
statue locations.

### Collected statue survives a life restart

The [collected-then-timeout trace](state-statue-collected-then-timeout.csv.gz)
places Lad below Bug City's statue at `(52,15)`. He climbs into it on
update 2, scores 29, and the tile is cleared. A forced bonus expiry on
update 3 costs one Lad and restarts the same board with score 29. The
fixture places him below the former statue afterward; Up cannot enter
that now-empty cell on updates 4–6, and score stays 29. In the paired
[intact-then-timeout control](state-statue-intact-then-timeout.csv.gz),
Lad does not collect the statue before the same restart. He reaches
`(52,15)` on update 4 and receives 29 points. The control confirms the
restart does not itself disable statue scoring; the earlier collection
remains in the mutable board.

Reproduce either with `--start-level 20 --speed 1 --updates 6` and
`--poke-after
1:0F89:0034,1:0F8B:0010,1:0F9D:0001,1:0F9F:0001,2:0F77:0001,2:0FA1:0001,3:0F89:0034,3:0F8B:0010,3:0F9D:0001,3:0F9F:0001`.
For the intact control, set the two update-1 direction words to `0000`.
The Pascal `restartLevel` path also reuses `m.Field` without calling
`LoadMap`, so it preserves collected statues. FLEX now scores statues and
keeps its mutable field on a life restart.

## Extra Lads at score thresholds

Two otherwise identical statue captures set the score word just after update
100, before the statue is collected on update 104. The fixture writes only
the score word; gameplay movement, the 31-point bonus, and the award path
remain original code.

| Trace | Set score after update 100 | Score after statue | Lads after statue |
| --- | ---: | ---: | ---: |
| [Below threshold](state-statue-score99.csv.gz) | 68 | 99 | 5 |
| [At threshold](state-statue-score100.csv.gz) | 69 | 100 | 6 |

This verifies the first extra-Lad threshold is **100 internal score points**,
inclusive. Code at `$5706..$5750` refreshes the score, compares it with the
threshold word `$0F6D`, increments the Lad word `$0F67`, and advances the
threshold by 100. The menu-play setup at `$4387..$438A` initializes that
threshold to 100. The Pascal rewrite also starts at 100 and advances in
100-point steps; FLEX currently has no extra-Lad implementation.

One large award does **not** grant a Lad for every threshold it crosses.
The [300-point statue fixture](state-statue-cross-300.csv.gz) sets score to
zero and bonus to 300 after update 100, then follows the same unmodified
statue route. On update 104, score jumps `0→300`, but Lads rise only `5→6`;
they remain at 6 on later samples. The `$5706..$5768` routine has a single
score-versus-threshold branch, advances the next threshold from 100 to 200,
and returns after incrementing Lads once. Pascal's `UpdateScore` also uses
one `IF` after the event, so it has the same one-Lad-per-award limit. FLEX
has no corresponding score path yet.

Points awarded during rock movement can reach a threshold before the extra
Lad is awarded.
The [rock-cross-100 state trace](state-rock-cross-100.csv.gz) starts the
controlled jump-over fixture with score 98. The rock-movement `$56FC` write
raises score to 100 between updates 2 and 3, but update 3 still has five
Lads. The player-movement `$56AF` write raises score to 102 between updates 3
and 4; the `$4ECA` call to the threshold routine then grants the Lad, so
update 4 has six. The [write log](score-events-rock-cross-100.csv.gz)
preserves both sites. Pascal's `Collision` calls `UpdateScore(ScoreRock)`
for each award, and that procedure checks the threshold immediately; its
first two-point award would grant the Lad at score 100. FLEX has no rock
scoring or life threshold yet.

## Treasure and the next threshold

The [treasure fixture](state-treasure-from-below.csv.gz) plays normally to
the `(58,19)` ladder base. After update 53 it writes `$0F8B=2`, placing Lad
at `(58,2)` while the `8` climb request is active. The original movement
code then takes the final step into the treasure at `(58,1)`. At update 53,
score is 0, bonus 33, level 1. The next state row is level 2 with score 33
and the new level's bonus 45. Code at `$51AB..$51B6` decrements the old
bonus and increments score once per point during the level-completion tally.
The tally occurs between state samples, so the CSV shows its net effect;
the compiled loop establishes the per-point mechanism. This confirms that
remaining bonus points transfer to score on completion.
The later [GangLand completion probes](START_LEVEL_CHEAT.md#controlled-gangland-treasure-completions)
repeat the same transfer with remaining bonuses 22, 12, and 2 at the
three sampled wave boundaries.

The [combined threshold fixture](state-threshold-200-treasure.csv.gz) sets
the pre-statue score to 169 after update 100. The 31-point statue yields
score 200 and Lads 5→6 on update 104. After update 110 it places Lad at
`(58,2)` with upward movement active. The treasure tally adds the remaining
31 points: the next row has score 231, level 2, and Lads 6→7. Thus the
next scoring event crosses the advanced 200-point threshold and awards
another Lad. The fixture changes setup words at recorded update boundaries;
the score changes and life awards themselves run in the unmodified COM.

## Rock jump points and collision order

The [jump-over fixture](state-rock-under-jump.csv.gz) presses space at
`(6,19)` on update 1. After update 2 it moves rock slot 1 to `(7,19)` with
leftward status `3`; Lad is then at `(6,18)` and rising. On update 3 the
rock reaches `(6,19)` while Lad is at `(6,17)`, and score rises 0→2. On
update 4 the rock rolls to `(5,19)` and score rises 2→4. The
[one-column-offset control](state-rock-offset-control.csv.gz) starts the
rock at `(8,19)`: the same two awards shift to updates 4 and 5, exactly
when the rock reaches and then leaves Lad's column.

The [score-site log](score-events-rock-under-jump.csv.gz) records the first
write at `$56FC` between updates 2 and 3, with working rock coordinates
`(6,19)` and new score 2. It records the second at `$56AF` between updates
3 and 4, with new score 4. The [offset log](score-events-rock-offset-control.csv.gz)
shows the same two write sites one update later. Calls to the `$56FC` path
come from the rock update at `$4B9C/$4BC8`; the `$56AF` path is reached
from player movement at `$4E85/$4EBF`. Thus a single pass can award **two
points twice**, once when the rock arrives beneath Lad and again when the
player-side check sees it there on the next update. This is a confirmed
original-game behavior, not a deduplicated jump event.

For a lethal control, [placing the rock directly in Lad's rising cell](state-rock-same-cell.csv.gz)
after update 2 causes Lads 5→4 at update 3 and score remains 0. The
[score-site log](score-events-rock-same-cell.csv.gz) is empty. This
establishes that exact cell overlap is lethal in this fixture, while a rock
two rows below awards points. Other relative heights and simultaneous
player/rock movement cases still need tests.

The [one-row separation fixture](state-rock-one-row.csv.gz) moves the same
leftward rock into Lad's X=6 column one update earlier. At update 2, Lad is
`(6,18)` and the rock is `(6,19)`: score rises `0→2`. At update 3, Lad is
`(6,17)`, the rock has moved to `(5,19)`, and score rises `2→4`. The
[site log](score-events-rock-one-row.csv.gz) records `$56FC` for the first
award and `$56AF` for the second. Starting the rock one column farther right
shifts both awards to updates 3 and 4 in the
[offset control](state-rock-one-row-offset.csv.gz) and its
[site log](score-events-rock-one-row-offset.csv.gz). Together with the
earlier two-row fixture, this confirms that both one-row and two-row
vertical separations can score on the rock-arrival path, and the following
player-side path can award again.

The compiled checks set the vertical limit. On the rock side,
`$4B95..$4B9C` tests Lad at rock Y−1; `$4B9F..$4BC8` tests Y−2 only when
the intervening tile at Y−1 is code `0`. On the player side,
`$4E7E..$4E85` tests a rock at Lad Y+1; `$4E88..$4EBF` tests Y+2 only
when the intervening tile at Y+1 is code `0`. Both scoring helpers compare
X and the selected Y for equality before adding two points at `$56AF` or
`$56FC`. There is no third-row scoring call on either path. Thus the
observed one- and two-row awards are the complete vertical range for these
checks, and nonempty intervening terrain blocks the two-row check.

An [eleven-code intervening-tile sweep](rock-score-gap-sweep.tar.gz)
checks that exact test dynamically. It repeats the two-row jump-over
fixture, but after update 2 changes `(6,18)`, the cell between Lad at
`(6,17)` and the arriving rock at `(6,19)`, to each tile code `0`–`10`.
With code `0`, score changes `0→2` on update 3 and `2→4` on update 4;
the score-write log has one `$56FC` and one `$56AF` event. Every code
`1`–`10` leaves score at zero and produces no writes at either site.
Lad stays on the same jump path and keeps all five lives in every case.
This confirms the original checks for **exactly code 0** between Lad and
rock, rather than merely checking whether the tile is passable.

Reproduce a case with `--speed 1 --updates 5 --when 6:19:20
--poke-after 2:0E6A:0007,2:0E80:0013,2:0E96:0003,2:0C7A:NNNN
--score-events`, where `NNNN` is the four-digit hex intervening tile
code. Pass those options to `tools/run_ladder_state.py` with
`--emulator`, `--output`, and `--name`.

The Pascal rewrite calls `Collision` before and after each rock move and
adds 2 when Lad is one or two rows above a rock with clear intervening
cells. Its empty-intervening-cell condition agrees with this sweep, but
its check also requires the rock's own cell to be empty for a two-row
award, as tested below. It may also double-award a pass, but its check
placement differs from the original's observed player-side and rock-side
sites. FLEX has moving rocks but no rock scoring yet.

### A rock on a ladder cell can score

Easy Street's original and Pascal maps both have ladder `H` at `(28,12)`
and empty cells at `(28,10)` and `(28,11)`. After update 3 of a standing
jump, a controlled fixture moves Lad to `(28,10)` while preserving his
apex-phase jump counter and puts rock slot 1 at `(28,12)` with downward
status `2`. On update 4, Lad stays at `(28,10)`, the rock moves down to
`(28,13)`, and score rises `0→2`. The
[state trace](state-score-rock-on-ladder.csv.gz) and
[score-write log](score-events-rock-on-ladder.csv.gz) place the award at
the player-side `$56AF` write between updates 3 and 4. In the
[one-column-offset control](state-score-rock-on-ladder-offset.csv.gz),
Lad is at `(27,10)` and score remains zero.

The original two-row player-side path at `$4E88..$4EBF` checks the
intervening `(28,11)` tile, then compares rock coordinates. It does not
require the rock's own `(28,12)` tile to be empty. Pascal's `Collision` in
`Ladder/src/ladprocs.pas` requires both `m.Field[lad.Y+1][lad.X]` and
`m.Field[lad.Y+2][lad.X]` to be spaces, so it would reject this ladder-cell
award. FLEX has no rock scoring yet. This is a controlled state fixture;
a natural route to the same configuration has not been captured.

Reproduce with `--speed 1 --updates 6 --when 6:19:20
--poke-after 3:0F89:001C,3:0F8B:000A,3:0E6A:001C,3:0E80:000C,3:0E96:0002
--score-events --name ladder_rock_center`. For the offset control, change
the Lad X poke to `001B`. Pass these options to `tools/run_ladder_state.py`
with `--emulator` and `--output`.

## Same-row collision before and after a rock step

Four short Easy Street fixtures place slot 1 after update 1 while Lad is at
`(6,19)`; the `6` or `4` key, when present, was read on update 1 and takes
effect on update 2. Coordinates in this table are decimal.

| Fixture | Lad and rock on update 2, absent death | Observed update 2 | Result |
| --- | --- | --- | --- |
| [Walk into departing rock](state-rock-contact-same_cell_right.csv.gz) | Lad `6→7`; rock `(7,19)` rolling right to `(8,19)` | Lad resets to `(6,19)`, slot 1 resets, Lads `5→4` | Lethal before rock can depart |
| [Rock arrives at stopped Lad](state-rock-contact-stationary_arrival.csv.gz) | Lad stays `(6,19)`; rock `(7,19)` rolls left to `(6,19)` | Lad resets, slot 1 resets, Lads `5→4` | Lethal on rock arrival |
| [Move apart control](state-rock-contact-separating_left.csv.gz) | Lad `6→5`; rock `7→6`, rolling left | Lad `(5,19)`, rock `(6,19)`, Lads 5 | No contact |
| [Same-direction control](state-rock-contact-moving_away.csv.gz) | Lad `6→7`; rock `8→9`, rolling right | Lad `(7,19)`, rock `(9,19)`, Lads 5 | No contact |

Score stays zero in all four fixtures. The original player-side loop at
`$5105..$5168` compares Lad's position with each active rock after Lad's
movement, before that rock's next movement. The rock-side comparison at
`$4B56..$4B84` checks the rock's new coordinates against Lad and branches
to death at `$5216` on exact overlap. These paths explain both lethal
fixtures and show why the first collision cannot be evaluated only after
the rock moves. Pascal also moves Lad before its per-rock pre-move and
post-move `Collision` calls in `Ladder/src/ladmain.pas`; FLEX checks contact
both before and after rock movement. The jump-phase cases below test
exact-cell contact.

Reproduce the departing-rock fixture with `--speed 1 --updates 6
--first-key 6 --poke-after 1:0E6A:0007,1:0E80:0013,1:0E96:0004
--name same_cell_right`. For the arriving-rock fixture, omit `--first-key`
and use status `0003`. For the two controls, use `--first-key 4` with rock
X `0007`, status `0003`, or `--first-key 6` with rock X `0008`, status
`0004`. Pass these options to `tools/run_ladder_state.py` with `--emulator`
and `--output` as in the other probes.

## Rock contact on an eater tile

Easy Street has a rock eater `*` at `(79,19)`. In the
[contact trace](state-lad-on-eater.csv.gz), a rightward rock starts at
`(78,19)` and Lad stands at `(79,19)`. On update 2 the rock enters the
eater cell, Lad loses a life `5→4`, and the board restarts. The paired
[clear-cell control](state-lad-clear-of-eater.csv.gz) puts Lad at
`(77,19)` instead: the rock enters `(79,19)` on update 2, becomes
inactive there on update 3, and reappears at a dispenser on update 4,
with no life loss. Eater recycling therefore does not protect Lad from
same-cell contact on the rock's arrival update.

Reproduce with `--speed 1 --updates 5` and `--poke-after
1:0F89:004F,1:0F8B:0013,1:0F9D:0000,1:0F9F:0000,1:0E6A:004E,1:0E80:0013,1:0E96:0004`.
Change Lad's X poke to `004D` for the control. Pass these options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

Pascal's `MoveActor` checks `OnEater` before moving the rock. Its
post-move `Collision` call in `ladmain.pas` would therefore see a rock
that has just entered the eater; source inspection predicts the same
lethal contact. The assembled FLEX code was checked for both cases: a
rock entering an eater occupied by Lad kills him, while an already eaten
rock is inactive and cannot kill Lad when he enters that cell later.

## Rock contact during a jump

The earlier [rising-cell fixture](state-rock-same-cell.csv.gz) places a
falling rock at `(6,17)` after update 2, when Lad is at `(6,18)` and the
next jump step will rise to row 17. Update 3 costs one Lad before the rock
can fall away; score remains zero. This is a jump-phase example of the
player-side exact-cell check at `$5105..$5168`.

To isolate the other order on terrain that permits the rock to fall, a
new fixture moves Lad to Easy Street `(73,19)` after update 1. The map has
empty cells at `(73,16)` through `(73,19)` and floor at `(73,20)`.
Space is read on update 2; Lad reaches `(73,18)` on update 3. The fixture
then places slot 1 at `(73,16)` with downward status `2`. On update 4,
Lad reaches `(73,17)` and the rock moves down to `(73,17)`: Lad loses one
life and restarts, with score still zero. The
[status-2 trace](state-rock-jump-open_fall_contact_status2.csv.gz) records
this result. Repeating with downward status `1` gives the same result in
the [status-1 trace](state-rock-jump-open_fall_contact_status1.csv.gz).
In the [adjacent-column control](state-rock-jump-open_fall_offset.csv.gz),
the rock starts at `(74,16)` and falls to `(74,17)` on update 4; Lad stays
at `(73,17)` with five lives. The contact outcome therefore depends on
the rock's post-movement exact-cell check at `$4B56..$4B84`, not simply
on a rock crossing the player's row. Pascal's post-rock-movement
`Collision` call covers this exact-cell case; FLEX has no rocks yet.

Reproduce the status-2 contact with `--speed 1 --updates 5 --key-at 2:20
--poke-after 1:0F89:0049,1:0F8B:0013,3:0E6A:0049,3:0E80:0010,3:0E96:0002
--score-events --name open_fall_contact_status2`. Change the final status
word to `0001` for the second contact, or the rock X word to `004A` for
the offset control. Pass these options to `tools/run_ladder_state.py` with
`--emulator` and `--output`. These probes establish exact-cell outcomes;
other jump contacts and terrain-dependent rock motion remain open.

Reproduce the successful capture with the patched iz-cpm:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-score --speed 1 --updates 150 \
  --first-key 6 \
  --when 58:19:38,58:15:34,50:15:20,27:15:20,17:15:38,17:11:20 \
  --name statue-route-jump
```

For the control, omit `,17:11:20` and use `--name statue-route`. The
coordinate-triggered keys are supplied at the original game's keyboard poll
`$47ED`; the runner copies COM and DAT to a temporary CP/M drive first.

For the threshold boundary, add `--poke-after 100:0F05:0044` or
`--poke-after 100:0F05:0045` to the statue command (`0044` and `0045` are
68 and 69). For the treasure fixture use `--first-key 6 --when 58:19:38
--poke-after 53:0F8B:0002 --name treasure-from-below --updates 75`.
For the 300-point fixture use
`--poke-after 100:0F05:0000,100:0F77:012C --updates 112` with the statue
route; the poke writes only setup words before collection.
For the rock threshold timing fixture, add `2:0F05:0062` to the
jump-over fixture's `--poke-after` list; `0062` is score 98.
Pokes are little-endian word writes made **after** the named state row has
been logged, so the next row shows their effect. They are applied only to
the emulator memory of a temporary game copy.

To reproduce the jump-over fixture, run for 12 updates with `--when 6:19:20
--poke-after 2:0E6A:0007,2:0E80:0013,2:0E96:0003 --score-events
--name rock-under-jump`. Slot 1's X/Y/status words are at
`$0E6A/$0E80/$0E96`; the offset control changes only X to `0008`.
The same-cell fixture sets `2:0E6A:0006,2:0E80:0011,2:0E96:0002`.
For the one-row fixture, move the same rock placement to after update 1:
`--when 6:19:20 --poke-after 1:0E6A:0007,1:0E80:0013,1:0E96:0003
--score-events --name rock-one-row --updates 8`. Set X to `0008` for its
offset control.
