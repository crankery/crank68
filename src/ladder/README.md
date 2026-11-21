# Ladder for C68 FLEX

This is a first playable 6800 port of Easy Street, the opening level of the
classic CP/M game Ladder. The map and initial movement rules come from the
Turbo Pascal rewrite in `Ladder/`. That rewrite is a reference, not a recovered
source listing of the original compiled BASIC game.
All seven maps are available as generated `flex/*.inc` files; only Easy Street is playable so far.

From `src`, build a fresh Ladder session and start it with:

```sh
make system
cp build/system/flex2.dsk build/ladder-session.dsk
make run THROTTLE=1 TCP_PORT=6800 SRAM_SESSION=build/ladder-session.dsk
```

`make run` normally reuses `build/session.dsk`, which may predate Ladder.
Use the separate session image above to keep saved files on that disk intact.
For a local console, omit `TCP_PORT=6800`.

At the FLEX prompt, type `LADDER`. Use an ANSI/VT100 compatible terminal with
at least 80 columns and 24 rows. On the start screen, press `P` to play,
`L` to change speed, `I` for instructions, or `E` to exit. During play,
press `h/j/k/l` or `a/s/w/d` to move, Space
to jump, any other key to stop, and `q` to return to FLEX. A direction keeps
moving until you change or stop it. The emulator's `--throttle` option sets
an approximately 1 MHz CPU rate; the game's delay loop is tuned for that rate.

This version draws Easy Street and supports walking, climbing, jumping,
falling, five moving Der Rocks, an animated death from rocks and fire, and reaching the
treasure. The start screen has the original logo and idle taunts; high scores
and configuration are still to come, along with bonus time, scoring, and the
remaining levels. After the last Lad dies, the game returns to the start screen.
`LADDER.CMD` is
included in the FLEX system disk built by `src/flex2/Makefile`.
See [TODO.md](TODO.md) for the playable milestones.

The original `LADDER.COM` remains a separate reverse engineering target.
When a matching `BASLIB.REL` or another useful binary reference is available,
compare its behavior against this port and the Pascal rewrite before changing
the rules here. Original CP/M files are now under `cpm/`; a matching
`BASLIB.REL` has not been identified.

The Pascal rewrite declares GPL version 2 or later; this port is derived from
its map and gameplay descriptions under those terms.
