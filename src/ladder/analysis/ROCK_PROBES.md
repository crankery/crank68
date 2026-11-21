# Original Ladder rock release and movement probes

The [per-update state traces](STATE_TRACE.md) contain eleven parallel
X/Y/status table slots. Slot 0 stays `(0,0,0)` in the speed-1 idle capture;
slots 1–5 hold the Easy Street rocks. `$FFFF` marks an inactive slot. The
original actor loop at `$48B0..$48C3` skips that value; the release path at
`$475E..$47D7` finds a free slot, copies dispenser coordinates from the
parallel tables at `$0EAA/$0EC0`, and writes status `2`. The code also
compares the active count with the level's rock limit before releasing.

| Slot | First active update, at every tested speed | Initial state |
| ---: | ---: | --- |
| 1 | 1 | `(40,2,2)` |
| 2 | 2 | `(40,2,2)` |
| 3 | 3 | `(40,2,2)` |
| 4 | 4 | `(40,2,2)` |
| 5 | 5 | `(40,2,2)` |

This sequence is identical in `state-speed1.csv.gz` through
`state-speed5.csv.gz`. The dispenser at `(40,2)` is the only one on Easy
Street. In each slot's first update, it has status `2`; it moves to
`(40,3,2)` in the next update.
At `(40,3)`, status changes to `3` or `4` before horizontal travel. Those
two values mean left and right in the observed movement. Across the 400-
update idle trace, status `3` produces 768 leftward steps, and status `4`
produces 860 rightward steps. Reverse and downward transitions occur near
terrain boundaries. The ladder choice is decoded below; other terrain
boundaries still need targeted probes.

An eater/release cycle is visible without touching player input. Slot 5 is
at `(79,19,4)` at update 110, becomes `(79,19,$FFFF)` at 111, and is back
at `(40,2,2)` at 112. Slot 3 does the same at updates 126–128. Slot 1 is
inactive at `(79,19)` at update 145 and returns at update 146, although
that update also loses a life and restarts the board. The first two cycles
therefore show a one-update inactive interval followed by release from the
dispenser; the third is confounded by the restart. The Easy Street map in
the Pascal rewrite places an eater at `(79,19)`, consistent with the first
two deactivations.

## Multiple dispensers: Ghost Town

The [level-N shortcut](START_LEVEL_CHEAT.md) starts displayed level 5,
Ghost Town, with dispensers at X=29, 45, and 57. In three 30-update runs,
slots 1–5 became active on updates 1–5, one new rock per update across all
three dispensers. Their initial Y was 2 and status was 2. The first five
release X values were:

| Menu speed | First five release X values | Trace |
| ---: | --- | --- |
| 1 | 57, 45, 57, 45, 57 | `state-ghost-release-s1.csv.gz` |
| 2 | 45, 57, 45, 57, 29 | `state-ghost-release-s2.csv.gz` |
| 5 | 57, 29, 45, 29, 45 | `state-ghost-release-s5.csv.gz` |

Each trace is paired with `rock-events-ghost-s1.csv.gz`,
`rock-events-ghost-s2.csv.gz`, or `rock-events-ghost-s5.csv.gz`.

At `$4730..$474F`, the original chooses a dispenser index and stores it at
`$0FA5`; `$4793..$47C2` copies that dispenser's X/Y into the first free
actor slot. The event traces record indices 1, 2, and 3, corresponding to
X=29, 45, and 57. The selection event immediately before game update 1
supplies slot 1; later selection events precede the next sampled update's
release. These captures establish per-release selection, but the short
sequences do not establish its probability distribution or whether menu
speed directly affects the choice. The menu speed changes instruction
timing, which could also change the random state.

The event traces also record the first rolling status at `$4A63`. On Ghost
Town, each rock falls straight down from Y=2 through Y=10, then changes
status at the same X; status `3` moves left and status `4` moves right on the
following update. At speed 1, the five initial statuses are `3,3,3,4,3`;
at speed 2 they are `3,3,4,3,4`; at speed 5 they are `3,4,4,4,4`.
`$496C` records a choice value used by a separate terrain-dependent
movement branch; its results include `0,1,2` and should not be read as actor
statuses. The ladder-cell comparison below maps all three values to
movement outcomes.

