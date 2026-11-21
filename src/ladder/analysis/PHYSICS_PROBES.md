# Original Ladder jump and ladder probes

These traces use the original 1.10 COM and DAT, the [per-update state
logger](STATE_TRACE.md), and one-shot keys sent only at the gameplay poll
`$47ED`. The `keys` column records the key in the update when it is read;
the resulting movement normally begins in the following update. Coordinates
below are decimal screen cells. The five compressed CSV files linked in the
table preserve all sampled words and actor slots.

| Probe | Input | Observed Lad position by update |
| --- | --- | --- |
| [Standing jump at start](state-jump-start.csv.gz) | Space at `(6,19)` in update 1 | `(6,19)` at 1; Y `18,17,17,17,18,19` at 2–7 |
| [Running jump at ladder base](state-jump-ladder-base.csv.gz) | `6` at start, space at `(58,19)` in update 53 | `(58,19)` at 53; `(59,18),(60,17),(61,17),(62,17),(63,18),(64,19)` at 54–59 |
| [Jump while climbing](state-jump-ladder-mid.csv.gz) | `6`, `8` at `(58,19)`, space at `(58,17)` in update 55 | `(58,17)` at 55; `(58,16)` at 56; `(58,15)` at 57 and later |
| [Jump from ladder top](state-climb-jump-top.csv.gz) | `6`, `8` at `(58,19)`, space at `(58,15)` in update 57 | `(58,15)` at 57; Y `14,13,13,13,14,15` at 58–63 |
| [Walk off the upper ledge](state-left-from-ladder-top.csv.gz) | `6`, `8` at `(58,19)`, `4` at `(58,15)` in update 57 | Left to `(48,15)` at 67; `(48,16)` through `(48,19)` at 68–71; left again at 72 |

The two unblocked jumps have the same six movement updates: two ascending
cells, two updates at the apex, and two descending cells. A running jump
also advances X by one cell on **every** movement update, including the two
apex updates. The jump begins on the update *after* space is read. The raw
word `$0F93` becomes `$FFFF` when space is read, while `$0F97` starts at 6,
counts down once per movement update, and reaches 0 on landing. Compiled
code at `$4ECD` reads `$0F97` to select the jump movement entry; `$4EE0` and
`$4EEA` are the corresponding upward/downward Y writes. These addresses and
the trace agree on the six-step path.

At the middle of the ladder, space is accepted (`keys=20`, `$0F93=$FFFF` at
update 55), but the jump state clears at update 56 with `$0F97` still 6.
The lad continues upward to the ladder top and stops there. This is a
terrain-specific interruption, so a jump from a ladder should not be modeled
as an unconditional six-step arc. At the ladder base, pressing space while
moving right produces the full running jump and passes horizontally across
the shaft.

## Space while stopped on a ladder

The update scheduler can send keys on separate state rows (`--key-at`), which
matters because several keyboard polls can occur within one update. On Easy
Street, `8` starts climbing at `(58,19)`; `5` on update 55 stops Lad at
`(58,17)`. The [stop control](state-ladder-stop-only.csv.gz) holds there.
With space on update 56, Lad moves to `(58,16)` on update 57 and stops.
Another space on update 58 moves him to `(58,15)` on update 59, where he
stops again. The [two-space trace](state-ladder-stop-jump-twice.csv.gz) shows
that each press advances one ladder cell. The
[single-space trace](state-ladder-stop-then-jump.csv.gz) confirms that the
first rise does not continue on its own.

The raw `$0F97` jump counter stays at `6` after each interrupted rise, even
though Lad is stationary; another space is still accepted. The Pascal
rewrite treats an `H` cell as solid, then cancels a jump when the next cell
is also `H`. That produces the same one-cell visible motion. FLEX's jump
path now accepts the step into `H` and ends the active jump there, matching
the original's visible one-cell interruption. A runtime port trace remains
to be captured.

## Manual descent and space at the ladder base

