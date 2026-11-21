# Original Ladder bonus expiry and restart

The original game decrements its bonus word `$0F77` when the update counter
at `$0FA1` expires. Code at `$4C06..$4C15` subtracts one and branches to
the death path at `$5216` when the result is zero. The ordinary idle traces
show decrements at updates 25, 50, and 75 at every menu speed.

To isolate expiry from rock contact, the fixture writes bonus `1` after
update 10 while Lad remains idle at `(6,19)`. The original code handles all
subsequent updates. Bonus stays at `1` through update 24. On update 25,
the next sampled state has bonus reset to Easy Street's `35`, Lads reduced
from `5` to `4`, level still `1`, and Lad back at `(6,19)`. The countdown
counter is reset to `24`. This is a life loss and restart at the same level,
visible in [the idle expiry trace](state-bonus-one-after-10.csv.gz).

A second fixture sets score to `42` at the same update boundary. The
[score preservation trace](state-bonus-one-score42.csv.gz) shows score `42`
both before and after the update-25 restart. Expiry neither awards nor
subtracts score. Bonus next falls from `35` to `34` at update 49, showing
the countdown runs again after restart.

For the last-life boundary, a third fixture writes Lads `1`, bonus `1`, and
score `42` after update 10, then stops the emulator at `$5345`. Code at
`$5332..$5348` decrements Lads and branches to the same-board restart at
`$4631` only when the result is nonzero; `$5345` begins the score-table path.
The [stop log](state-last-life-timeout.log.gz) records that this branch is
reached after 24 completed state rows with score `42`, bonus `0`, Lads `0`,
and level `1`. The [state trace](state-last-life-timeout.csv.gz) preserves
the preceding countdown. There is no update-25 gameplay row because the
game leaves the active board when the last Lad expires. This verifies the
last-life branch; the later high-score screens have not been traced here.

Reproduce the scored case with the patched emulator:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-timeout --speed 1 --updates 70 \
  --poke-after 10:0F77:0001,10:0F05:002A \
  --name bonus-one-score42