## Rock limit on every board

The original release guard at `$4718..$472A` compares the active count
`$0F99` with the board's limit at `$0F7D`. Short runs on each of the seven
initial boards show one additional active rock on each update until that
limit is reached. The [summary CSV](rock-limits-first-14.csv) gives the
counts on updates 1–14. Individual state traces are saved for
[Easy Street](state-rock-limit-level1.csv.gz),
[Long Island](state-rock-limit-level2.csv.gz),
[Ghost Town](state-rock-limit-level5.csv.gz),
[Tunnel Vision](state-rock-limit-level9.csv.gz),
[Point of No Return](state-rock-limit-level14.csv.gz),
[Bug City](state-rock-limit-level20.csv.gz), and
[GangLand](state-rock-limit-level27.csv.gz).

| Board | First displayed level | Active limit | Pascal board data |
| --- | ---: | ---: | ---: |
| Easy Street | 1 | 5 | 5 |
| Long Island | 2 | 8 | 8 |
| Ghost Town | 5 | 5 | 5 |
| Tunnel Vision | 9 | 5 | 5 |
| Point of No Return | 14 | 7 | 7 |
| Bug City | 20 | 6 | 6 |
| GangLand | 27 | 6 | 6 |

These board limits match the Turbo Pascal `Rocks` fields in
`Ladder/src/ladicons.pas`. The release schedule still differs: Pascal
tests each pending rock independently with a 1-in-10 chance on a game
tick, while the original release guard adds one per update while below
the cap. FLEX does not yet implement rocks.

Reproduce a board with `--start-level N`, choosing its first displayed
level from the table:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-rock-limits --speed 1 --start-level 14 \
  --updates 14 --name rock-limit-level14
