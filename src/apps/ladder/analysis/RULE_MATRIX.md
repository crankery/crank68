# Ladder gameplay rule comparison

The original CP/M 1.10 game is the reference. Each **original** cell below
links to its detailed evidence. “CPU checked” means
the assembled FLEX routine ran on the project's 6800 CPU. The input timing
rows also have whole-loop checks with stubbed keyboard calls. “Source only”
means the behavior follows the current code but lacks that runtime check.

## Lad movement and terrain

| Rule and original evidence | Pascal rewrite | FLEX port |
| --- | --- | --- |
| [One horizontal cell per update at all five speeds](STATE_TRACE.md), with a counted delay of 1000/750/500/250/0 iterations | One cell per movement tick; nominal waits are 100/50/25/13/7 ms | One cell per loop in source; hardware pacing unmeasured |
| [Standing jump: up, up, apex, apex, down, down](PHYSICS_PROBES.md) over six movement updates | Five visible standing steps, with one apex pause | Six-step arc, CPU checked |
| [Moving jump: one horizontal cell on every one of six steps](PHYSICS_PROBES.md) | Six moving steps | Six steps, CPU checked |
| [Midair reverse, stop, and resume use the latest direction without resetting jump phase](PHYSICS_PROBES.md#change-direction-during-a-jump) | Opposite request waits; Stop changes the jump state | Live direction each step; reverse and stop timing CPU checked |
| [Space on a ladder gives one upward cell, then interrupts the jump](PHYSICS_PROBES.md#space-while-stopped-on-a-ladder) | Stops on `H` | One-cell interruption, CPU checked |
| [Down request survives a blocked ladder base; space hops one cell before the next down step](PHYSICS_PROBES.md#manual-descent-and-space-at-the-ladder-base) | `DOWN` has no jump-start arm | Down retention, jump, and return CPU checked |
| [A supported plain cell can climb into `H` or `&` above; `H` below alone does not support Lad](PHYSICS_PROBES.md#enter-a-ladder-from-a-supported-plain-cell) | Requires current cell `H` for Up; treats `H` below as support | Entry, blocked control, and unsupported falls CPU checked |
| [Only tile codes 1–5 below support Lad and permit a jump; current `H` also supports](PHYSICS_PROBES.md#which-tiles-support-lad-from-below) | Below support set is `-`, `=`, `H`, `\|`; includes `H`, omits `$` and `V` | Eleven-code support sweep and all five jump cases CPU checked |
| [Sideways entry blocks only on `=` and `\|`; descent from `H` also blocks `-` and `V`](PHYSICS_PROBES.md#which-tiles-lad-can-enter-sideways-or-downward) | Sideways matches; Down also blocks `*`, which original enters | Both eleven-code immediate destination sweeps CPU checked; special effects incomplete |
| [Blocked Right, Down, and Up requests resume automatically when terrain allows](PHYSICS_PROBES.md#blocked-movement-requests-persist) | Right/Down stop; Up persists but requires current `H` | Three recovery paths CPU checked |
| [Jump ascent enters codes 0, 1, 3, 5–10; `=` cancels, `\|` pauses, `H` interrupts](PHYSICS_PROBES.md#jump-destination-tile-sweep) | Blocks `-` as well as `=` and `\|` | Eleven-code immediate jump sweep CPU checked; score and level effects incomplete |
| [Space while unsupported does not start a jump; a supported poll after landing does](PHYSICS_PROBES.md#step-sideways-off-a-ladder-and-press-space) | Uses `OnSolid` | Whole-loop CPU checked with a synthetic ledge |
| [A jump into `\|` reverses horizontal motion and pauses the vertical phase for one update](PHYSICS_PROBES.md#running-jump-into-a-wall) | Cancels jump | Reversal and pause CPU checked |
| [Solid `=` cancels a jump from below; disposable `-` lets the jump pass](PHYSICS_PROBES.md#solid-and-disposable-ceilings) | Blocks both | Both cases CPU checked |
| [Unsupported Lad falls one row per update, then resumes horizontal request](PHYSICS_PROBES.md#step-sideways-off-a-ladder-and-press-space) | `FALLING` retains request | Whole-loop CPU checked with a synthetic ledge |
| [Ordinary horizontal departure removes `-` below; vertical movement and sideways jump-apex motion preserve it](DISPOSABLE_FLOOR_PROBES.md) | Removes on any same-row X change, including jump apex | Ordinary removal and jump-apex preservation CPU checked |
| [Removed `-` terrain persists after timeout or fire life restart](DISPOSABLE_FLOOR_PROBES.md#removed-floor-survives-a-life-restart) | `restartLevel` redraws the current mutable field | Fire reset preservation CPU checked; timeout missing |
| [Trampoline chooses keep direction, reverse, or jump using the RNG's three equal-width ranges; a stopped Lad may stay put](TRAMPOLINE_PROBES.md) | Five forced-direction and jump outcomes | Missing |
| [Fire costs one Lad, restarts same board, and preserves score](TERRAIN_AND_DEATH_PROBES.md) | Same broad consequence | Life loss, eleven-glyph death animation, and same-board restart CPU checked; score missing |

## Der Rocks

| Rule and original evidence | Pascal rewrite | FLEX port |
| --- | --- | --- |
| [One release per update until the board's cap; caps 5/8/5/5/7/6/6](ROCK_PROBES.md#rock-limit-on-every-board) | Caps match; each pending rock gets an independent 1-in-10 release chance | Easy Street five-rock cap and release CPU checked |
| [Dispenser is chosen on each release](ROCK_PROBES.md#multiple-dispensers-ghost-town); index uses a [3-way bucket of the RNG's low 24 bits](ROCK_PROBES.md#observed-random-choice-frequencies) | Chooses a dispenser when setting up or recycling a rock | Missing |
| [RNG state advances as `5*state+3` modulo `2^32`; low 24 bits determine 2-way and 3-way results](ROCK_PROBES.md#observed-random-choice-frequencies) | Calls Pascal `Random(2)`, `Random(3)`, or `Random(numDispensers)` at related events; original sequence is not reproduced | Low-24 recurrence and 3-way boundaries CPU checked; seed is fixed |
| [Horizontal travel is one cell per update; edges and `\|` take a stationary reversal update](ROCK_PROBES.md#horizontal-obstruction) | Reverses at edge and obstruction, but exact timing unverified | Implemented; edge timing CPU checked |
| [A rolling rock directly above `H` descends automatically](ROCK_PROBES.md#a-rock-one-cell-above-a-ladder) | Makes a three-way random choice above `H` | CPU checked |
| [On `H`, RNG choice 0 reverses, 1 descends, 2 continues; both downward statuses step and land alike on sampled terrain](ROCK_PROBES.md#two-downward-statuses) | Random choices apply only to horizontal rock states; `DOWN` and `FALLING` differ | Implemented; CPU check pending |
| [An open gap gives one downward cell per update; landing pauses and chooses a fresh left/right direction](ROCK_PROBES.md#landing-selects-a-new-horizontal-direction) | `FALLING` resumes its saved horizontal request | Implemented; one-cell fall CPU checked |
| [A falling rock descends into code 0 or 6–10; codes 1–5 cause a stationary landing turn](ROCK_PROBES.md#open-gap-and-landing) | `OnSolid` treats `H` below as support and omits `$` and `V` | Implemented; terrain matrix CPU check pending |
| [A rolling rock enters code 0 or 6–10; codes 1–5 turn it in place](ROCK_PROBES.md#terrain-a-rolling-rock-can-enter) | `EmptySpace` also admits `-`, `$`, and `V` | Implemented; terrain matrix CPU check pending |
| [Eater removes a rock, with an inactive update before dispenser release](ROCK_PROBES.md) | Reinitializes it as `PENDING`, with probabilistic release | Eater delay and re-release CPU checked |
| [Rocks can overlap and pass through one another](ROCK_PROBES.md#rock-to-rock-overlap) | No rock-to-rock collision check | Two rocks entering one cell CPU checked |

## Collision, score, timer, and levels

| Rule and original evidence | Pascal rewrite | FLEX port |
| --- | --- | --- |
| [Lad entering a rock's current cell and rock entering Lad's new cell are both lethal](SCORING_PROBES.md#same-row-collision-before-and-after-a-rock-step) | Checks before and after each rock move | Pre- and post-move checks implemented; post-move death CPU checked |
| [Exact-cell contact during a jump is lethal in either movement order](SCORING_PROBES.md#rock-contact-during-a-jump) | Has post-move exact-cell checks | Missing |
| [Lad on an eater dies when a rock enters that cell, before the eater recycles it](SCORING_PROBES.md#rock-contact-on-an-eater-tile) | Source predicts the same contact order | Missing |
| [A rock pass can award 2 points at each of two separate sites](SCORING_PROBES.md#rock-jump-points-and-collision-order) | Awards 2 on `Collision`; placement may also repeat an award | Missing |
| [One- and two-row separation score; two-row scoring requires exactly code 0 between Lad and rock, but allows rock on `H`](SCORING_PROBES.md) | Empty intervening cell matches; also requires rock's own cell blank | Missing |
| [A statue adds the current bonus once; treasure transfers the remaining bonus](SCORING_PROBES.md) | Same formulas | Missing; prototype treasure only ends level |
| [A collected statue remains absent after a life restart](SCORING_PROBES.md#collected-statue-survives-a-life-restart) | `restartLevel` reuses the mutable field | Missing |
| [Score thresholds 100 and 200 each add one Lad](SCORING_PROBES.md#extra-lads-at-score-thresholds) | Advances threshold by 100 | Missing |
| [A single award crossing several 100-point thresholds grants only one Lad](SCORING_PROBES.md#extra-lads-at-score-thresholds) | Same one-award limit | Missing |
| [A rock-side score can reach 100 one sampled update before the extra Lad is granted](SCORING_PROBES.md#extra-lads-at-score-thresholds) | `Collision` calls `UpdateScore` and checks the threshold with that award | Missing |
| [Bonus falls every 25 game updates at all five speeds](BONUS_TIMEOUT_PROBES.md#update-rate-versus-elapsed-time) | Uses a 3,000 ms interval | Missing |
| [Bonus at zero costs a life and resets board, score preserved; fire and new board reset countdown phase](BONUS_TIMEOUT_PROBES.md) | Same broad restart and reset, with millisecond phase | Missing |
| [Statue collection leaves the 25-update countdown phase intact](BONUS_TIMEOUT_PROBES.md#countdown-phase-after-a-restart-or-new-board) | Statue handler leaves millisecond phase intact | Missing |
| [A negative wrapped bonus keeps decrementing until exactly zero](BONUS_TIMEOUT_PROBES.md#negative-bonus-after-many-level-waves) | Expires at `<= 0` | Missing |
| [A 27-level wave repeats prefixes of 2–7 boards, resetting after GangLand](START_LEVEL_CHEAT.md#full-seven-board-waves-and-bonus-adjustment) | `levelCycle` continues growing; diverges at level 28 bonus and level 30 map | Only Easy Street wired in |
| [Seven original maps differ from Pascal at 58 terrain cells](MAP_PARITY.md) | Contains those 58 differences | FLEX maps are generated with the original terrain corrections |

## Open comparisons

The compiled FLEX game loop has CPU checks for key-to-movement ordering, but
real hardware timing and keyboard service behavior remain unmeasured.
Real elapsed time per original update, selected terrain edge cases, and a
complete FLEX rock/score/bonus implementation remain
open. The [validation plan](GAMEPLAY_VALIDATION_PLAN.md) links the detailed
fixtures and disassembly addresses for each area.