```

For the last-life branch, add `10:0F67:0001` to `--poke-after` and
`--stop-pc 5345`. The stop address is the first instruction after the
zero-Lads decision, before high-score handling begins.

The Pascal rewrite also treats bonus expiry as a death and restarts the
level, but uses a three-second interval rather than the original's 25 game
updates. FLEX has no bonus or life-loss handling yet.

## Countdown phase after a restart or new board

The live countdown word `$0FA1` is loaded from the period word `$0F01`
(decimal 25) during board setup. At `$4BF3..$4C34`, the original decrements
the live word once per completed actor loop. When it reaches zero, bonus
falls by one and the live word reloads to 25. Thus a new board's first
sample has counter 24, its 24th sample has counter 1, and its 25th sample
decrements bonus and has counter 25. The idle, rightward, and statue-route
traces in [the state analysis](STATE_TRACE.md) all show bonus decreases on
updates 25, 50, and 75 before any restart.

Two paired cases check the reset phase:

| Event | First sampled counter after event | Next bonus decrement |
| --- | ---: | --- |
| [Fire death and same-board restart](state-fire-clock-reset.csv.gz) on update 2 | 24 | Update 26, bonus 33→32 |
| [Treasure and next-board start](state-treasure-clock-reset.csv.gz) between updates 53 and 54 | 24 at update 54 | Update 78, bonus 45→44 |

The fire fixture places Lad above Ghost Town fire after update 1; the
treasure fixture puts Lad one upward step below Easy Street's gold after
update 53. Both run original movement and board setup code. The counter
returns to 24 in the first post-event sample, so neither event carries
the previous board's partial countdown into the new board. The existing
[bonus-expiry trace](state-bonus-one-score42.csv.gz) has the same pattern:
restart at update 25 with counter 24, then bonus falls at update 49.
The Pascal rewrite also resets `bonusTimeTicks` at its `restartLevel`
label, but measures its period in milliseconds rather than game updates.

Collecting a statue does **not** reset that phase. In the
[statue route](state-statue-route-jump.csv.gz), bonus falls to 31 and the
counter reloads to 25 on update 100. The statue pays 31 points on update
104; the counter has continued to 21. It reaches 20 on update 105 and
bonus falls again on update 125, exactly 25 updates after the previous
decrement. The Pascal `&` handler calls `UpdateScore` and clears the
tile without changing `bonusTimeTicks`, so it preserves its own timer
phase too. FLEX has no bonus clock yet.

## Update rate versus elapsed time

The first 60 samples of the saved idle traces have no life loss. Their
instruction gaps between consecutive state rows vary as rocks spawn and
move, but every run still decrements bonus on updates 25 and 50:

| Original run | Instruction gap range, updates 2–60 | Bonus decrement updates |
| --- | ---: | --- |
| [Easy Street speed 1](state-speed1.csv.gz) | 28,112–38,101 | 25, 50 |
| [Easy Street speed 2](state-speed2.csv.gz) | 24,080–33,728 | 25, 50 |
| [Easy Street speed 3](state-speed3.csv.gz) | 20,084–30,109 | 25, 50 |
| [Easy Street speed 4](state-speed4.csv.gz) | 16,084–26,190 | 25, 50 |
| [Easy Street speed 5](state-speed5.csv.gz) | 12,114–24,521 | 25, 50 |
| [Ghost Town speed 2](state-ghost-ladder-s2.csv.gz) | 23,099–30,850 | 25, 50 |
| [Ghost Town speed 3](state-ghost-ladder-s3.csv.gz) | 19,552–26,759 | 25, 50 |

These are executed Z80 instruction counts, not CPU cycles or real seconds.
The compiled `$4BF3..$4C34` path counts completed actor updates, so the
bonus period is fixed at 25 movement updates even when one update executes
more instructions. A wall-clock rate still needs a measured target CPU and
terminal pacing. Pascal instead uses `BonusTimeDecInterval = 3000`
milliseconds and adds its `ReadmsWait` movement interval (`100, 50, 25,
13, 7` ms across speeds) until reaching that threshold. FLEX's loop has
an approximate delay and no bonus countdown yet.

Reproduce the fire case with `--start-level 5 --speed 1 --updates 31` and
`--poke-after 1:0F89:0014,1:0F8B:0007,1:0F9F:0002,1:0F05:002A`. For
the next-board case, use `--start-level 1 --speed 1 --updates 90
--first-key 6 --when 58:19:38 --poke-after 53:0F8B:0002`. These options
are passed to `tools/run_ladder_state.py` with `--emulator`, `--output`,
and a distinct `--name` for each capture.

## Negative bonus after many level waves

The [level sweep](START_LEVEL_CHEAT.md#full-seven-board-waves-and-bonus-adjustment)
finds that the loader's 16-bit bonus subtraction wraps at high displayed
levels. The shortcut starts displayed level 109 on Easy Street with raw
bonus `65531`, which is signed `−5`. In the
[28-update trace](state-negative-bonus-level109.csv.gz), the live counter
falls from 24 to 1 on updates 1–24; on update 25 the bonus becomes
`65530` (signed `−6`), the counter reloads to 25, and Lads remain at 5.
Code at `$4C06..$4C15` decrements the bonus and calls the death path
only when the result is **exactly zero**. It does not treat a negative
signed value as expired. Pascal's `RemainingBonusTime <= 0` check would
expire a negative value on its next decrement, although Pascal's board
cycle differs long before level 109. FLEX has no bonus timer yet.

Reproduce with `--start-level 109 --speed 1 --updates 28
--name negative_bonus`, passed to `tools/run_ladder_state.py` with
`--emulator` and `--output`. The shortcut reaches this level through the
original board loader; ordinary-play reachability is not established.