```

The original map table gives tile code `6` at Ghost Town `(33,10)` and below
it, and `0` to the right. The Pascal map depicts that column as a ladder.
Five 180-update captures show all three `$496C` results there with the same
terrain, for rocks arriving with either horizontal status:

| `$496C` result | Prior state | Sampled state after decision | Meaning |
| ---: | --- | --- | --- |
| `0` | `(33,10,4)` | `(32,10,3)` | Reverse right to left |
| `0` | `(33,10,3)` | `(34,10,4)` | Reverse left to right |
| `1` | `(33,10,4)` | `(33,11,2)` | Descend ladder |
| `1` | `(33,10,3)` | `(33,11,2)` | Descend ladder |
| `2` | `(33,10,4)` | `(34,10,4)` | Continue right |
| `2` | `(33,10,3)` | `(32,10,3)` | Continue left |

Across these 37 visits, result counts are `0:5`, `1:16`, `2:16`; this is a
small, correlated sample, not a probability estimate. The saved long traces
`state-ghost-ladder-s2.csv.gz` and `state-ghost-ladder-s3.csv.gz`, paired with
`rock-events-ghost-ladder-s2.csv.gz` and
`rock-events-ghost-ladder-s3.csv.gz`, contain examples of all three results.
The Pascal rewrite also offers reverse, descend, and continue at ladder
tops through `Random(3)`, though its numeric case assignments differ.
Other ladder layouts still need comparison.

Easy Street provides a blocked downward path. At `(58,3)`, the original
tile table contains `6` under the rock and solid tile `2` below. In the
speed-1 capture, slot 1 reaches `(58,3,4)` on update 21. `$496C` then yields
`1`, but update 22 has `(58,3,3)`: the rock stays on the row and reverses
left. At Ghost Town `(33,10)`, where the tile below is `6`, the same choice
value sends a right-moving rock down to `(33,11,2)`. Thus a `1` choice does
not force descent through a solid cell. The paired
`state-easy-ladder-blocked.csv.gz` and
`rock-events-easy-ladder-blocked.csv.gz` preserve the blocked case.

## A rock one cell above a ladder

Easy Street `(28,11)` is empty tile `0`, with ladder tile `6` immediately
below at `(28,12)`. A controlled rock at `(28,11)` with rolling status
`3` [left trace](state-rock-above_h_left.csv.gz) or `4`
[right trace](state-rock-above_h_right.csv.gz) goes to `(28,12,2)` on the
next update. The rock does not move horizontally on that update. The
[right-side choice log](rock-events-above_h_right.csv.gz) has no `$496C`
event before this transition; its first `$496C` event occurs on the
following update, when the rock is already on `H`. A rock placed directly
at `(28,12,4)` instead generates `$496C` immediately, as the
[on-ladder state](state-rock-on_h_right.csv.gz) and
[choice log](rock-events-on_h_right.csv.gz) show. A rock placed at
neighboring `(27,11,3)`, with ordinary floor below, rolls left to
`(26,11,3)` in the [floor control](state-rock-above_floor_left.csv.gz).

At `$4938..$4955`, the compiled code tests the rock's current cell for
ladder code `6`; that case reaches the three-way choice at `$496C`.
Otherwise `$49AA..$49E8` checks the cell below, setting status `2` at
`$4999` when its code is `0` or at least `6`, and `$4A03` performs the downward
step. Thus an empty cell directly above a ladder causes **automatic
descent** in this fixture; random reversal or continued rolling starts
only once the rock occupies the ladder cell. Pascal's `OnSolid` treats
`H` below as support, while `AboveLadder` applies `Random(3)` to a
left- or right-moving rock in the cell above. That can choose reverse or
continue there, unlike the original. FLEX does not yet implement rocks.

Reproduce the rightward case with `--speed 1 --updates 5
--poke-after 1:0E6A:001C,1:0E80:000B,1:0E96:0004 --rock-events
--name above_h_right`. Change status to `0003` for the leftward case;
change Y to `000C` for the on-ladder comparison. Pass these options to
`tools/run_ladder_state.py` with `--emulator` and `--output`.

## Horizontal obstruction

The original Ghost Town map has tile code `4` at `(11,10)` and empty tile
code `0` at `(12,10)`; the Pascal map shows a vertical `|` at `(11,10)`.
In five 180-update runs, 13 left-moving rocks reached `(12,10)` and changed
status from `3` to `4` without changing position. Each moved right to
`(13,10,4)` on the following update. No `$496C` ladder-choice event occurs
at `(12,10)`. This is a repeatable one-update turn at that obstruction. The
original tile dumps `tile-ghost-map.csv.gz` and `tile-easy-map.csv.gz`
record the board codes used in these comparisons; the Ghost Town examples
are in the long state traces above.

## Terrain a rolling rock can enter

The horizontal destination branch at `$4A8E..$4ACC` admits tile code `0`
or codes `6` and above in the original board table; other codes turn the
rock and restore its old position for that update. Short controlled runs
confirm the passable side with natural terrain:

An [eleven-code destination sweep](rock-destination-sweep.tar.gz) now tests
that branch completely. It puts a rightward rock in slot 1 at Easy Street
`(73,19)` and changes only its next cell `(74,19)`. On update 2, code `0`
or any of `6`–`10` moves the rock to `(74,19)` with rightward status `4`.
Every code `1`–`5` leaves it at `(73,19)` and reverses its status `4→3`;
on update 3 it moves left to `(72,19)`. Eater code `7` admits the rock on
update 2 and makes it inactive on update 3. Score and Lads remain
unchanged throughout the sweep.

Reproduce any case with `--speed 1 --updates 3` and `--poke-after
1:0E6A:0049,1:0E80:0013,1:0E96:0004,1:0DA4:NNNN`, where `NNNN` is the
four-digit hex destination code. Pass the options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

| Original tile | Placement after update 1 | State on update 2 | Later observation |
| --- | --- | --- | --- |
| Eater `7` (`*`) | Easy Street rock `(78,19,4)` toward `(79,19)` | [Enters `(79,19,4)`](state-rock-roll-eater.csv.gz) | Becomes inactive on update 3, reappears at dispenser on update 4 |
| Fire `8` (`^`) | Point of No Return rock `(34,12,3)` toward `(33,12)` | [Enters `(33,12,3)`](state-rock-roll-fire.csv.gz) | Continues left; Lad and score unchanged |
| Trampoline `9` (`.`) | Point of No Return rock `(34,12,4)` toward `(35,12)` | [Enters `(35,12,4)`](state-rock-roll-trampoline.csv.gz) | Continues right |
| Statue `10` (`&`) | Point of No Return rock `(18,12,4)` toward `(19,12)` | [Enters `(19,12,4)`](state-rock-roll-statue.csv.gz) | Continues right; score stays zero |

No original board has a conveniently supported empty cell immediately
beside a disposable `-` floor cell. A separate fixture changes one Easy
Street tile at `(74,19)` from code `0` to code `1` after update 1, then
puts a right-moving rock at `(73,19)`. On update 2 the rock stays at
`(73,19)` and turns from status `4` to `3`; it rolls left on update 3.
The [blocked trace](state-rock-roll-disposable-block.csv.gz) contrasts
with the [unchanged-map control](state-rock-roll-disposable-control.csv.gz),
where it moves right through `(74,19)` and beyond. The tile word is at
`$0DA4 = $010A + 2×(81×19+74)` in the original's 1-based table. This
fixture tests the code path with a single terrain change; it is not a
naturally occurring rock route on Easy Street.
Using the same fixture with code `5` at `(74,19)` also produces a blocked
turn in the [dispenser-code trace](state-rock-roll-dispenser-block.csv.gz),
while code `6` lets the rock enter `(74,19)` in the
[ladder-code trace](state-rock-roll-ladder-pass.csv.gz). Those two boundary
cases support the compiled `0` or `≥6` passability test.

Pascal's `EmptySpace` in `Ladder/src/ladactor.pas` excludes only `|` and
`=`, so it would let a rolling rock enter `-`, `$`, and `V`, all three of
which turn the original rock. It also admits `*`, `^`, `.`, and `&`,
matching the original's immediate horizontal step for those tiles. FLEX
does not yet implement rocks.

Reproduce the disposable case with `--speed 1 --updates 5
--poke-after 1:0E6A:0049,1:0E80:0013,1:0E96:0004,1:0DA4:0001
--name disposable_block`. Omit the final map poke for the control.
The natural-tile cases use the placements in the table with
`--start-level 14` for Point of No Return and default level 1 for the
eater. Pass these options to `tools/run_ladder_state.py` with
`--emulator` and `--output`.

## Playfield edges

The [400-update Easy Street trace](state-idle-400.csv.gz) contains 13 clean
edge reversals. Eight left-moving rocks arrive at X=1, at Y=7 or Y=15;
their next state keeps the same position and changes status `3→4`, then
the following update moves them to X=2. Five right-moving rocks at
`(79,7)` likewise stay in place while changing `4→3`, then move to X=78.
This is a one-update turn at either horizontal boundary. At `(79,19)`,
the rock eater instead marks a right-moving rock inactive, as described
above. The Pascal rewrite also reverses at X=1 or its maximum column;
FLEX has no rock actor yet.

## Rock-to-rock overlap

The Easy Street idle trace has 21 sampled updates with two active rocks in
the same cell. Two clean opposing-direction crossings show the effect. At
updates 94–96, slots 3 and 5 move from X=65/63 to both occupy `(64,19)`,
then separate to X=63/65. Their left/right statuses remain `3` and `4`.
At updates 123–125, slots 2 and 4 similarly converge at `(28,19)` and
pass through. The original actor update therefore permits rock overlap
without a collision response in these cases. Pascal's `Collision` routine
checks a rock against Lad, not another rock; FLEX has no rocks yet.

## Open gap and landing

An [eleven-code falling-rock sweep](rock-down-tile-sweep.tar.gz) puts rock
slot 1 at Easy Street `(73,18)` with downward status `2` and changes only
the cell below at `(73,19)`. On update 2, code `0` or any of `6`–`10`
lets it descend one row to `(73,19)`. Every code `1`–`5` leaves it at
`(73,18)` and changes to rolling status `4` in the sampled RNG sequence;
it moves right to `(74,18)` on update 3. Code `7` admits the rock on
update 2 and makes it inactive on update 3. Score and Lads remain
unchanged in all eleven runs. The sweep shows that the same tile code
boundary governs downward travel, while landing takes a separate
stationary update to choose a horizontal direction.

Reproduce any case with `--speed 1 --updates 3` and `--poke-after
1:0E6A:0049,1:0E80:0012,1:0E96:0002,1:0DA2:NNNN`, where `NNNN` is the
four-digit hex tile code. Pass the options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.
Pascal's shared `OnSolid` treats `H` below as support and omits `$` and
`V`, so its falling-rock landing test differs on those three codes.

Ghost Town has an open shaft at X=64: the original tile codes at
`(64,10)`–`(64,14)` are `0`, with floor code `2` at `(64,15)`. In both the
saved speed-2 and speed-3 long traces, a right-moving rock reaches
`(64,10,4)`, then visits Y=11, 12, 13, and 14 on successive updates at
constant X with falling status `2`. On the next update it stays at
`(64,14)` and changes back to rightward status `4`; only the following
update moves to `(65,14,4)`. This confirms one row per update through an
open gap and a separate no-movement direction update on landing. The
Pascal rewrite's `FALLING` path retains the previous horizontal request;
the original's landing direction needs separate examination below.

### Landing selects a new horizontal direction

A five-update Ghost Town fixture puts slot 1 at `(64,14,2)` after update 1.
Its next attempted downward step reaches solid floor at `(64,15)`.
At menu speed 1, update 2 keeps the rock at `(64,14)` and changes status
`2→4`, followed by a rightward step on update 3; see the
[state trace](state-rock-landing_s1.csv.gz) and
[choice log](rock-events-landing_s1.csv.gz). At menu speed 4 the same
placement changes `2→3` and rolls left on update 3; see the
[second state trace](state-rock-landing_s4.csv.gz) and
[choice log](rock-events-landing_s4.csv.gz). Both logs record the choice
at `$4A63` with working coordinates `(64,15)`. These two examples show
both landing directions, without establishing their probabilities.

The natural [Ghost Town speed-3 trace](state-ghost-ladder-s3.csv.gz) gives
the stronger previous-direction comparison: slot 4 rolls right into
`(64,10,4)` on update 113, falls through rows 11–14 on updates 114–117,
then stays at `(64,14)` and turns left to status `3` on update 118. It
moves left on update 119. The corresponding
[event log](rock-events-ghost-ladder-s3.csv.gz) records result `3` at
`$4A63` after the blocked step toward `(64,15)`. Thus the original can
land facing **opposite** its pre-fall horizontal direction.

Compiled code at `$4A03..$4A48` attempts a downward step and tests the
destination tile. When it is solid, `$4A4B..$4A6F` chooses status `3` or
`4`, then `$4AE8..$4AF1` restores the old coordinates for that update.
Pascal's `FALLING` branch in `Ladder/src/ladactor.pas` resumes its saved
`DirRequest` on support, so it preserves the old horizontal direction in
this situation. FLEX has no rocks yet.

Reproduce the short fixture with `--start-level 5 --updates 5
--poke-after 1:0E6A:0040,1:0E80:000E,1:0E96:0002 --rock-events
--name landing_s1`, using `--speed 1`. Repeat with `--speed 4` and name
`landing_s4`. Pass these options to `tools/run_ladder_state.py` with
`--emulator` and `--output`.

## Two downward statuses

Statuses `1` and `2` both move a rock down one row per update. In the
400-update Easy Street idle trace, 23 transitions starting in status `1`
move `(0,+1)`, and the remaining three change to horizontal status without
moving. A rock descending the shaft at X=17 alternates between `1` and `2`
while continuing down at the same rate. The Ghost Town long traces also
show status `1` crossing empty cells before changing to `2`. This rules out
interpreting status `1` as stationary or as a horizontal direction.

[Paired controlled traces and choice logs](rock-down-status-pairs.tar.gz)
put slot 1 at Easy Street `(73,18)` with initial status `1` or `2` and
the same RNG state. With empty code `0` below, both descend to `(73,19,2)`
on update 2 and land at `(73,19,4)` on update 3. With floor code `2`
below, both stay at `(73,18)` and select status `4` on update 2, then
roll right on update 3. The `$4A63` log records old status `1` or `2`
for the immediate landing and result `4` in both. Thus the two downward
statuses share the same movement and landing decision in these paired
terrain cases; status `1` normalizes to `2` on an ordinary downward step.

Reproduce with `--speed 1 --updates 4 --rock-events` and
`--poke-after 1:0E6A:0049,1:0E80:0012,1:0E96:SSSS,1:0DA2:TTTT`,
where `SSSS` is `0001` or `0002` and `TTTT` is `0000` or `0002`.

The [paired long state trace](state-rock-vertical-choice-s1.csv.gz) and
[choice log](rock-events-vertical-choice-s1.csv.gz) show what changes the
status on a ladder. At `$4955..$4996`, tile code `6` invokes the three-way
choice at `$496C`. Choice `0` reverses the current status through the
table at `$0E5E`; choice `1` sets status `2`; choice `2` leaves the status
alone. The actor dispatch after `$49F7` sends both statuses `1` and `2`
to the same downward step at `$4A03`. For 64 events with a ladder cell
below, the paired rows give:

| Prior status | Choice 0 | Choice 1 | Choice 2 |
| ---: | --- | --- | --- |
| 1 | `2`, down (5) | `2`, down (8) | `1`, down (9) |
| 2 | `1`, down (16) | `2`, down (13) | `2`, down (13) |

Every case moves `(0,+1)` in the same update. Thus reversing a vertically
descending rock toggles its status but does not send it upward. The Pascal
rewrite only applies its ladder random choice to rocks moving left or
right, and its `DOWN` and `FALLING` states have distinct behavior. The
original's two numeric downward statuses should not be assigned those
Pascal meanings without further evidence. On reaching solid ground, the
original picks a horizontal direction instead of continuing downward;
the paired trace also contains examples at X=17 and X=58.

Reproduce the paired capture with:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-rock-vertical --speed 1 --start-level 1 \
  --updates 400 --rock-events --name easy-vertical-s1
```

