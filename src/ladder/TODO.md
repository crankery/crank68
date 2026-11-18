# Ladder roadmap

The current `LADDER.CMD` plays Easy Street on an 80×24 ANSI terminal. Lad can
walk, climb, jump, and fall; fire returns him to the start, and treasure ends
the level. All seven 79×20 maps have been extracted from the Turbo Pascal
rewrite, but only Easy Street is wired into the game. Keep each milestone
playable on C68 FLEX.

## 1. Put Der Rocks on Easy Street

- [ ] Keep terrain and actors separate, so drawing or erasing Lad and rocks
      always restores the tile underneath. Use a fixed rock pool sized for the
      largest Pascal level (eight rocks) rather than dynamic allocation.
- [ ] Read `V` dispenser locations from the selected map. Place each rock in
      a pending state at a dispenser, then release it over time using a
      reproducible random seed for emulator checks.
- [ ] Make rocks roll, reverse at edges and obstructions, fall through gaps,
      and react to ladders. A `*` eater removes a rock and returns it to a
      dispenser; it does not hurt Lad.
- [ ] Check Lad and rock collisions before and after rock movement. Give Lad
      visible death feedback and restart the level cleanly, with no stale
      actors or terminal marks.
- [ ] Test spawning, rolling, falling, eating, collision, and restart in the
      emulator. Play Easy Street with rocks on the throttled terminal.

## 2. Restore the game's stakes

- [ ] Start with five Lads. Lose one to a rock, fire, or expired bonus time;
      restart the level while lives remain, then show game over.
- [ ] Add the level's initial bonus time and decrement it every three seconds
      of play. Keep timing tied to the game tick at the intended 1 MHz pace.
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
      source maps.
- [ ] Advance on `$` through Easy Street, Long Island, Ghost Town, Tunnel
      Vision, Point of No Return, Bug City, and GangLand. Decide the repeat
      cycle after checking the original game; the Pascal rewrite has a
      particular cycle and notes uncertainty about the original ending.
- [ ] Implement disposable floor (`-`) and trampoline (`.`) behavior from
      the Pascal source. Keep `^` fire lethal, and confirm all special tiles
      behave sensibly on every map.
- [ ] Check each map for exactly one start, valid dispenser positions,
      bounded movement, and a reachable treasure. Run a full seven-level
      emulator path and play the harder maps by hand.

## 4. Finish the terminal game

- [ ] Add a title screen, controls, pause/resume, and a clear game-over and
      level-complete flow. Always restore the cursor when returning to FLEX.
- [ ] Add optional sound and a small high-score table once scoring is stable.
      Decide whether to use a new FLEX data file or read the CP/M `LADDER.DAT`
      format; do not overwrite the original file during experiments.
- [ ] Revisit ladder entry and speed choices after the core game is present.
      The current pace is intentionally left alone for now.
- [ ] Keep `LADDER.CMD` within FLEX application RAM (`$0300`–`$7DFF`) and
      verify the packaged disk image as features are added.

## Original game research

- [ ] Inventory the files in `cpm/`, record their source and checksums, and
      keep pristine copies before disassembly or patching.
- [ ] Identify the compiler/runtime signatures in the original `LADDER.COM`.
      Resume `BASLIB.REL` matching if a promising candidate turns up; otherwise
      map code and data by observing the executable in a CP/M emulator.
- [ ] Compare movement, timing, rock behavior, scoring, and level progression
      against the original. Mark differences between it, the Pascal rewrite,
      and this 6800 port before changing gameplay rules.
