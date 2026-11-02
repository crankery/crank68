# Startup milestones: V3 through the first input request

Goal: execute the local Zork I V3 story normally, print its opening output,
and stop deliberately at the first `read` instruction, returning to FLEX.
First output, the title/banner, and the initial room description are separate
checkpoints. Printing a string extracted from the story is a useful earlier
test, but does not count as executing the story.

**Reached:** local Zork I release 88 prints its banner, West of House, the
opening description, mailbox and first `>` through normal story execution.
`sread` sets `vm_input_requested`, emits an explicit milestone diagnostic and
returns to FLEX. No command is consumed. `make -C ../flex2 acceptance` checks
this startup when the local story exists and runs the full CZECH V3 suite:
349 automatic passes, zero failures, plus 19 visual print checks.
The sections below retain the original implementation plan and acceptance
criteria; input/tokenization and interactive play are the next milestone.

Implement V3 first. V1/V2 can follow with their different text and opcode
semantics; no V4+ instructions, screen model, or addressing are in scope.
The initial opcode set below was a development order, not a claim that every
opcode needed by this particular story's startup is already known.

## Evidence from the current story

`stories/ZORK1.DAT`: V3, release 88, serial 840726. The header declares
84,876 story bytes; the supplied host file contains 92,160 bytes including
trailing padding. Dynamic memory is 11,859 bytes ($2E53). Initial PC is $4F05.

The first instruction is `call` with packed routine address $2A39 and two
arguments ($8010, $FFFF), storing its return value into variable 0 (the Z-stack).
That routine is at byte address $5472, declares three locals with zero defaults,
and begins with another call. The caller then uses `storew`. A printing-only
opcode implementation cannot execute even this initialization sequence.

The loader now reserves Z-stack/call frames, file index, cache and the hardware
stack before checking whether dynamic memory fits. The runtime layout report
is authoritative; capacity shrinks as interpreter code grows.

## 1. Story memory and file access

Progress: dynamic RAM layout and full writable-region loading are implemented
and emulator-tested, including all fixed reservations, exact-fit/overflow checks
and truncated reads. A lazy sector index, static-memory cache, and 17-bit byte reader are also
implemented. Word/write/instruction-PC APIs remain to implement. See README for current layout.

Files: `z/memory.s`, `z/zio.s`, `app/init.s`.

- Allocate dynamic story bytes in conventional RAM; load them from offset zero
  and serve all later reads/writes of that region from this RAM copy.
- Keep the story open. Read static/code/string bytes through a read-only cache.
  Never allocate application state in FLEX's SRAM disk pages or reserved memory.
- Use three-byte containers for byte PCs and packed-address expansion (V3 can
  address 128 KiB). Use 16-bit arithmetic for Z-machine values. Packed routine
  and string addresses multiply by two without truncating the seventeenth bit.
- Treat FLEX sector payloads as 252 bytes, excluding links and record numbers.
  The imported story is a sequential file with no random-file sector map;
  FMS function 21 cannot simply be assumed to seek it. Scan its linked sectors
  to create a validated track/sector index, then use FLEX sector-read services
  to fill a cache. Keep file ownership, drive selection, and error handling in
  `zio.s`. No direct SRAM-latch operations in the interpreter.
- Keep the declared story length separate from padded file capacity. Zero
  length in an early V3 header requires a documented fallback rather than
  treating it as an empty file.
- Proposed interface: read byte/word, write byte/word, fetch next PC byte/word,
  expand packed address. Define register preservation/error returns before use.
- Recalculate memory needs at startup: code/data + dynamic bytes + index/cache
  + Z-stack/call storage + 6800 stack, all below min(FLEX MEMEND, $7FFF).
  Fail cleanly if they do not fit. The Z-stack is separate from the 6800 stack.

Acceptance: read bytes around offset 251/252, word and sector boundaries,
$FFFF/$10000, and the declared end; reject writes outside dynamic memory;
verify modified dynamic bytes remain visible; reject malformed disk chains
and I/O failures without corrupting FLEX. Verify upper RAM and stack guards.

## 2. Text decoder and console output

Progress: the V3 decoder and command-line text inspector are implemented and
emulator-tested, including abbreviations and 17-bit file reads. Extended ZSCII
currently uses `?` placeholders. This remains separate from story execution.

