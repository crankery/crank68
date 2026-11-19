# ROGUE for C68 FLEX

`ROGUE.CMD` is a small 6800 assembly proof of concept inspired by the 1982
Rogue source in `3.6-unix-source/`. It runs as a normal command on the C68 FLEX
system disk. Use an ANSI or VT100 compatible terminal with at least 80 columns
and 22 rows.

At the FLEX prompt, type `ROGUE`. Move with `h` (left), `j` (down), `k` (up),
and `l` (right). Uppercase `H`, `J`, `K`, and `L` run in those directions until
blocked or until reaching a door, stair, or gold. Walk over `*` to collect gold.
Stand on `%` and press `>` to
descend, through depth 26. Press `Q` to return to FLEX. The status line shows depth and gold in
hexadecimal.

Press `i` for the inventory view or `?` for help. Each view returns to the
same explored map when you press any key. The starter inventory contains one
inert item: pocket lint.

Each 60×20 level has nine connected rooms and corridors, with two separate
passages between each band of three rooms. Room widths, heights,
and positions vary within bounded slots, so every room is placed and no room
can overlap another or cross the screen edge. The upstairs `<` marks the spawn
point; descending places it in the same room slot as the previous downstairs.
Entering a room reveals its whole outline and floor; corridors reveal nearby
tiles. Explored areas stay visible. Gold and stair placement vary. The disk
contains 26 prebuilt floors (`RFL01.DAT` through `RFL26.DAT` on drive 1);
ROGUE loads the next floor through FLEX file I/O when you descend. A missing
or damaged floor file ends the game with an error message. Each floor has one
stationary bat (`B`) and one kobold (`K`) in separate rooms outside the starting
room. The kobold patrols its room after successful player steps and approaches
the player when they enter. Both monsters block movement, but neither can
attack or be attacked yet. Combat, item pickup and use, hunger, saving, and an
ending are not implemented yet.

The map occupies columns 1–60. A message panel in columns 62–79 shows the
four most recent events, including entering a floor and collecting gold.
Depth, gold, and controls remain below the map.

FLEX counts serial-input polling loops at `$BFF8–$BFF9`. ROGUE seeds a 16-bit
LFSR from that counter when it starts, with a nonzero fallback. The kobold's
initial patrol direction is the first random choice. The 26 packaged floor
layouts still come from a fixed generator seed so rebuilds are reproducible.

The loaded floor record stays unchanged in memory. Each level is split into
terrain, object, and actor layers: gold and stairs occupy object cells over
ordinary floor terrain, and the monsters occupy actor cells. The player is
tracked separately. Collecting gold clears
the object cell without changing the floor beneath it. This makes the drawing
and movement rules ready for more object types.

The [feature roadmap](TODO.md) tracks further room variation, monsters, loot,
inventory, an Amulet quest and ending, and later save/load support.
The [monster roster](MONSTERS.md) compares the original 26 monsters with a
proposed 12-monster set for this version.
The [loot roster](LOOT.md) does the same for the original item classes and a
smaller first set.
The [conditions list](STATES.md) records hunger, temporary effects, and
possible later additions such as ongoing poison.

Build and test from `src`:

```sh
make -C flex2 rogue-test
```

This builds `flex2/build/ROGUE.CMD` and includes it, plus the 26 floor files,
in `flex2/build/flex2.dsk`. The test boots FLEX in the 6800 emulator and checks
movement, gold pickup, reveal, descent, and exit. It loads every floor through
FLEX, checks room bounds and connected paths, and checks missing and damaged files.

The floor files preserve the built layouts. Collected objects and explored cells
still live only in RAM; saving a run or returning to an earlier floor remains
future work. The [floor format](FLOOR_FORMAT.md) records the file layout.
