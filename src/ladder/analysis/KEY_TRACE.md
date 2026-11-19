# Feeding one key to the original Ladder

The first [execution trace](DYNAMIC_TRACE.md) recorded a run with no movement
input. To make the next comparison deterministic, I extended the iz-cpm
instrumentation with `--ladder-inject-key 6`. It supplies ASCII `6` at the
**first level-one keyboard poll** from game call site `$47ED`; all other
keyboard reads use iz-cpm's normal CP/M console handling. The injection is
one-shot and does not alter `LADDER.COM` or the original `LADDER.DAT`.

The run began with `P` at the menu, injected `6` at `$47ED` after 23,234,576
instructions, reached game over, entered `ONEKEY` for the high score, and
exited. The high score changed only a temporary copy of the DAT file.

| Measure | No movement input | One injected `6` |
| --- | ---: | ---: |
| Instructions | 80,844,470 | 76,420,900 |
| Game-to-runtime transfers | 1,155,421 | 1,151,436 |
| Distinct executed call sites | 367 | 371 |
| Distinct runtime targets | 55 | 56 |

Total counts vary with how long each unthrottled run lasts, so the significant
comparison is **which sites execute**. All 367 baseline sites occurred again.
The injected run additionally reached:

| New source | Target | Executions | First event |
| --- | --- | ---: | ---: |
| `$4828` | `$73BD` | 1 | 477,047 |
| `$4833` | `$7156` | 1 | 477,048 |
| `$4DAB` | `$768E` | 107 | 477,079 |
| `$4E07` | `$768E` | 107 | 477,080 |

The event sequence gives a concrete path from input to compiled code:

```text
477044  $47ED -> $617D   poll key
477045  $47F3 -> $75B5   HL=$0036 (ASCII '6' returned)
477046  $47F9 -> $74DB   update the input string slot
477047  $4828 -> $73BD   newly reached input branch
477048  $4833 -> $7156   newly reached input branch
```

The exact BASIC meaning of `$73BD` and `$7156` remains to be named. The
disassembly at `$47FC..$4839` checks for a nonzero key, handles two special
key values separately, and then enters the path with `$4828` and `$4833`.
The two `$768E` call sites at `$4DAB` and `$4E07` were reached in a subsequent
repeating game update path. This runtime entry [multiplies by an inline
16-bit factor](MULTIPLY_INLINE.md). This is direct evidence that a keypress opens a
branch the no-input trace missed.

`key_sites.csv` and `key_targets.csv` summarize the run. The full event log
is `key-session-2026-11-18.csv.gz`. The updated `iz_cpm_ladder.patch` contains
both the cross-boundary call logger and the optional one-key injection. Apply
it to iz-cpm commit `5f6ee4d856bea1a17b4362badc178a181feddaa7`, build
with `cargo build --release --locked`, and run a **copy** of the original game:

```sh
/path/to/iz-cpm/target/release/iz-cpm --terminal adm3a \
  --disk-a . --ladder-calls calls.csv --ladder-inject-key 6 LADDER.COM
```