Easy Street has a ladder at `(58,15)`–`(58,19)` with solid floor beneath
row 19. The [down-key trace](state-down-ladder.csv.gz) places Lad at
`(58,15)` stopped and sends ASCII `2` on update 2. Lad descends to Y=16,
17, 18, and 19 on updates 3–6, one row per update. The down request word
`$0F9D` and applied direction `$0F9F` both hold value `2` at the bottom;
Lad stays at Y=19 through update 12. In the
[adjacent control](state-down-control.csv.gz), the same key at `(57,15)`
sets the down request to `2` but leaves applied direction `0`, with no
vertical movement. The request alone does not make Lad descend through
ordinary floor.

What happens after descent depends on that retained request. The
[down-then-space trace](state-down-then-space.csv.gz) presses space on
update 7, immediately after reaching the ladder base. Lad rises one cell
to `(58,18)` on update 8; the ladder tile interrupts the jump and leaves
the raw jump counter at `6`. The down request remains `2`, so Lad returns
to `(58,19)` on update 9. In the
[stopped-base control](state-base-space.csv.gz), space at `(58,19)` also
moves Lad to `(58,18)` for one update, but he stays there because the
down request is `0`. The destination-tile branch at `$4F1D..$4F42`
clears the active jump on a ladder; the subsequent downward movement
uses the retained request. These two traces distinguish a brief hop
followed by descent from a one-cell rise that persists.

Reproduce the descent with `--start-level 1 --speed 1 --updates 12
--poke-after 1:0F89:003A,1:0F8B:000F,1:0F9D:0000,1:0F9F:0000
--key-at 2:32`. Add `,7:20` to `--key-at` and extend to 15 updates for
the space-after-descent case. Pass the options to `tools/run_ladder_state.py`
with `--emulator`, `--output`, and `--name`.

Pascal's `DOWN` branch stops at solid floor, and its jump-start case has
no `DOWN` arm. FLEX starts a jump while its down direction is selected
and allows movement through ladder cells. FLEX now retains its down
direction at row 19, so a jump at the ladder base leaves that request
available after the one-cell interruption. The direct CPU check below
executes `key_jump` and successive `move_player` calls and verifies the
one-cell rise followed by the return to the base. Key-poll timing still
needs a port game-loop trace.

## Enter a ladder from a supported plain cell

Bug City has an empty cell at `(39,3)`, solid floor at `(39,4)`, and ladder
`H` immediately above at `(39,2)`. In the
[entry trace](state-up-entry-ladder-above.csv.gz), the fixture places Lad
at `(39,3)` after update 1 and reads Up (`8`) on update 2. He climbs into
`(39,2)` on update 3, then stays there. The
[no-ladder control](state-up-entry-no-ladder-above.csv.gz) uses `(40,3)`,
also supported but with empty space above; Up leaves him at `(40,3)`.
The [unsupported control](state-up-entry-ladder-above-forced-unsupported.csv.gz)
places him at `(38,3)` directly below another `H`, with no support below,
and forces the Up state after update 1. He falls to `(38,4)` on update 2.
Thus a supported plain cell can enter a ladder from below, while the
unsupported cell falls. The
[statue-above trace](state-up-entry-statue-above-supported.csv.gz) shows
the same Up entry into `&` from Bug City `(52,16)`, supported by floor;
Lad reaches `(52,15)` and scores 29. A
[ladder-below control](state-up-entry-statue-above-ladder-unsupported.csv.gz)
places him at Easy Street `(17,10)` with `H` below and `&` above and
forces the Up state. He falls into `(17,11)` instead. An `H` one row
below does not support Lad unless he is already on the ladder cell.

The original player path at `$4C57..$4C72` checks the current tile and
support below before the direction dispatch at `$4CBC`. The Up path then
tests the destination above. Pascal's `MoveActor` in `ladactor.pas` only
accepts an Up request when the **current** cell is `H`, and its `OnSolid`
also treats `H` below as support, so both cases differ. FLEX now checks
support and the destination above; the assembled CPU probe covers ladder
entry, statue entry, blocked entry, and the two unsupported falls.

Reproduce the entry with `--start-level 20 --speed 1 --updates 6`,
`--poke-after 1:0F89:0027,1:0F8B:0003,1:0F9D:0000,1:0F9F:0000`, and
`--key-at 2:38`. For the no-ladder control use X `0028`. For the forced
unsupported control use X `0026`, omit `--key-at`, and set `$0F9D` and
`$0F9F` to `0001` after update 1. Pass those options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

