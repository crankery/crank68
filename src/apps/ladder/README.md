# Ladder for C68 FLEX

This is a playable 6800 port of all seven distinct levels of the classic CP/M
game Ladder. The map and initial movement rules come from the
Turbo Pascal rewrite in `Ladder/`. That rewrite is a reference, not a recovered
source listing of the original compiled BASIC game.
All seven maps are available as generated `flex/*.inc` files. Collecting a
treasure starts the next board with your remaining lives. The seventh board
displays the completion message.

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
at least 80 columns and 24 rows. On the start screen, press `P` to start at
Easy Street and qualify for high scores, or press `1` through `7` to practice
on that board without high score eligibility. Press
`L` to change speed, `I` for instructions, or `Q` to quit to FLEX. During play,
press `h/j/k/l` or `a/s/w/d` to move, Space
to jump, any other key to stop, and `q` to return to the start screen. A direction keeps
moving until you change or stop it. The emulator's `--throttle` option sets
an approximately 1 MHz CPU rate; the game's delay loop is tuned for that rate.
Speed 1 is the slowest setting, and all five settings now wait about twice as
long between game updates as before.

This version draws all seven boards and supports walking, climbing, jumping,
falling, moving Der Rocks, an animated death from rocks and fire, and reaching the
treasure. The line below the board shows its name, score, Lad count, and bonus
time. Bonus time falls every 25 game updates at every play speed; reaching zero
costs one Lad and restarts the board. Each `&` statue awards the remaining
bonus once and then disappears; treasure awards the remaining bonus again.
The treasure payout briefly flashes `Hooka!`, as in the original game.
Rock-jump points and extra-Lad awards are not implemented.
The start screen has the original logo, idle taunts, and five high scores.
When the last Lad dies after a `P` start, a qualifying score prompts for a name of up to ten
characters, then saves the score and FLEX date to `LADDER.HIS` on the same
drive from which FLEX loaded `LADDER.CMD`. The file is created on the first
qualifying game. Scores are loaded when Ladder starts, so keep using the same
session disk to retain them. Returning to the menu during a run does not
submit its score. Configuration is still to come. After
the last Lad dies, the game returns to the start screen.
`LADDER.CMD` is
included in the FLEX system disk built by `src/os/flex2/Makefile`.
See [TODO.md](TODO.md) for the playable milestones.

The original `LADDER.COM` remains a separate reverse engineering target.
When a matching `BASLIB.REL` or another useful binary reference is available,
compare its behavior against this port and the Pascal rewrite before changing
the rules here. Original CP/M files are now under `cpm/`; a matching
`BASLIB.REL` has not been identified.

The bundled Pascal rewrite includes the GNU GPL version 3 in
[`Ladder/LICENSE`](Ladder/LICENSE). This combined C68 port uses its maps and
gameplay descriptions and is distributed under those GPL terms. Crankery's
original C68 additions are also offered under the [MIT License](LICENSE-MIT);
that grant does not relicense the Pascal rewrite or the original Yahoo Software
game.
