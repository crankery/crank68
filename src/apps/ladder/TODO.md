# Ladder roadmap

The current `LADDER.CMD` plays Easy Street on an 80×24 ANSI terminal. Lad can
walk, climb, jump, and fall; five Der Rocks are released and move through the
board. Fire or rock contact costs a life, and treasure ends the level. All seven 79×20 maps have been extracted from the Turbo Pascal
rewrite, but only Easy Street is wired into the game. Keep each milestone
playable on C68 FLEX.

## 1. Put Der Rocks on Easy Street

- [x] Keep terrain and actors separate, so drawing or erasing Lad and rocks
      always restores the tile underneath. Use a fixed rock pool sized for the
      largest Pascal level (eight rocks) rather than dynamic allocation.
- [ ] Read `V` dispenser locations from the selected map. Release one rock
      per game update until the level's active-rock limit is reached, choosing
      a dispenser for each release. Use a reproducible seed for emulator
      checks; see [rock probes](analysis/ROCK_PROBES.md).
- [x] Make rocks roll, reverse at edges and obstructions, fall through gaps,
      and react to ladders. A `*` eater removes a rock and returns it to a
      dispenser; it does not hurt Lad.
- [x] Check Lad and rock collisions before and after rock movement. Give Lad
      visible death feedback and restart the level cleanly, with no stale
      actors or terminal marks.
- [ ] Test spawning, rolling, falling, eating, collision, and restart in the
      emulator. Play Easy Street with rocks on the throttled terminal.
      Assembled CPU probes now cover release, falling, edge reversal, eater
      recycling, RNG boundaries, lethal contact, and pool reset. Manual terminal
      play and more terrain cases remain.

## 2. Restore the game's stakes

- [ ] Start with five Lads. Lose one to a rock, fire, or expired bonus time;
      restart the level while lives remain, then show game over.
      Rock and fire deaths now consume lives; bonus expiry remains.
- [ ] Add the level's initial bonus time and decrement it every 25 game
      updates, as measured in the [state traces](analysis/STATE_TRACE.md).
- [ ] Show lives, level, score, and bonus time on the status line. Refresh only
      changed fields so gameplay does not stall on terminal output.
- [ ] Award points for statues (`&`), jumping over rocks, and finishing with
      bonus time left. Remove a collected statue from the active field and
      award an extra Lad at the score threshold.
- [ ] Test time expiry, all death causes, score changes, and the extra-life
      threshold with controlled tick and random inputs.

## 3. Make all seven levels playable

- [x] Extract and assemble all seven Pascal maps as 79×20 `.inc` files.
- [ ] Select a map by level number and find its `p` start, `V` dispensers,
      initial bonus time, and rock count. Copy terrain into mutable level
      state so collected statues and disappearing floors do not alter the
      source maps. Preserve that mutable terrain on a life restart; reload
      it only when advancing to a new board, as the original does.
- [ ] Advance on `$` through Easy Street, Long Island, Ghost Town, Tunnel
      Vision, Point of No Return, Bug City, and GangLand. Follow the
      expanding repeat cycle confirmed for displayed levels 1–12 in the
      [level-N probes](analysis/START_LEVEL_CHEAT.md). The shortcut sweep
      through level 57 finds a 27-level wave and a reset after GangLand;
      controlled GangLand treasure completions confirm that boundary at
      levels 27, 54, and 81. A full playthrough remains to test.
- [x] Implement original disposable floor (`-`) departure behavior, including
      preservation during a jump apex.
- [ ] Implement original trampoline (`.`) behavior. Keep `^` fire lethal, and confirm all special tiles
      behave sensibly on every map.
- [ ] Check each map for exactly one start, valid dispenser positions,
      bounded movement, and a reachable treasure. Run a full seven-level
      emulator path and play the harder maps by hand. Compare Pascal terrain
      with the original tile tables; the [seven-board comparison](analysis/MAP_PARITY.md)
      found 58 terrain-cell differences, now applied to generated FLEX maps.

## 4. Finish the terminal game

- [x] Add the original style title screen, playable menu choices, instructions,
      difficulty speed cycle, and idle taunts.
- [x] Return to the start menu after the last Lad dies; Play starts a fresh run.
- [ ] Add pause/resume and a full level-complete flow. Always
      restore the cursor when returning to FLEX.
- [ ] Add optional sound and a small high-score table once scoring is stable.
      Decide whether to use a new FLEX data file or read the CP/M `LADDER.DAT`
      format; do not overwrite the original file during experiments.
- [ ] Revisit ladder entry and speed choices after the core game is present.
      The current pace is intentionally left alone for now.
- [ ] Keep `LADDER.CMD` within FLEX application RAM (`$0300`–`$7DFF`) and
      verify the packaged disk image as features are added.

## Original game research

Use [the gameplay validation plan](analysis/GAMEPLAY_VALIDATION_PLAN.md) to
record repeatable probes and compare the original game, Pascal rewrite, and
FLEX port. The [rule matrix](analysis/RULE_MATRIX.md) shows the current
comparison. The original game's behavior decides gameplay rules.

- [ ] Inventory the files in `cpm/`, record their source and checksums, and
      keep pristine copies before disassembly or patching.
- [ ] Identify the compiler/runtime signatures in the original `LADDER.COM`.
      Resume `BASLIB.REL` matching if a promising candidate turns up; otherwise
      map code and data by observing the executable in a CP/M emulator.
- [x] Capture one state row per original-game update, including Lad and actor
      slots, score, bonus, lives, level, input, and instruction count. See
      [the first state traces](analysis/STATE_TRACE.md); downward actor states
      and transitions still need decoding.
- [ ] Probe Lad and Der Rock movement, including speed settings, jumps from
      ladders, falls, rock release, obstacles, eaters, and collision order.
      [The first jump probes](analysis/PHYSICS_PROBES.md) establish the
      unblocked arc and one ladder interruption. [Rock probes](analysis/ROCK_PROBES.md)
      establish one-per-update release, dispenser selection on Ghost Town,
      eater recycling, and several ladder and wall turns.
- [ ] Isolate each scoring event and measure bonus countdown and extra-life
      thresholds in the original game. [The scoring probes](analysis/SCORING_PROBES.md)
      confirm statue, treasure, and the first two extra-Lad thresholds;
      a controlled rock pass also confirms two separate two-point awards.
      [Bonus expiry probes](analysis/BONUS_TIMEOUT_PROBES.md) confirm life loss,
      same-level restart, and score preservation. Other collision
      configurations remain open.
- [ ] Audit remaining guessed rules: terrain effects, input persistence, life
      restart, map progression, and level cycling. Record original/Pascal/FLEX
      differences before changing gameplay code. The
      [level-N fixture](analysis/START_LEVEL_CHEAT.md) now reaches later
      boards and confirms two complete 27-level map waves through level 54.
      [Fire probes](analysis/TERRAIN_AND_DEATH_PROBES.md) confirm same-level
      restart with one lost Lad and unchanged score.