## Observed random-choice frequencies

Five distinct *menu-speed configurations* on Ghost Town ran for 400
updates each. The preserved event logs are
[speed 1](rock-events-frequency-ghost-s1.csv.gz),
[speed 2](rock-events-frequency-ghost-s2.csv.gz),
[speed 3](rock-events-frequency-ghost-s3.csv.gz),
[speed 4](rock-events-frequency-ghost-s4.csv.gz), and
[speed 5](rock-events-frequency-ghost-s5.csv.gz). The site at `$474F`
records dispenser indices 1/2/3, `$496C` records ladder choices 0/1/2,
and `$4A63` records new rolling statuses 3/4 after landing. Run
`python3 tools/summarize_rock_choices.py` to recount the compressed logs.

| Speed | Dispenser 1/2/3 | Ladder 0/1/2 | Rolling left/right |
| ---: | ---: | ---: | ---: |
| 1 | 4/10/8 | 30/41/36 | 30/17 |
| 2 | 8/10/7 | 27/26/26 | 19/26 |
| 3 | 8/9/6 | 36/36/39 | 24/23 |
| 4 | 9/9/7 | 33/37/41 | 25/30 |
| 5 | 10/6/8 | 33/37/34 | 23/28 |
| **Total** | **39/44/36** | **159/177/176** | **121/124** |

