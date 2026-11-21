# Ladder's calls into its linked runtime

This inventories direct 8080 `CALL` and `JP` operands in the original
`cpm/LADDER.COM` that point from game code into the linked BASIC runtime.
Addresses are CP/M memory addresses: the COM loads at `$0100`.
The exact input analyzed has SHA-256
`583399fa98acbe725d15a91f5a3028b195fbe0b28b09d93e26199a90d72d0e67`.

## Boundaries and method

The CP/M entry is `$0100`; startup at `$0FFA` passes `$100E` as the compiled
main-code address to runtime entry `$66B0`. The last apparent compiled routine
ends in `RET` at `$58DE`. At `$58DF`, a record containing a string pointer
begins; its text is `Type RETURN to continue:`. Game data continues through
`(c)1982 Yahoo Software` at `$617C`. Runtime code starts at `$617D` with a
CP/M BDOS call. These observations give a game-code scan range of
`$0100..$58DE` and runtime range of `$617D..$9CFF`.

`runtime_calls.py` produces two kinds of evidence:

- `reachable`: a conservative instruction trace from `$0100` and `$100E`
  reaches the transfer instruction. It follows direct branches and calls in
  the game region and treats a runtime call as returning to the next byte.
- `byte_scan`: the three bytes have a direct `CALL` or `JP` opcode and a
  runtime address, but the trace did not reach them. Many occur in repeated
  compiled-code patterns; a few may be data or misaligned instruction bytes.

The trace cannot follow runtime callbacks into compiled routines, computed
branches, or tables of code addresses. The CSV therefore inventories **direct
transfer candidates**, not a proof of every actual call. It also does not
count transfers made within the runtime, or indirect calls through a register
or stack. The original binary has no complete debug symbols.

## Results

| Measure | Count |
| --- | ---: |
| Traced game instructions | 1,358 |
| Trace-confirmed direct transfers | 320 (319 `CALL`, 1 `JP`) |
| All direct transfer candidates in code range | 584 (567 `CALL`, 17 `JP`) |
| Distinct runtime targets among candidates | 78 |

Most frequently referenced target addresses:

| Target | Candidates | Trace-confirmed |
| --- | ---: | ---: |
| `$6FEA` | 117 | 71 |
| `$6E92` | 73 | 50 |
| `$6E6E` | 56 | 32 |
| `$768E` | 34 | 3 |
| `$74DB` | 33 | 23 |
| `$626B` | 27 | 10 |
| `$747F` | 25 | 18 |
| `$744D` | 11 | 11 |
| `$7CFF` | 11 | 0 |
| `$75B5` | 10 | 6 |
| `$8B2D` | 10 | 10 |

The high-frequency `$6E**` and `$74**` entries are good first targets for
understanding the compiler's expression and statement machinery. Their
functions have not yet been established, so this inventory leaves them
unnamed. The 11 jumps to `$7CFF` are byte-scan candidates only; inspect those
call sites before treating them as a confirmed dispatch pattern.

## Provisional disk-module labels

The 5.3 `OBSLIB.REL` `Disk` module has eleven independent exact-code anchors
that all place its base at `$8574` in this 5.2 Ladder image. They suggest
these labels for targets in the inventory:

| Target | OBSLIB name | Candidates | Trace-confirmed |
| --- | --- | ---: | ---: |
| `$8574` | `$EOF` | 2 | 2 |
| `$85F4` | `$DKC` | 6 | 4 |
| `$8993` | `$RS2` | 1 | 1 |
| `$89AF` | `$DKK` | 2 | 2 |
| `$8AB4` | `$DKN` | 4 | 2 |
| `$8ADC` | `$DKM` | 4 | 2 |
| `$8B11` | `$RPT` | 1 | 0 |
| `$8B2D` | `$RGT` | 10 | 10 |

These are candidate names, since Ladder identifies its linked BASLIB as 5.2
and the available OBSLIB is 5.3. The exact run matching is explained in
`REL_RESEARCH.md` and reproduced by `rel_anchors.py`.

## Complete inventory and reproduction

`RUNTIME_CALLS.csv` has one row per candidate, with source address, raw
opcode, transfer kind, target address, trace status, and any provisional
OBSLIB disk label. Generate it again from `src/apps/ladder` with:

```sh
python3 tools/runtime_calls.py --csv RUNTIME_CALLS.csv
```

The most useful next step is to disassemble the repeated code blocks around
`$3C00..$5800`, identify how runtime startup enters compiled routines, and
then follow the frequent targets from their call sites. That can turn many
`byte_scan` rows into confirmed transfers and clarify which runtime operations
carry Ladder's game logic.

## Case study: the most referenced target, `$6FEA`

The inventory counts **static references**, not executions. `$6FEA` has 117
candidate call sites, 71 reached by the conservative trace. The routine at
`$6FEA..$6FFF` is only 22 bytes. It preserves `HL`, sets the working pointer
at `$6836` to `$6839`, clears the word at `$680E` and the byte at `$6831`,
calls `$7000`, restores `HL`, and returns. `$7000` moves the old byte at
`$6834` to `$6835` while clearing `$6834`.

Its callers reveal the purpose. In 111 of 117 cases, the next instruction is
`LD HL,nn`; 71 of those immediately call `$6E92`, and 38 call `$6E6E`.
Both entries read a string descriptor and feed characters to `$900E`, the
runtime character-output routine. `$6E92` reaches `$90B6`, which emits CR/LF
when the relevant output-mode flag is clear; `$6E6E` reaches `$6FA7`, which
returns without a separator in that mode. `$900E` can reach `$6739`, a CP/M
BDOS console-output call. For example, `$3A7F` begins this sequence:

```asm
CALL $6FEA       ; reset output/print state
LD   HL,$613E    ; string descriptor
CALL $6E92       ; output the string, then the line ending
```

This identifies `$6FEA` with high confidence as a **PRINT/output setup
helper**. The precise meanings of all `$68xx` state bytes still need tracing,
and some output can be redirected by the runtime. The result is useful for
reverse engineering: the many calls to `$6FEA` do not imply 117 different
pieces of game logic. They mark compiler-generated output sequences, while
the branches, variable updates, and data chosen before them are where Ladder's
behavior is expressed.
