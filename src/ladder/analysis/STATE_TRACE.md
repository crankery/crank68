# Original Ladder update-state trace

The [iz-cpm patch](iz_cpm_ladder.patch) now accepts `--ladder-state FILE` and
`--ladder-max-updates N`. It samples the original `LADDER.COM` at PC `$4C37`,
after the indexed actor loop and bonus-counter check, before the next player
movement block. Each CSV row includes the CPU instruction count, nonzero
gameplay keys read during that update, player coordinates, raw movement and
timer words, score, bonus, lives, level, and all
eleven entries from the parallel actor X/Y/status tables. An `actors` entry is
`X:Y:STATUS` in hexadecimal. Movement words remain raw; the status readings
below describe observed motion and remain provisional for downward states.

The [runner](../tools/run_ladder_state.py) makes temporary copies of the COM
and DAT, selects a menu speed, and stops after a fixed number of samples. For
example, after applying the patch to iz-cpm commit
`5f6ee4d856bea1a17b4362badc178a181feddaa7` and building it:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-state --speed 1 --updates 125
```

Five no-movement captures are saved as `state-speed1.csv.gz` through
`state-speed5.csv.gz`; `state-idle-400.csv.gz` is a longer speed-1 run.
`state-right-80.csv.gz` and `state-right-speed2.csv.gz` through
`state-right-speed5.csv.gz` inject a single ASCII `6` at the first gameplay
poll. All runs used the original 1.10 COM and TeleVideo-configured DAT from
`cpm/`, with `P` and any necessary `L` menu keys supplied by the runner.
The original files were not changed.
For controlled scoring fixtures, the runner's `--poke-after` option writes
specified emulator memory words after a named state row; see the
[scoring probes](SCORING_PROBES.md). The CSV always records the pre-poke row.

| Menu speed | Delay word `$0F7B` | Stable instruction gap per sampled update | Bonus decrements in the first life |
| ---: | ---: | ---: | --- |
| 1 | 1000 | 31,821 | updates 25, 50, 75, 100, 125 |
| 2 | 750 | 27,821 | updates 25, 50, 75, 100, 125 |
| 3 | 500 | 23,821 | updates 25, 50; life loss resets bonus at update 71 |
| 4 | 250 | 19,821 | updates 25, 50, 75, 100, 125 |
| 5 | 0 | 15,821 | updates 25, 50, 75, 100, 125 |

The instruction gaps above are the identical values at updates 8–20 in each
capture. They are **not** wall-clock times. Actor activity, rendering, and
death cause other gaps to differ. Speed settings reduce this stable gap by
4,000 instructions per step. The delay routine at `$577F..$57A7` reads
`$0F7B`; each extra count repeats a 16-instruction loop. Poking that word
to zero after update 5 gives the same 15,821-instruction stable gap at
[speed 1](state-delay-zero-s1.csv.gz),
[speed 2](state-delay-zero-s2.csv.gz),
[speed 3](state-delay-zero-s3.csv.gz), and
[speed 4](state-delay-zero-s4.csv.gz). Poking it to one at
[speed 5](state-delay-one-s5.csv.gz) gives 15,837, confirming the 16-
instruction increment. Subtracting the zero-delay gap yields the word values
shown above. Run `python3 tools/summarize_speed_delay.py` to recount the
saved traces. Reproduce a poke with `--poke-after 5:0F7B:0000` and
`--updates 12`; compare the instruction gap between samples 7 and 8.

The Pascal rewrite's `ReadmsWait` table is 100, 50, 25, 13, and 7 ms.
Its nominal speed-1 to speed-5 interval changes by about 14 times, while
the original's measured stable instruction gap changes by about 2 times.
Neither instruction count establishes wall-clock speed, because CPU rate,
terminal output, and emulator scheduling also matter. The bonus counter has
a separate 25-update
period at every tested speed. At sample 1 it is already 24; it reaches 1 at
sample 24, decrements the bonus at sample 25, then resets to 25. The original
code initializes the period word `$0F01` to decimal 25 at `$1041..$1044`,
decrements the live counter `$0FA1` after the actor loop at `$4BF3..$4BFA`,
decrements bonus `$0F77` at `$4C06..$4C0A`, and reloads the counter at
`$4C31..$4C34`.

In the longer idle capture, the player position stays at `(6,19)` while rock
table entries change. The first actor entry is `(0,0,0)` throughout; entries
1–5 become active. This supports a separate player coordinate pair at
`$0F89/$0F8B` and rock slots in the parallel tables, but individual status
values still need decoding. Idle life losses at samples 146 and 253 reset
the bonus to 35, so the state trace also provides exact restart boundaries.

Comparing each slot with its next sample gives the first status mapping. It
describes observed motion, not every transition rule:

| Status | Dominant next position change | Working reading |
| ---: | --- | --- |
| `1` | X unchanged, Y +1 | Directed descent, often on a ladder |
| `2` | X unchanged, Y +1 | Falling |
| `3` | X -1 | Rolling left |
| `4` | X +1 | Rolling right |
| `$FFFF` | Skipped by the actor loop | Inactive slot |

The idle trace has 768 leftward changes from status 3 and 860 rightward
changes from status 4. Changes to a different direction, a fall, a blocked
step, and a reset make the less frequent deltas differ. Status 1 and 2 both
move downward; the ladder/free-fall distinction still needs a controlled
terrain check.

In each rightward capture, the `keys` column contains `36` at sample 1 and is
empty thereafter. At all five speeds, the player begins at `(6,19)` and
advances one column per sample to `(79,19)` at sample 74, where it remains
through sample 80. Lives remain at five. That confirms persistent direction
and one horizontal cell per sampled update on this open-floor path at every
menu speed. The speed choice affects delay, rather than cells per update.
The bonus still decrements at samples 25, 50, and 75.

This differs from the Pascal rewrite's `BonusTimeDecInterval = 3000` and its
millisecond-based `ReadmsWait` table: the original decrements after 25 game
updates, so faster menu settings consume bonus faster in wall time if the
emulator CPU rate is held fixed. FLEX currently has only an approximate
`tick_wait` loop and no implemented bonus countdown.

## Next use

The runner now accepts ordered position-triggered keys through `--when`;
[jump and ladder probes](PHYSICS_PROBES.md) use them. Add update-triggered
keys for cases that revisit the same coordinate, and compare raw movement
words after each input.
Capture random draws or run repeated controlled scenarios before assigning
probabilities to rock direction changes. Use score-word deltas to isolate
event awards. The 25-update bonus period is confirmed; its real-time duration
still depends on CPU pacing, speed setting, and output overhead.
