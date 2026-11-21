# Original Ladder gameplay validation

The original CP/M `LADDER.COM` is the reference for gameplay rules. The Turbo
Pascal rewrite is a useful hypothesis source, and `flex/ladder.s` is the port
we will compare against it. A rule is **confirmed** only when a specific code
path and a repeatable run agree. Record the address, initial state, input or
random trigger, observed state changes, and any difference in the Pascal and
FLEX versions. Keep copies of `LADDER.COM` and `LADDER.DAT` for emulator runs;
the game can update the DAT file.

The [rule matrix](RULE_MATRIX.md) collects confirmed original behaviors and
the current Pascal and FLEX comparison in one place.

## First: measure game updates

The existing iz-cpm patch logs game-to-runtime calls and can inject a few
position-triggered keys. Its terminal captures count cursor commands, and
the call log does not record every game branch or memory write. Extend that
instrumentation to record a compact state row once per completed game update:
instruction count, input, Lad position and movement state, active rock slots
and positions, score, bonus, lives, level, and any random result that changes
an actor. Use the known gameplay poll `$47ED`, actor index at `$0FB2`, actor
tables at `$0E68/$0E7E/$0E94`, and HUD words at `$0F05/$0F77/$0F67/$0F69`
as starting points. First verify which table slot is Lad and which are rocks;
the [actor analysis](HUD_AND_ACTORS.md) has not established every slot yet.

Use repeatable key schedules tied to a game update or observed position. For
random behavior, capture the random values and either replay them or compare
several runs. Report rates in updates and CPU instructions first; convert to
elapsed time only after checking the original game's speed setting and the
emulator's CPU pacing. Keep output overhead separate from game logic timing.

## Rules to establish

| Priority | Question | Discriminating probes | Existing lead |
| --- | --- | --- | --- |
| 1 | How often do Lad and rocks move at each play speed? | Hold a direction on open floor at each menu speed; compare position changes and update/instruction counts. | `$47ED` polls input; `$48B0..$4BE4` iterates actors. |
| 1 | What are the exact jump, climb, and fall paths? | Standing and running jumps; jump at ladder base, on ladder, at ladder top, near a wall or edge; release or reverse direction mid-jump; walk off a ledge and land. Record X/Y and movement state each update. | `$4CD8` and `$4D44` change Y during climb/fall; the [left-turn trace](LEFT_TRACE.md) confirms those paths execute. |
| 1 | How do Der Rocks choose and change direction? | Observe release from each dispenser, open-floor rolling, edges, walls, gaps, ladder tops and shafts, rock eaters, and rock-to-rock contact. Repeat random cases with captured draws. | Actor tables and spawn-looking code at `$47A0..$47D7`; the [left-turn capture](LEFT_TRACE.md) shows rocks rolling into an eater. |
| 2 | When is a collision or a jump-over counted? | Place Lad and rock at the same X on successive updates, including one and two rows apart; compare pre-move and post-move checks and score changes. | The Pascal rewrite checks collisions both before and after each rock move; original behavior remains to be verified. |
| 2 | What scores come from statues, rocks, treasure, and time? | Isolate each event and log `$0F05` before/after; repeat at different bonus values and near the extra-life threshold. Check whether displayed `00` is a multiplier or formatting. | [HUD analysis](HUD_AND_ACTORS.md) identifies score storage; Pascal gives statue = remaining bonus, rock jump = 2, treasure = remaining bonus, but these are hypotheses for the original. |
| 2 | How fast does bonus time fall, and what resets its clock? | Hold Lad still at each play speed; record updates/instructions between `$0F77` decrements, then compare during movement, terminal output, life loss, and level change. | `$4C06..$4C0A` decrements the bonus word; Pascal uses a three-second interval, unverified for the original. |
| 3 | Which other assumed rules differ? | Audit lives and restart, input persistence, disposable floor, fire, trampolines, rock release, map selection, level cycling, and extra lives with one-event runs. | The [roadmap](../TODO.md) and Pascal rewrite contain several current assumptions. |

## Evidence and completion criteria

For each rule, add a small entry with the observed sequence and the relevant
compiled-code branch or write. Mark it **confirmed**, **likely**, or
**unresolved**; do not promote a Pascal rule to confirmed without original-game
evidence. Keep at least one repeatable trace for each deterministic case and
multiple runs or a captured random draw for stochastic cases. Note the
original/Pascal/FLEX result side by side, then update the FLEX implementation
from the confirmed rule. A matching screen alone is insufficient for timing
or collision order; compare state changes on the same game updates.

The first deliverable, the [update trace and baseline runs](STATE_TRACE.md),
now records Lad coordinates, raw actor slots, score, bonus, and inputs on each
sample. The next instrumentation step is to decode actor status values and
capture or replay random draws for controlled rock experiments.

