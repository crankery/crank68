# Climbing the first ladder

This run used a temporary copy of the original CP/M `LADDER.COM` and
`LADDER.DAT`. The iz-cpm instrumentation sent ASCII `6` at the first
level-one keyboard poll. When the terminal output drew the lad `p` at row 19,
column 58, it sent ASCII `8` at the next level-one poll. Both were one-shot
injections at game call site `$47ED`; the second uses the output position as
its trigger, so it does not depend on host timing.

| Capture | Lad position |
| --- | ---: |
| [At the base](climb-base.txt) | row 19, column 58 |
| [First step](climb-step.txt) | row 18, column 58 |
| [Higher](climb-higher.txt) | row 16, column 58 |
| [At the top](climb-top.txt) | row 15, column 58 |

The lad remains at row 15 while the `o` hazards continue moving. The ladder
ends there, so a later run can turn left or right onto the platform. The
one-key rightward run is documented in [SCREEN_CAPTURE.md](SCREEN_CAPTURE.md).

The full ADM-3A-to-ANSI display stream is `climb-run.ansi.gz`, and the two
injections and their instruction counts are in `climb-injections.log`. The
saved `.txt` files store reconstructed 80-by-24 character cells. `iz_cpm_ladder.patch` includes the call logger, one-key injection, and
position-triggered climb and left-turn support for iz-cpm commit
`5f6ee4d856bea1a17b4362badc178a181feddaa7`.

After applying the patch and building iz-cpm, run a copy of the game:

```sh
iz-cpm --terminal adm3a --disk-a . --ladder-inject-key 6 \
  --ladder-inject-up-at-58 LADDER.COM >terminal.out 2>inject.log
```

Press `P` at the menu. To regenerate these frames from the saved stream:

```sh
python3 ../../tools/replay_ladder.py climb-run.ansi.gz /tmp/ladder-climb \
  --every 20 --select move-640,move-660,move-680,move-700
```

Frame labels count terminal cursor commands. They are not CPU instruction or
game tick numbers.

The [left-turn trace](LEFT_TRACE.md) follows the lad through the gap and compares executed call sites.