## Which tiles support Lad from below

A [16-trace tile sweep](support-tile-sweep.tar.gz) places Lad at Easy Street
`(73,18)` and changes only `(73,19)` after update 1. Each original tile
code `0`–`10` gets its own three-update run. With no movement request, the
position and event on update 2 are:

| Code | Glyph | Result |
| ---: | :---: | --- |
| 0 | space | Falls to `(73,19)` |
| 1–5 | `-`, `=`, `$`, `|`, `V` | Stays supported at `(73,18)` |
| 6–7 | `H`, `*` | Falls to `(73,19)` |
| 8 | `^` | Falls into fire, loses one Lad, restarts at `(6,19)` |
| 9 | `.` | Falls to `(73,19)` |
| 10 | `&` | Falls to `(73,19)` and scores 35, the current bonus |

Five further traces in the archive press Space on update 2 with each
supporting code `1`–`5` below. The raw jump state arms at `6` on that
update; Lad rises to `(73,17)` on update 3. Thus `$` and `V` count as
support for jump arming as well as standing. The original support
classification is **codes 1–5
below, or current cell `H`**. A ladder below Lad is passable terrain, not
support; he falls into it.

Reproduce any case with `--speed 1 --updates 3` and `--poke-after
1:0F89:0049,1:0F8B:0012,1:0F9D:0000,1:0F9F:0000,1:0DA2:NNNN`,
where `NNNN` is the four-digit hex tile code. Use `--updates 5
--key-at 2:20` for the jump cases. The map word address `$0DA2` is
`$010A + 2×(73 + 81×19)`.

Pascal's `OnSolid` accepts `=`, `-`, `H`, and `|` below: it wrongly supports
on `H` and omits `$` and `V`. FLEX now uses the original five support
codes and the current-cell `H` check. Its assembled CPU sweep covers all
eleven codes and jumps from each supporting code.

## Which tiles Lad can enter sideways or downward

A [22-trace destination sweep](player-destination-sweep.tar.gz) changes
one destination code at a time. For sideways movement, Lad begins at Easy
Street `(73,19)` with a right request, and the fixture changes `(74,19)`.
For downward movement, he begins on `H` at `(58,18)` with a Down request,
and the fixture changes `(58,19)`. Both positions are otherwise unchanged
across their eleven cases. Update 2 gives:

| Destination code | Sideways result | Down from `H` result |
| --- | --- | --- |
| 0 space | Enter | Enter |
| 1 `-` | Enter | Blocked |
| 2 `=` | Blocked | Blocked |
| 3 `$` | Enter; next board and +35 score | Enter; next board and +35 score |
| 4 `|` | Blocked | Blocked |
| 5 `V` | Enter | Blocked |
| 6 `H` | Enter | Enter |
| 7 `*` | Enter | Enter |
| 8 `^` | Enter; lose one Lad | Enter; lose one Lad |
| 9 `.` | Enter; trampoline affects the following update | Enter; trampoline affects the following update |
| 10 `&` | Enter; +35 score | Enter; +35 score |

The blocked cases stay in place on update 3 and keep the requested
direction in `$0F9F`. In the trampoline cases, update 2 enters the tile;
the controlled RNG sequence changes movement on update 3. An eater does
not hurt Lad. These are destination rules: a `-` cell can be entered from
the side, even though it supports Lad from below and blocks downward
descent. Likewise `V` supports from below and admits sideways movement,
but blocks descent from `H`.

Reproduce a sideways case with `--speed 1 --updates 3` and `--poke-after
1:0F89:0049,1:0F8B:0013,1:0F9D:0004,1:0F9F:0004,1:0DA4:NNNN`.
For a downward case, use
`1:0F89:003A,1:0F8B:0012,1:0F9D:0002,1:0F9F:0002,1:0D84:NNNN`.
`NNNN` is the destination code as four hex digits. Pass these options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

Pascal's `EmptySpace` allows every sideways destination except `=` and
`|`, matching the original. Pascal's `DOWN` destination list excludes
`*`, though the original enters it. FLEX now uses separate sideways and
downward checks: its assembled CPU sweep matches both original passability
sets. FLEX still lacks statue, trampoline, and full level-completion
behavior, so the CPU check covers the immediate cell entry and blocking
rather than every subsequent effect.