The first [jump and ladder probes](PHYSICS_PROBES.md) confirm six-step
unblocked jumps and show a jump interrupted by a ladder cell. Continue with
edges, walls, reversals during a jump, ordinary falls, and rock collisions.
FLEX's standing jump now runs the same six vertical steps as the original,
and its jump path reads live horizontal direction for midair steering.
Its source also interrupts a jump on `H`, reverses and pauses at a wall,
and passes through `-` during a jump. The [FLEX CPU probe](PHYSICS_PROBES.md#flex-jump-cpu-check)
executes the assembled `move_jump` and checks coordinates, direction, and
jump step for these cases. It also runs complete `game_loop` iterations with
stubbed keyboard calls, confirming that a key read affects movement on the
next iteration. Real hardware tick duration and keyboard behavior remain open.
The stopped-ladder probe now shows that each space press moves Lad up one
ladder cell and then stops; FLEX now ends a jump after entering `H`.
The [manual descent probe](PHYSICS_PROBES.md#manual-descent-and-space-at-the-ladder-base)
confirms one row per update on a ladder and shows that a down request
persists at the blocked base. Space from that state rises one cell, then
the retained request moves Lad back down on the following update. FLEX now
retains its down direction at row 19; the direct CPU probe executes
`key_jump` and successive `move_player` calls to confirm the one-cell hop
and return. The whole-loop CPU check covers input ordering, but not hardware
pacing.
The [Bug City ladder-entry fixture](PHYSICS_PROBES.md#enter-a-ladder-from-a-supported-plain-cell)
shows that Up can enter `H` or `&` above a supported plain cell. An
adjacent cell without `H` above stays put, while unsupported cells fall,
including one with `H` immediately below. Pascal requires Lad's current
cell to be `H` for Up and counts `H` below as support. FLEX now matches
the original in the tested cases; assembled CPU probes cover them.
The [all-code support sweep](PHYSICS_PROBES.md#which-tiles-support-lad-from-below)
finds that only original codes `1`–`5` below hold Lad up and permit a
jump. Pascal instead includes `H` and omits `$` and `V`. FLEX's support
and jump checks now follow the original, with assembled CPU checks across
all eleven tile codes and the new jump cases.
The [destination sweeps](PHYSICS_PROBES.md#which-tiles-lad-can-enter-sideways-or-downward)
show distinct passability: sideways movement blocks `=` and `|`, while
downward movement from `H` also blocks `-` and `V`. Pascal's sideways
set matches, but its downward set excludes `*`, which original Lad can
enter. FLEX now has separate tile checks and assembled CPU probes for
both eleven-code sweeps; special-tile effects remain unfinished.
The [blocked-request probes](PHYSICS_PROBES.md#blocked-movement-requests-persist)
show that Right, Down, and Up remain requested across blocked updates and
resume without another key when terrain permits movement. Pascal stops
Right and Down; it retains Up but requires the current cell to be `H`.
FLEX preserves all three requests in assembled CPU checks.
The [standing-jump destination sweep](PHYSICS_PROBES.md#jump-destination-tile-sweep)
checks all eleven codes at one ascent target. `=` cancels, `|` pauses,
`H` interrupts, and `-` or `V` lets the jump continue. Pascal blocks
`-` during jumps; FLEX matches the original immediate jump phase in
assembled CPU checks. Its score, life, and level effects remain open.
The [sideways ladder-exit probes](PHYSICS_PROBES.md#step-sideways-off-a-ladder-and-press-space)
show one horizontal step, two one-row falls, and resumed horizontal motion
after landing. Space read while unsupported does not arm a jump; space
read on the first supported poll after landing does. The whole-loop FLEX
CPU probe now confirms one-row falling, resumed horizontal motion, and
the same unsupported-versus-supported space timing on a synthetic ledge.
The midair reversal probe shows that a direction key changes horizontal
motion on the next movement update while the six-step vertical jump phase
continues. Stop freezes horizontal motion while the vertical phase
continues; another direction key resumes it midair. Pascal still models
these midair requests differently; FLEX now follows the same direction
rule; the whole-loop CPU check confirms next-iteration input timing for a
midair reversal and stop.
The [interior-wall jump probe](PHYSICS_PROBES.md#running-jump-into-a-wall)
confirms that an attempted jump step into tile code 4 pauses the jump
counter for one update, reverses horizontal direction, and then resumes
the vertical arc. FLEX now follows this wall rule in source; Pascal still
cancels the jump.
The [ceiling probes](PHYSICS_PROBES.md#solid-and-disposable-ceilings)
confirm that solid floor code 2 cancels a jump from below, while disposable
floor code 1 allows the full jump through it. Pascal blocks both tile
types; FLEX's jump path now passes through `-` while ordinary movement
still treats it as a wall.

The [rock probes](ROCK_PROBES.md) confirm one release per update until five
rocks are active on Easy Street and Ghost Town, show per-release dispenser
selection on Ghost Town, and show two eater-to-dispenser cycles.
The [five-speed choice counts and RNG probe](ROCK_PROBES.md#observed-random-choice-frequencies)
recover `state = 5*state + 3` modulo `2^32` and exact 3-way/2-way bucket
formulas from its low 24 bits. Actual rock events sample that deterministic
sequence according to terrain and earlier choices; their observed frequencies
are not independent draws.
The [seven-board rock-limit probes](ROCK_PROBES.md#rock-limit-on-every-board)
confirm active caps of 5, 8, 5, 5, 7, 6, and 6, reached by releasing one
rock per update. Those caps match Pascal's board data even though its
release schedule differs.
The [paired vertical rock choices](ROCK_PROBES.md#two-downward-statuses)
show that statuses 1 and 2 both step downward on a ladder. The random
reverse outcome swaps them without reversing vertical motion; Pascal's
rock ladder choice does not run while descending.
Controlled [status-1/status-2 landing pairs](ROCK_PROBES.md#two-downward-statuses)
also show the same result on empty and solid cells below: an ordinary
fall becomes status 2, while either status makes the same stationary
landing turn under the sampled RNG state.
The Ghost Town `(33,10)` traces map all three observed choice values at one
ladder cell: reverse, descend, or continue rolling. At an Easy Street ladder
cell with solid ground below, the descent choice keeps the rock on its row
and reverses it. At a Ghost Town vertical obstruction, a left-moving rock
turns in place for one update before moving right. An open Ghost Town shaft
shows four one-row falls, a stationary landing turn, then resumed rolling.
The [landing-direction probes](ROCK_PROBES.md#landing-selects-a-new-horizontal-direction)
show that the turn chooses left or right and can oppose the direction
before the fall. Pascal instead resumes its saved horizontal request.
The Easy Street idle trace also shows 13 stationary edge reversals followed
by inward motion on the next update. Opposing rocks can occupy one cell and
pass through each other without changing direction.
The [above-ladder probe](ROCK_PROBES.md#a-rock-one-cell-above-a-ladder)
shows that the original sends a horizontally rolling rock straight down
from an empty cell with `H` below, without making a random ladder choice
until the rock occupies `H`. Pascal instead randomizes at the cell above.
The [rock terrain probes](ROCK_PROBES.md#terrain-a-rolling-rock-can-enter)
show the original entering eater, fire, trampoline, and statue cells while
turning away from disposable floor. The
[eleven-code sweep](ROCK_PROBES.md#terrain-a-rolling-rock-can-enter)
confirms that codes `1`–`5` all cause a stationary turn, while code `0`
and `6`–`10` admit the rock. Pascal's `EmptySpace` would also admit
`-`, `$`, and `V`; FLEX has no rocks yet.
The [falling-rock code sweep](ROCK_PROBES.md#open-gap-and-landing)
confirms the same code boundary below a descending rock. Codes `1`–`5`
cause a stationary landing turn; code `0` and `6`–`10` allow a one-row
fall. Pascal's `OnSolid` instead supports on `H` and omits `$` and `V`.

The [level-N fixture](START_LEVEL_CHEAT.md) can now start a run on later
original boards for those multi-dispenser and terrain probes. The first
twelve displayed levels follow the Pascal rewrite's expanding map cycle
and two-point bonus reduction. The
[level 1–57 map sweep](START_LEVEL_CHEAT.md#full-seven-board-waves-and-bonus-adjustment)
finds a 27-level wave that resets its board-prefix length after GangLand;
Pascal continues growing `levelCycle` instead. The original also keeps
the same bonus baseline at each wave reset before reducing it again.
Controlled [GangLand treasure completions](START_LEVEL_CHEAT.md#controlled-gangland-treasure-completions)
at levels 27, 54, and 81 follow the unmodified completion path and reach
Easy Street with the shortcut's predicted bonus and dispenser.

The [scoring probes](SCORING_PROBES.md) confirm that a statue adds the
current bonus once, treasure transfers remaining bonus to score, and the
first two extra-Lad thresholds are 100 and 200 internal points. A controlled
300-point statue award grants only one Lad despite crossing three thresholds.
A [paired timeout-restart fixture](SCORING_PROBES.md#collected-statue-survives-a-life-restart)
also confirms that an already collected statue stays absent after a life
loss, while an untouched statue remains collectible. Pascal reuses its
mutable field at `restartLevel`; FLEX has no statue logic yet.
A rock-side award can bring score to 100 one sampled update before the
player-side score refresh grants the extra Lad; Pascal checks immediately.
A controlled
rock jump scores twice on one pass, through distinct player-side and
rock-side checks. One-row and two-row vertical separations both score on
rock arrival. The compiled paths have no third-row check and require an
empty intervening tile for two-row scoring. An
[eleven-code score-gap sweep](SCORING_PROBES.md#rock-jump-points-and-collision-order)
confirms that only code `0` in that cell permits either two-point award;
codes `1`–`10` suppress both writes. Other motion combinations remain.
The [ladder-cell score fixture](SCORING_PROBES.md#a-rock-on-a-ladder-cell-can-score)
confirms that the original can award two-row rock points when the rock's
own cell is a ladder, provided the intervening cell is empty. Pascal's
two-row check would reject that configuration because it also requires
the rock cell to be blank.
The [same-row collision fixtures](SCORING_PROBES.md#same-row-collision-before-and-after-a-rock-step)
show that entering a rock's current cell is lethal even if the rock would
leave it that update, and that a rock arriving at stationary Lad is also
lethal. Pascal's pre-move and post-move rock checks cover these cases;
FLEX still needs rock collision handling.
The [eater-cell contact probe](SCORING_PROBES.md#rock-contact-on-an-eater-tile)
shows that a rock entering an eater still kills Lad if he occupies the
cell; the eater removes the rock on the following update. Pascal's
source predicts the same order.
The [jump-contact fixtures](SCORING_PROBES.md#rock-contact-during-a-jump)
show death both when Lad rises into a rock's current cell and when a rock
falls into Lad's new cell. The latter holds for both original downward
statuses, with an adjacent-column control remaining safe.

The [bonus expiry probe](BONUS_TIMEOUT_PROBES.md) confirms that reaching zero
costs one Lad and restarts the same board with its initial bonus while
preserving score. The restarted countdown resumes on subsequent updates. With
one Lad remaining, the same expiry reaches the zero-Lads score-table branch.
The [countdown phase probes](BONUS_TIMEOUT_PROBES.md#countdown-phase-after-a-restart-or-new-board)
confirm that both a fire-death restart and a treasure-triggered new board
reset the 25-update timer; each first post-event sample has counter 24.
The existing statue route shows the opposite event behavior: collection
at update 104 leaves the counter at 21, and the next bonus decrement
still occurs at update 125. Pascal also leaves its timer phase intact
when collecting a statue.
The [timing comparison](BONUS_TIMEOUT_PROBES.md#update-rate-versus-elapsed-time)
shows the same decrement updates across all five menu speeds and two
Ghost Town rock runs despite varying instruction counts. The
[delay-word probes](STATE_TRACE.md) isolate a 16-instruction loop and
1000/750/500/250/0 delay counts at speeds 1–5. A measured wall-clock
conversion remains open.
The [negative-bonus probe](BONUS_TIMEOUT_PROBES.md#negative-bonus-after-many-level-waves)
shows that a high-level wrapped bonus continues decrementing without a
life loss, because the original checks for exactly zero; Pascal checks
for nonpositive time. This uses the level-N shortcut.

The [fire probe](TERRAIN_AND_DEATH_PROBES.md) confirms a fire contact also
costs one Lad and restarts the board without changing score. The Ghost Town
tile dump differs from the Pascal map at four lower flame cells. The
[seven-board map comparison](MAP_PARITY.md) finds 58 terrain-cell
differences, including a lethal original fire tile where Pascal has a rock
eater. The FLEX maps now apply these original terrain corrections.

The [trampoline probes](TRAMPOLINE_PROBES.md) establish three original
outcomes: keep direction, reverse direction, or start a six-step jump while
keeping direction. A stopped player can remain on the tile through repeated
no-change or reversal outcomes. Pascal's five-outcome trampoline behavior
differs; FLEX does not yet handle trampolines. The
[RNG boundary probes](TRAMPOLINE_PROBES.md) now establish the exact
three-way choice ranges.

The [disposable-floor probe](DISPOSABLE_FLOOR_PROBES.md) confirms that the
original clears a `-` tile after Lad moves horizontally off the cell above
it through the ordinary movement path. A return to the now empty cell causes
a one-row-per-update fall. A straight-up jump leaves the floor, while a
running jump first makes an ordinary sideways step that removes it. A
controlled vertical climb above `-` also leaves the floor intact. A new
[jump-apex probe](DISPOSABLE_FLOOR_PROBES.md#sideways-motion-during-a-jump-apex)
shows that even a same-row sideways jump step preserves the floor; Pascal's
general same-row X-change condition would remove it. FLEX now handles
ordinary floor removal and preserves the tile during `move_jump`, both CPU
checked.
The [life-restart floor probes](DISPOSABLE_FLOOR_PROBES.md#removed-floor-survives-a-life-restart)
show that both bonus timeout and fire death preserve a previously removed
`-` tile. Pascal's `restartLevel` also reuses the mutable field; FLEX's
fire reset preserves it in an assembled CPU probe. A next-board load must
start from fresh terrain.