The counts are consistent with the equal-width choice ranges decoded below,
but decisions within a run share random state and rock paths. Repeating speed 3 with the same setup
gave the identical result sequence at all three sites, so repeated launches
of one configuration cannot be treated as independent samples. The menu
speed changes the instruction path enough to produce different sequences.
Reproduce a speed's raw capture with:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-rock-frequency --speed 3 --start-level 5 \
  --updates 400 --rock-events --name ghost-frequency-s3
```

The linked runtime's random routine at `$6C31` reads two words at
`$6805/$6807` and writes updated words at `$6C62/$6C66`; initialization
also writes `$6805` at `$689D`. Compiled game code calls it for dispenser
selection (`$4730`), ladder choice (`$495B`), and landing direction
(`$4A4E`), as well as a menu draw (`$4126`) and trampoline choice
(`$50C5`). The disassembly now labels the routine `random_float` and the
four-byte storage `random_seed_state`.

The [400-update RNG log](ghost-rng-s3-400.rng.csv.gz), paired with its
[rock events](ghost-rng-s3-400.rock.csv.gz), records each call just before
`$6C31` and just after its state write at `$6C77`. Treating `$6805` as the
high word and `$6807` as the low word gives the exact recurrence
`state = (5 * state + 3) mod 2^32`: all 184 captured calls follow it.
The [seed-zero log](seed-zero.rng.csv.gz) adds 17 matching calls, including
`0 -> 3 -> 18 -> 93`. The game uses the *low 24 bits of the updated
state* for these integer choices:

| Decision | Result from `v = state & 0xFFFFFF` | Checked events on Ghost Town |
| --- | --- | ---: |
| Three dispensers | `1 + floor(3*v / 2^24)` | 19 |
| Ladder choice | `floor(3*v / 2^24)` | 111 |
| Landing direction | `3 + floor(2*v / 2^24)` | 47 |

All 177 choices match the formulas. Six controlled seed pokes in the
[boundary captures](rng-boundary-captures.tar.gz) check both sides of the
1/3, 2/3, and 1/2 cutoffs. Run `python3 tools/verify_rng_probe.py` to
recount the state transitions, choices, and boundary cases. For a board
with fewer than three dispensers, replace `3` in the dispenser formula
with that board's dispenser count.

The low 24-bit recurrence has period `2^24` (16,777,216): starting at zero,
it returns to zero only after all that many steps. Thus a three-way raw draw
assigns 5,592,406 states to result 0 and 5,592,405 to each other result;
a two-way draw splits the states evenly. Those are full-cycle bucket sizes,
not independent probabilities for rocks encountered on a particular run.

A controlled Ghost Town speed-3 run wrote zero to both seed words after
update 1 with `--poke-after 1:6805:0000,1:6807:0000`. The
[control](rock-events-rng-control.csv.gz) and
[seed-zero run](rock-events-rng-zero.csv.gz) share the first five dispenser
choices made before the poke. The next choice, logged at completed update 1,
changes from index 2 to index 1; the first five landing statuses change
from 3/4/3/4/4 to 3/3/3/3/3. This confirms that those rock choices depend
on the four-byte state. Reproduce with `--speed 3 --start-level 5
--updates 100 --rock-events` and the poke above.

## Comparison and next checks

The Pascal rewrite initializes all five rocks as `PENDING` and, on each
game tick, gives each pending rock a `Random(10) = 0` chance to start
falling. That can release several rocks on one tick or none for many ticks.
The original Easy Street and Ghost Town traces instead show exactly one new
rock per update until five are active. The original chooses a dispenser at
release. These are confirmed rule differences for the initial release and
dispenser assignment. The FLEX port does not yet implement rocks.

The [trampoline RNG probe](TRAMPOLINE_PROBES.md) confirms the same three-way
bucket rule for Lad. The
[controlled jump-over probe](SCORING_PROBES.md) shows separate two-point
writes on rock arrival and the following player-side check; other relative
heights and contact directions remain to test. The
[jump-contact probes](SCORING_PROBES.md#rock-contact-during-a-jump) also
show that either downward status can bring a rock into Lad's new cell and
cost a life on that update. A
[ladder-cell score fixture](SCORING_PROBES.md#a-rock-on-a-ladder-cell-can-score)
shows that the original's two-row award can occur while the rock occupies
an `H` tile; Pascal's corresponding check would reject it.