## Blocked movement requests persist

Two controlled Easy Street fixtures test whether a blocked request is
discarded. In the [rightward trace](state-blocked-right-cleared.csv.gz),
Lad is at `(73,19)` requesting Right with a synthetic `=` at `(74,19)`.
Updates 2–3 leave him at `(73,19)` with request and applied direction both
`4`. The fixture clears `(74,19)` after update 3. Without another key,
Lad moves to `(74,19)` on update 4 and continues right. The
[downward trace](state-blocked-down-cleared.csv.gz) puts Lad on `H` at
`(58,18)` with a synthetic `V` at `(58,19)`. He stays at row 18 on
updates 2–3 with both direction words `2`; clearing `V` after update 3
lets him descend to row 19 on update 4 without another key. The original
retains both requests through these blocked updates.

The [Up trace](state-blocked-up-ladder-added.csv.gz) starts Bug City Lad
at supported `(40,3)` with no `H` above. Up is read on update 2; he stays
at `(40,3)` on updates 2–3 with request word `1` and applied direction
`0`. The fixture adds `H` at `(40,2)` after update 3. Without another
key, update 4 moves him to `(40,2)` and sets applied direction to `1`.
Thus the original retains the blocked Up request as well.

Reproduce with `--speed 1 --updates 6` and either `--poke-after
1:0F89:0049,1:0F8B:0013,1:0F9D:0004,1:0F9F:0004,1:0DA4:0002,3:0DA4:0000`
for Right or
`1:0F89:003A,1:0F8B:0012,1:0F9D:0002,1:0F9F:0002,1:0D84:0005,3:0D84:0000`
for Down. Pass these options to `tools/run_ladder_state.py` with
`--emulator`, `--output`, and `--name`.
For Up, use `--start-level 20 --key-at 2:38` and
`--poke-after
1:0F89:0028,1:0F8B:0003,1:0F9D:0000,1:0F9F:0000,3:029E:0006`.

Pascal's blocked `RIGHT` branch requests `STOPPED`, and its blocked
`DOWN` branch sets `Dir := STOPPED`; neither automatically resumes when
the tile clears. Pascal retains an Up request on a plain cell, but only
accepts it when Lad's **current** cell is `H`, so adding `H` above does
not trigger this climb. FLEX keeps all three requests, with each recovery
path checked on the assembled CPU.

## Jump destination tile sweep

An [eleven-trace standing-jump sweep](jump-destination-sweep.tar.gz) arms
Space on update 1, then places Lad at Easy Street `(73,19)` and substitutes
each code `0`–`10` at the next jump cell `(73,18)`. Update 2 gives:

| Code | Original result |
| --- | --- |
| 0, 1, 5, 7, 9 | Enter `(73,18)`; jump counter `6→5`, then continues up |
| 2 `=` | Stay `(73,19)`; active jump cancels, counter remains `6` |
| 3 `$` | Complete board; level 2 begins, score +35 |
| 4 `|` | Stay `(73,19)`; active jump and counter `6` persist |
| 6 `H` | Enter `(73,18)`; jump interrupts with counter still `6` |
| 8 `^` | Lose one Lad; restart board |
| 10 `&` | Enter `(73,18)`; score +35 and jump continues |

This confirms that `-` and dispenser `V` are passable during ascent, while
solid `=` cancels the jump and wall `|` pauses it. Eater `*` and trampoline
`.` are entered without interrupting the jump in these fixtures. The
original destination dispatch at `$4F08..$4F78` matches the observed
branches. FLEX's assembled CPU sweep matches the immediate movement and
jump phase for all eleven codes. Its prototype still lacks full scoring,
lives, and next-board handling.

Reproduce a case with `--speed 1 --updates 4 --key-at 1:20` and
`--poke-after
1:0F89:0049,1:0F8B:0013,1:0F9D:0000,1:0F9F:0000,1:0D00:NNNN`.
`NNNN` is the destination code as four hex digits. Pass those options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

## Step sideways off a ladder and press space

