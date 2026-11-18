# HUD variables and actor tables in the original LADDER.COM

This is a targeted reading of the original compiled game's Z80 code, checked
against the saved right/up/left call trace and terminal output. It does not
require emulating game rules outside `LADDER.COM`.

## HUD words

The HUD strings are length-and-pointer descriptors in the COM's data area.
Code at `$46A9..$4706` prints each label, then calls runtime entry `$61A8`
with `HL` pointing at a word to format. The left-turn trace executed each
initial HUD number call five times, matching five board draws. The addresses
are:

| Screen field | Word | Print call | Direct update seen in compiled code |
| --- | --- | --- | --- |
| `Lads` | `$0F67` | `$46B8 → $61A8` | `$5332..$5336` decrements on life loss; `$574C..$5750` increments for an extra lad |
| `Level` | `$0F69` | `$46C7 → $61A8` | `$4375..$4378` sets 1; `$520C..$5210` increments |
| `Score` | `$0F05` | `$46D6 → $61A8` | Multiple scoring paths write it |
| `Bonus time` | `$0F77` | `$46FD → $61A8` | `$4C06..$4C0A` decrements; `$4408..$4415` subtracts a larger amount |

The initial bonus display prints the word at `$0F77` followed by a literal
`00`. Thus `35` appears as `3500`. A separate update routine at `$5769..$577E`
prints the changed bonus; its `$577B → $61A8` call executed 33 times in the
left-turn trace. The life counter changes from five to four in
[left-lads4.txt](left-lads4.txt), and the compiled decrement at `$5336` is
the direct write to its HUD word.

`$0F69` is the **displayed** level number. A [one-byte experiment](LEVEL_DISPLAY_PATCH.md) changed its initial value to 2: the HUD showed Level 2 while the game still drew Easy Street. Map selection uses different state.

## Moving actors

The actor update loop at `$48B0..$48E0` uses the word at `$0FB2` as an index.
It doubles the index and reads from three parallel word tables:

| Base | Observed use |
| --- | --- |
| `$0E68 + 2 × index` | X position, copied into working word `$0FB4` |
| `$0E7E + 2 × index` | Y position, copied into working word `$0FB6` |
| `$0E94 + 2 × index` | actor status/type; `$FFFF` causes the loop to skip it |

The bases are `$16` bytes apart, consistent with eleven word slots per
table. Code at `$4B36..$4B55` writes the working X and Y values back to the
indexed tables. Code at `$47A0..$47D7` copies coordinates from two more
parallel tables at `$0EAA` and `$0EC0` into a selected actor slot and sets
its `$0E94` entry to `2`; this looks like actor spawning from stored
positions. The evidence so far does not assign every slot to a specific
rock, dispenser, or the lad.

The climb/fall trace gives an independent check on the working Y word:
`$4CD8` decrements `$0FB6` during ascent, while `$4D44` increments it during
the fall. Their first observed `HL` values were `$12,$11,$10,$0F` and
`$10,$11,$12,$13` respectively. These paths line up with the lad's changing
rows in the saved text frames.

These are addresses in the **running CP/M memory image**. The original COM
contains executable bytes at some of the low addresses before startup, so
the program or linked runtime reuses that region as variable storage during
play. A later memory snapshot at the actor loop would establish exact slot
roles without building a separate game engine.
