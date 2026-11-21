# Original Ladder trampoline probes

The original Long Island board has a trampoline (tile code `9`) at `(54,7)`.
The code at `$50B6..$50F6` checks for tile `9`, draws a random outcome, and
dispatches through the three-entry table after the call at `$50DD`. Its
entries lead to `$5105` (no change), `$50E7` (replace horizontal direction
through the reversal table at `$0E5E`), and `$50F9` (set the jump counter at
`$0F97` to `6`). The reversal table initialized at `$1098..$10C5` maps
`0→0`, `1↔2`, and `3↔4`; `0` is stopped and `3/4` are left/right in the
captures. The jump branch leaves horizontal direction alone.

To reproduce the moving fixture, start displayed level 4, then place Lad at
`(53,7)` moving right (`$0F9D=$0F9F=4`) after update 1. The next movement
enters the trampoline at `(54,7)`. The original random state varies with
menu speed; these speed settings give one example of each outcome:

```sh
python3 tools/run_ladder_state.py \
  --emulator /path/to/iz-cpm/target/release/iz-cpm \
  --output /tmp/ladder-trampoline --start-level 4 --updates 6 \
  --poke-after 1:0F89:0035,1:0F8B:0007,1:0F9D:0004,1:0F9F:0004 \
  --tile-events --speed 5 --name moving-l4-s5
```

Repeat with `--speed 1` for choice 1 and `--speed 2` for choice 2. The saved
[choice-0 state](state-trampoline-straight.csv.gz),
[choice-1 state](state-trampoline-reverse.csv.gz), and
[choice-2 state](state-trampoline-jump.csv.gz) traces have matching
[choice logs](tile-events-trampoline.csv.gz). Each event is logged at `$50D6`
before dispatch; the state rows show the result at the end of update 2.

| Choice | State at update 2 | Next movement | Confirmed effect |
| --- | --- | --- | --- |
| 0 | `(54,7)`, direction 4, jump 0 | `(55,7)` | Keep moving right. |
| 1 | `(54,7)`, direction 3, jump 0 | `(53,7)` | Reverse right to left. |
| 2 | `(54,7)`, direction 4, jump 6 | `(55,6)` | Start jump; keep moving right. |

The [stopped-player trace](state-trampoline-stopped.csv.gz) places Lad just
above the same tile, falling onto it. Choice 1 keeps direction 0 because the
reversal table maps stopped to stopped. Choice 2 starts the same six-step
jump with no horizontal movement. The tile is checked again on each later
landing or stationary update, so the stopped player can get another random
outcome while still on it. The capture shows repeated 0/1 results before a
2 eventually bounces Lad. A trampoline does not guarantee an immediate
bounce.

The RNG trace for each moving fixture and four controlled seed-boundary
fixtures is saved in [trampoline-rng-captures.tar.gz](trampoline-rng-captures.tar.gz).
The choice is `floor(3*v / 2^24)`, where `v` is the low 24 bits of the
updated [original RNG state](ROCK_PROBES.md#observed-random-choice-frequencies).
The boundary probes produce 0/1 at `v=$555555/$555556` and 1/2 at
`v=$AAAAAA/$AAAAAB`. Run `python3 tools/verify_trampoline_rng.py` to
verify the saved state transitions and choices. Across a complete low-24-bit
cycle, choice 0 has 5,592,406 raw states and choices 1 and 2 each have
5,592,405. A particular game run samples those states according to its
earlier events, so its observed outcome counts need not be balanced.

The Turbo Pascal rewrite's `'.'` case uses five outcomes: force left, force
right, jump in place, jump left, or jump right. Those differ from the three
original outcomes and from its rule that a direction choice can move a
stopped Lad. The current FLEX port has no trampoline handler; its
[roadmap](../TODO.md) lists this as unfinished. The original effects and
choice ranges are confirmed by code paths, state traces, and controlled
RNG boundary probes.