Files: `z/text.s`, `hardware/hw_io.s`.

Implement V3 packed Z-characters, alphabet shifts, spaces, punctuation,
10-bit ZSCII escapes, abbreviation expansion, and string termination.
Abbreviation expansion must preserve the outer string cursor and return
position. Bound nesting/storage to catch malformed input. Inline strings must
leave the instruction PC immediately after the string; external strings must
preserve the calling PC. Convert ZSCII newlines to the console's line ending.

Acceptance: synthetic strings cover all encoding paths, abbreviated strings,
and sector crossings. A debug harness may print a known story string through
the same memory reader. This tests text before depending on a VM dispatcher.

## 3. Decoder and execution state

Files: `z/decode.s`, `z/vars.s`, `z/branch.s`, `z/calls.s`, `z/debug.s`.

- Decode V3 long, short, and variable forms; preserve operand types as well as
  values. Fetch store/branch suffixes only where the opcode defines them.
- Implement globals, locals, and the evaluation stack, including variable-zero
  push/pop and the different indirect-variable peek/replace behavior.
- Implement routine headers/default locals, argument overrides, nested call
  frames, result destinations, return-PC restoration, and call-to-zero.
- Implement both branch lengths, signed offsets, and special return branches.
- Trap unsupported instructions with PC, opcode form/number, and operands.
  Do not silently skip them. Add a bounded trace and an instruction budget.

Acceptance: tiny synthetic story programs test each feature independently,
including signed arithmetic boundaries, nested calls and returns, stack bounds,
branch-return behavior, and a PC crossing $FFFF. Tests run on the actual 6800
emulator, not solely on a host-language implementation of the Z-machine.

## 4. Small executable stories, then Zork's first output

Files: `z/ops.s` and the modules above.

Implement opcode groups in testable batches:

1. `print`, `print_ret`, `print_addr`, `print_paddr`, `new_line`, `print_char`,
   `print_num`, `quit`, `nop`: synthetic stories can print and exit.
2. V3 `call`, `ret`, `rtrue`, `rfalse`, `ret_popped`; `load`, `store`, `push`,
   `pull`; `loadb`, `loadw`, `storeb`, `storew`.
3. `jz`, `je`, `jl`, `jg`, `jump`, `test`; `inc`, `dec`, `inc_chk`, `dec_chk`;
   `add`, `sub`, `mul`, `div`, `mod`, `and`, `or`, `not`.

Run Zork after each batch, inspect the first unsupported instruction, and add
what its actual startup path needs. Keep this path's opcode inventory in the
tests once observed. First emitted story text is the first execution milestone.

## 5. Banner, room description, first read

Files: `z/objects.s`, `z/props.s`, `z/random.s`, `z/ops.s`, `z/input.s`.

Implement encountered object-tree/attribute/property operations and object-name
printing; do not assume startup avoids world-state initialization. Add tested
random behavior and other V3 operations as the trace demands. Initialize header
capability flags honestly for a simple serial terminal: no status line or
split-window support initially. Handle screen operations according to their
V3 semantics rather than introducing V4+ screen machinery.

Stop at `read` with a clear diagnostic and close the story/return to FLEX.
This allows opening prose and the room description to be tested before adding
line input and dictionary tokenization. Save/restore, command parsing, and full
interactive play are later milestones. If startup invokes a deferred opcode,
report it explicitly and implement the defined behavior before continuing.

## References

- [Memory and address types](https://inform-fiction.org/zmachine/standards/z1point1/sect01.html)
- [Text encoding](https://inform-fiction.org/zmachine/standards/z1point1/sect03.html)
- [Instruction encoding](https://inform-fiction.org/zmachine/standards/z1point1/sect04.html)
- [Variables, stacks, calls](https://inform-fiction.org/zmachine/standards/z1point1/sect06.html)
- [Screen/status capabilities](https://inform-fiction.org/zmachine/standards/z1point1/sect08.html)
- [Opcode table](https://inform-fiction.org/zmachine/standards/z1point1/sect14.html)
- [Opcode semantics](https://inform-fiction.org/zmachine/standards/z1point1/sect15.html)