At Easy Street `(58,17)`, Lad is on ladder code `6`; the neighboring cells
at `(57,17)` and `(59,17)` are empty, with floor at row 20. The
[right-exit trace](state-ladder-exit-right.csv.gz) presses `6` on update 2:
Lad moves to `(59,17)` on update 3, falls in place to Y=18 and 19 on
updates 4–5, then resumes rightward travel on update 6. The
[left-exit trace](state-ladder-exit-left.csv.gz) mirrors that sequence.
Thus stepping sideways uses one horizontal update, then two one-row fall
updates, and preserves the horizontal request for landing.

The timing of space matters. A second fixture starts one row lower at
`(58,18)`, presses right on update 2, and reaches unsupported `(59,18)`
on update 3. Pressing space at that poll is recorded in the
[unsupported-space trace](state-ladder-space-on-exit.csv.gz), but no jump
is armed; Lad falls to `(59,19)` on update 4, exactly as in the
[no-space control](state-ladder-no-space.csv.gz). If space is instead read
on update 4 after Lad has reached supported `(59,19)`, the
[landing-space trace](state-ladder-space-after-exit.csv.gz) arms a jump
with counter `6`; Lad begins a full rightward arc on update 5. The key
therefore cannot start a jump while Lad is unsupported, but is accepted
on the first poll after landing.

The original jump-key path at `$484D..$4897` reads the tile below Lad and
branches away from jump arming for an empty unsupported cell; the accepted
path sets `$0F93` active and `$0F97=6`. Pascal's `OnSolid` check and
FLEX's `key_jump` support check cover this empty-cell case, though Pascal
differs when `H` is immediately below. Input and
movement scheduling now have a whole-loop FLEX CPU comparison for this
specific edge, described below.

Reproduce the right exit with `--start-level 1 --speed 1 --updates 12
--poke-after 1:0F89:003A,1:0F8B:0011,1:0F9D:0000,1:0F9F:0000
--key-at 2:36`. For the unsupported-space case, set Y to `0012`, use
`--updates 13`, and pass `--key-at 2:36,3:20`. Pass those options to
`tools/run_ladder_state.py` with `--emulator`, `--output`, and `--name`.

The ledge run separates ordinary falling from horizontal travel. After
leaving the upper platform at X=48, Lad falls one row per update for four
updates with X unchanged. The raw movement word `$0F9F` is `2` during the
fall; after landing, it returns to `3`, and the saved left request resumes
on the next update. The Pascal `FALLING` path likewise increments Y by one
and resumes `DirRequest` on solid ground. This observation covers one open
shaft; wall and ladder-adjacent falls remain to test.

The [Long Island map comparison](MAP_PARITY.md) adds a second fall case:
the original has no floor at `(7,18)`, so Lad placed at `(7,17)` falls two
rows to `(7,19)` and stops. A nearby supported control stays in place.
The Pascal layout includes floor at `(7,18)`, which would prevent this fall;
using its map in FLEX would change the physics even with identical movement
code.

## Change direction during a jump

From `(6,19)`, key `6` starts running right. Space on update 2 starts a
rightward jump; the [control](state-jump-right-control.csv.gz) moves through
`(8,18)`, `(9,17)`, `(10,17)`, `(11,17)`, `(12,18)`, `(13,19)` on updates
3–8. Sending `4` on update 4, while ascending, leaves update 4 at `(9,17)`
and changes the next states to `(8,17)`, `(7,17)`, `(6,18)`, `(5,19)`.
Sending `4` on update 5, at the apex, leaves `(10,17)` on that update and
then moves to `(9,17)`, `(8,18)`, `(7,19)`. Both
[ascent](state-jump-reverse-ascent.csv.gz) and
[apex](state-jump-reverse-apex.csv.gz) reversals preserve the six-step
vertical phase and continue left after landing.

The Pascal rewrite stores jump direction in `JUMPRIGHT` or `JUMPLEFT` and
only applies a left/right request after the jump ends. FLEX's `move_jump`
now reads the current horizontal direction on each jump step, allowing a
midair left/right change. A whole-loop FLEX CPU check now confirms that the
direction key takes effect on the following movement iteration.

