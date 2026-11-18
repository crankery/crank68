# ROGUE feature roadmap

The current `v7` game loads 26 varied 60×20 floors from FLEX files, with
exploration, gold, stairs, and descent. The goal is a small, playable dungeon game
on C68 FLEX, using an ANSI terminal with at least 60 columns and 22 rows.

## 1. Make room for game state

- [ ] Keep terrain, floor items, and actors separate. A dropped item or monster
      must not erase a doorway, stair, or floor tile.
- [ ] Define compact records for rooms, items, monsters, and the player, with
      fixed capacity limits and a clear response when a limit is reached.
- [ ] Give each input command one turn; invalid keys and blocked movement do
      not advance monsters. Add a message area for combat and item feedback.
- [ ] Keep the terminal drawing cache in step with changes to all three layers.
- [x] Use a fixed generator seed and emulator checks so the 26 packaged floors
      can be reproduced and validated.

## 2. Vary the dungeon

- [x] Expand the playfield toward 60×20, then generate rooms with varying
      width, height, and position. Start with the existing 3×3 room slots so
      generation stays bounded.
- [x] Choose doors and connect rooms with corridors, guaranteeing a path from
      the starting room to stairs. Horizontal connections are fixed per row;
      two vertical connections between each band of rooms vary by floor.
- [x] Place the player, stairs, and items only on valid, unoccupied floor cells.
      Keep the starting room safe when a level begins.
- [ ] Use the departure stair as the landing anchor on the next floor. Randomly
      shift the new floor's room-grid origin around that anchor, then generate
      rooms and passages so the landing cell is valid and connected. The player
      should not be able to infer room boundaries from a fixed upper-left
      origin after descending. Choose this offset once per floor; keep the
      whole floor fixed on screen as the player moves.
- [x] Generate layouts without overlaps, isolated rooms, unreachable stairs,
      or invalid boundary tiles by construction.
- [x] Test every packaged floor for connectivity, valid placements, and correct
      reveal of rooms of different sizes.

## 3. Add a first monster and combat loop

- [ ] Use the proposed roster and implementation order in [MONSTERS.md](MONSTERS.md).
- [ ] Add player hit points, monster hit points, damage, and death.
- [ ] Spawn a few visible monsters outside the starting room. Give them a
      simple turn: chase when nearby, otherwise wait or wander.
- [ ] Bumping into a monster attacks it; surviving monsters can attack on their
      turns. Show damage and kills in the message area.
- [ ] Prevent monsters from walking through walls or occupying the same cell.
      Define what happens when the player dies and how to start another game.
- [ ] Test attacks, damage, death, and movement around doors and corridors.

## 4. Add loot and inventory

- [ ] Use the proposed item roster and implementation order in [LOOT.md](LOOT.md).
- [ ] Keep gold as a score and add at least three usable item types: a weapon,
      armor, and a healing potion.
- [ ] Widen the gold counter and display it in decimal before 26-floor runs
      can overflow the current one-byte hexadecimal score.
- [ ] Let the player pick up, inspect, use or equip, and drop items. Show a
      numbered inventory with a small carrying-capacity budget. Equipped gear
      counts; gold and score treasure do not. See [LOOT.md](LOOT.md).
- [ ] Make equipped gear affect combat and potions restore health. Put items on
      the floor when dropped, without changing terrain underneath.
- [ ] Add feedback for a full pack, an invalid item choice, and an item on an
      occupied cell. Test pickup, use, equip, drop, and inventory limits.

## 5. Add the Amulet quest and ending

- [ ] Increase monster and loot variety with depth, while keeping fights
      survivable and useful items available.
- [ ] Place the Amulet of Yendor on depth 26 and let the player pick it up.
      Show clearly when it is carried.
- [ ] After finding the Amulet, allow `<` on stairs to ascend. Generate fresh
      levels on the return trip, so earlier maps need not stay in memory.
      Preserve the player's health, equipment, inventory, and gold.
- [ ] Win by ascending from depth 1 with the Amulet. Show a final score using
      gold and survival; descending without the Amulet does not win.
- [ ] Test Amulet placement, ascent gating, return-trip state, and the win
      transition at the surface. Explain the objective and controls in-game.
- [ ] Balance a full run by playing it on the same terminal setup used for
      development, not only in the emulator harness.

## Later

- [ ] Add occasional dark rooms. Show only nearby cells while inside one;
      lit rooms continue to reveal their whole outline. Remember discovered
      walls and doors without leaving moving monsters visible after they leave
      sight. Keep every room lit until this work begins.
- [ ] Add a scroll of light that permanently lights the current room on that
      floor. Show when it takes effect, and test use in dark rooms, lit rooms,
      and corridors.
- [ ] Save and load a run, including the random seed, current level, explored
      cells, player state, inventory, items, and monsters. Use a versioned file
      format and handle incomplete or incompatible saves safely.
- [ ] With disk persistence available, save each floor when descending and
      reload it on ascent. Update that floor's file whenever leaving it again,
      preserving its layout, explored cells, remaining items, and surviving
      monsters. The current read-only floor files preserve layouts but not
      changes made while playing.
- [ ] Consider hunger, traps, scrolls, identified items, and more elaborate
      monster behavior after the core game is fun.
- [ ] Add conditions selectively using the source comparison and turn rules
      in [STATES.md](STATES.md).
- [ ] Consider a scrolling viewport only if a future dungeon grows beyond the
      terminal-sized floor. The initial Amulet quest uses fixed-screen floors.

Build each numbered milestone as a playable slice and keep `ROGUE.CMD` within
the FLEX application RAM limit (`$0300` through `$7DFF`). Bump the visible
version marker whenever a new disk image is prepared, so saved emulator disks
cannot silently masquerade as the current build.
