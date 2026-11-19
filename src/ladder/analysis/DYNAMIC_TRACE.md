# Original LADDER.COM execution trace

An instrumented copy of [iz-cpm](https://github.com/ivanizag/iz-cpm) ran the
original CP/M game and recorded **executed** direct transfers from Ladder's
compiled code (`$0100..$58DE`) to its linked runtime (`$617D..$9CFF`). The
instrumentation checks the CPU's PC after each `CALL` or `JP`, so conditional
transfers appear only when taken. The original COM was not modified.

## First session

On 2026-11-18, iz-cpm commit
`5f6ee4d856bea1a17b4362badc178a181feddaa7` was built with
`iz_cpm_ladder.patch`. The run used copies of `cpm/LADDER.COM` and
`cpm/LADDER.DAT` in a temporary directory. I started the game, let level one
run without movement input until game over, entered `CODEX` for the high
score, and exited through the menu. The game reached all these screens and
updated only the **temporary copy** of `LADDER.DAT`.

| Measure | Count |
| --- | ---: |
| CPU instructions | 80,844,470 |
| Game-to-runtime transfers | 1,155,421 |
| Distinct executed call sites | 367 |
| Distinct runtime targets reached | 55 |
| Previously byte-scan-only sites now proved by execution | 163 |

| Target | Executions | Executed sites | Reading |
| --- | ---: | ---: | --- |
| `$617D` | 1,078,305 | 4 | Keyboard poll via BDOS function 6 |
| `$768E` | 24,592 | 20 | [Multiply HL by inline 16-bit factor](MULTIPLY_INLINE.md) |
| `$6FEA` | 9,476 | 70 | PRINT/output setup |
| `$6E6E` | 9,437 | 46 | String output path |
| `$626B` | 9,387 | 18 | Runtime role not yet identified |
| `$747F` | 6,535 | 20 | Runtime role not yet identified |
| `$7524` | 4,820 | 4 | Runtime role not yet identified |
| `$74DB` | 3,931 | 25 | String assignment path |
| `$75B5` | 3,878 | 6 | Runtime role not yet identified |

At `$4163`, the game calls `$617D` to poll for a key, then checks a fixed
variable and loops. That one call site executed **1,074,030 times** in this
session. `$617D` invokes CP/M BDOS function 6 with `E=$FF` and uppercases
lowercase ASCII before storing the result. Thus keyboard polling dominates
the raw frequency table. The static inventory's most referenced target,
`$6FEA`, remains frequent in actual play, but its 117 static call sites are
different from its 9,476 executions in this one run.

`dynamic_sites.csv` gives counts per source and target, first/last event
numbers, static inventory status, and register values at the first execution
of each site. `dynamic_targets.csv` gives aggregate counts. The complete
event stream is in `session-2026-11-18.csv.gz` (about 4.5 MB compressed).
Its rows record sequence number, source, transfer kind, target, and AF/BC/DE/
HL/SP **before** executing the transfer. Addresses are hexadecimal without a
`$` prefix. The call to `$6FEA` has no immediate operands; the register
snapshot is useful for comparing other runtime conventions.

## Repeat or extend the run

Apply `iz_cpm_ladder.patch` to the exact iz-cpm commit above, then build with
`cargo build --release --locked`. Run Ladder from a directory containing
**copies** of its COM and DAT files. For example, from that directory:

```sh
/path/to/iz-cpm/target/release/iz-cpm --terminal adm3a \
  --disk-a . --ladder-calls calls.csv LADDER.COM
python3 /path/to/src/ladder/tools/summarize_dynamic.py \
  calls.csv /path/to/src/ladder/RUNTIME_CALLS.csv --out session
```

The recorded session used `--terminal ansi`, which left Ladder's TeleVideo
cursor sequences visible as raw escapes. A second, menu-only check with
`--terminal adm3a` translated the shared `ESC = row col` cursor sequence to
ANSI, so that is the better setting for interactive tracing. Some TeleVideo
features may still differ. A run with movement or a different level will cover additional
branches. The trace covers only direct game-to-runtime `CALL`/`JP` edges in
the specified address ranges. It does not count runtime-internal calls,
indirect transfers, or unvisited game paths.

The follow-up [one-key trace](KEY_TRACE.md) injects ASCII `6` at the first
level-one poll and identifies four call sites that were absent from this
no-input run.

The [right-up-left trace](LEFT_TRACE.md) confirms two more executed call sites, one during the climb and one during the fall.