Stop also changes the horizontal part of a jump without resetting its
vertical phase. Pressing `5` on update 4 of the same rightward jump leaves
Lad at `(9,17)` on update 5, holds X=9 through the apex and descent, and
lands at `(9,19)` on update 8. The jump counter still counts from `4` to
`0`; the [ascent stop trace](state-jump-stop-ascent.csv.gz) preserves it.
Stopping at the apex similarly lands at X=10 in the
[apex stop trace](state-jump-stop-apex.csv.gz). If `6` is sent on update 6
after the ascent stop, horizontal movement resumes on update 7 while the
same jump is descending; see
[stop then right](state-jump-stop-then-right.csv.gz).

In Pascal, a `STOPPED` request while `JUMPRIGHT` is active changes `Dir` to
`STOPPED` before the jump path is evaluated, so it does not retain the same
arc. FLEX now clears the live horizontal direction on Stop while leaving
its jump step active, matching the original's separate horizontal and
vertical phases in this case. The whole-loop FLEX CPU check confirms the
following-iteration stop timing with stubbed keyboard calls.

## Running jump into a wall

Ghost Town's original tile table has a vertical wall (code `4`) at
`(71,9)`–`(71,10)`, with support beneath `(69,10)` and `(70,10)`. The
[interior-wall trace](state-wall-jump-ghost-wall.csv.gz) starts displayed
level 5 and, after update 1, places Lad at `(69,10)` moving right. Space
on update 2 moves Lad to `(70,10)` and arms a six-step jump. The next
target would be wall `(71,9)`. Instead, update 3 leaves Lad at `(70,10)`,
changes horizontal direction `4→3` (right to left), and leaves the jump
counter at `6`. Update 4 moves him left and up to `(69,9)`, reducing the
jump counter to `5`; the six successful jump steps then run normally.
The [open control](state-wall-jump-ghost-open.csv.gz) starts three columns
earlier and moves right and up on update 3 as expected.

The same response appears at Easy Street's right boundary wall:
[wall trace](state-wall-jump-jump-wall.csv.gz) and
[open control](state-wall-jump-jump-open.csv.gz). The original destination
tile dispatch after `$4F08` sends code `4` to `$4F54`, which reverses the
horizontal direction through the table at `$0E5E`, restores the previous
coordinates, and skips the jump-counter decrement at `$4F78`. A wall
therefore costs one movement update, reverses horizontal motion, and
*pauses* the vertical jump phase rather than canceling it.

Reproduce the interior-wall case with:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-wall-jump --speed 1 --start-level 5 \
  --updates 11 --poke-after 1:0F89:0045,1:0F8B:000A,1:0F9D:0004,1:0F9F:0004 \
  --key-at 2:20 --name ghost-wall
```

The Pascal rewrite's blocked-jump branch sets `Dir` to its saved request
and clears `JumpStep`. FLEX's jump path now reverses the live horizontal
direction at a `|` wall or horizontal boundary and leaves its jump step
unchanged, so the next successful step resumes the arc. The source follows
the original rule; a runtime port trace remains to be captured.

## Solid and disposable ceilings

Tunnel Vision has an empty player cell `(40,5)` with ordinary floor code
`2` at `(40,4)` directly above and `(40,6)` directly below. The
[standing ceiling trace](state-jump-ceiling.csv.gz) places Lad at `(40,5)`
after update 1 and presses space on update 2. The jump is armed with
counter `6`, but update 3 stays at `(40,5)`, clears the active jump word
`$0F93` to zero, and leaves the counter at `6`. Lad remains supported and
stationary through update 10. An [open control](state-jump-open.csv.gz)
at `(49,5)` follows the normal six-step jump. With a rightward run under
the same solid ceiling, the [running trace](state-jump-ceiling-running.csv.gz)
stays at `(41,5)` on the blocked update, then continues right along row 5;
the vertical jump does not resume.

Point of No Return provides a different ceiling: disposable floor code
`1` at `(48,12)` over Lad at `(48,13)`, with another disposable floor
cell supporting him at `(48,14)`. The
[disposable-ceiling trace](state-jump-disposable-ceiling.csv.gz) shows a
full standing jump through the upper `-` tile: Y goes `12,11,11,11,12,13`
on updates 3–8. The jump is not interrupted, and the lower floor still
supports Lad after landing.

The original destination-tile dispatch after `$4F08` routes tile code `1`
to the normal jump-step path at `$4F78`, while solid floor code `2` goes
to `$4F45`, which restores the old position and proceeds to cancel the
active jump without decrementing the raw counter. These code paths and
traces confirm that ordinary floor blocks a jump from below, while a
disposable floor is passable during the arc. Pascal's jump collision case
lists both `=` and `-` as blocking, so its disposable-floor ceiling
behavior differs from the original. FLEX's jump path now lets `-` through
while still blocking `=`; its ordinary movement's `is_wall` test remains
separate.

Reproduce the solid ceiling case with `--start-level 9 --speed 1
--updates 10 --poke-after 1:0F89:0028,1:0F8B:0005,1:0F9D:0000,1:0F9F:0000
--key-at 2:20`. For the disposable ceiling, use `--start-level 14` and
`--poke-after 1:0F89:0030,1:0F8B:000D,1:0F9D:0000,1:0F9F:0000` with
the same key schedule. Pass those options to `tools/run_ladder_state.py`
with `--emulator`, `--output`, and a distinct `--name`.

## Comparison

The Pascal rewrite's `jumpPaths` table in `Ladder/src/ladicons.pas` has six
steps for a moving jump (`UPRIGHT,UPRIGHT,RIGHT,RIGHT,DOWNRIGHT,DOWNRIGHT`),
which matches this unblocked original run. Its standing jump table has five
steps (`UP,UP,STOPPED,DOWN,DOWN,ACTIONEND`), so it has one apex pause where
the original trace has two. The Pascal `MoveActor` code also stops a jump on
an `H` ladder cell; that is consistent with the interrupted middle-ladder
capture, though the exact subsequent climb state needs a dedicated comparison
run. The FLEX port's `move_jump` now uses six steps for both moving and
standing jumps, matching the original's vertical arc. It also uses live
horizontal direction, pauses and reverses at a wall, interrupts on `H`,
and passes through `-` during a jump. These source changes have assembled;
the assembled routine also passes the direct CPU checks below. A tick-aligned
full-game comparison remains open.

### FLEX jump CPU check

Run `make test-jump` from this directory. It builds
`tools/probe_flex_jump.cpp` against the project's 6800 CPU and executes the
assembled `move_jump` from `ladder.bin`, using addresses from `ladder.lst`.
The check asserts X, Y, direction, and jump step after every routine call.
It covers the original six-step standing arc, moving arc with midair reverse,
stop and resume, a boundary wall and an interior `|` wall that reverse and
pause the arc, one-cell ladder interruption, solid `=` ceiling cancellation,
and passage through a disposable `-` ceiling. The expected paths come from
the original traces cited above. The harness also executes one full
assembled `game_loop` iteration at a time with synthetic FLEX `poll`/`getc`
results. It checks that a right key or space read in one iteration affects
movement in the next, and that reverse and stop requests made during a jump
take effect on the following movement step. This matches the update ordering
in the original traces. A synthetic ledge case runs the entire assembled
loop: Lad steps from `(10,17)` to unsupported `(11,17)`, falls one row on
the next iteration, then resumes the saved right request. Space read over
the gap does not arm a jump; space read after landing does, and the next
iteration begins the jump. The port's real hardware tick duration and
keyboard service behavior are still unmeasured. For the
ladder-base case it also calls assembled `key_jump` and `move_player`,
checks that the down direction persists at row 19, and verifies the hop
to row 18 followed by a return to row 19 on the next movement call.

Reproduce the middle-ladder run after building the patched iz-cpm:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-physics --speed 1 --updates 70 \
  --first-key 6 --when 58:19:38,58:17:20 --name jump-ladder-mid
```

The `--when` entries are ordered `X:Y:HEXKEY`; `38` is ASCII `8` and `20`
is space. Other runs use `--when 6:19:20` for the standing jump,
`--first-key 6 --when 58:19:20` for the running jump, and
`--first-key 6 --when 58:19:38,58:15:20` for the ladder-top jump.
For the ledge fall, use `--first-key 6 --when 58:19:38,58:15:34`.
For the stopped-ladder sequence, use `--first-key 6 --when 58:19:38
--key-at 55:35,56:20,58:20`; `35` is ASCII `5` (Stop).
