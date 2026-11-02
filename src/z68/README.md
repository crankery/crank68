# Z68 for C68 FLEX

Z68 is a FLEX-loadable **Version 3 Z-machine interpreter in development**.
It executes the local Zork I through its title, initial room description, mailbox,
and first `>` prompt. At `sread` it reports that the first input request was
reached, closes the story and returns to FLEX. Line input, tokenization and
interactive play are not implemented yet. CZECH V3 completes with 349 automatic
passes, zero failures, and 19 print checks requiring visual review.

From this directory, `make` delegates to `../flex2` to assemble Z68 and package
`Z68.CMD` on drive 0. Outputs are `../flex2/build/z68.bin`, `z68.lst`,
`Z68.CMD`, and the complete `flex2.dsk` image. `make test` runs the FLEX
emulator checks, including Z68. Local files in `stories/` with `.DAT` or `.z3`
extensions are imported as raw binary files on drive 3; their FLEX names are
uppercased and their extensions become `.DAT`. Only Version 3 files are accepted.
Use names of at most eight characters, starting with a letter. Duplicate names
are rejected. Missing/empty `stories/` leaves drive 3 empty. The build preserves
all supplied bytes, including any trailing padding beyond the declared story
length. No game downloads are performed.

At the FLEX prompt, execute the story:

```text
Z68 3.ZORK1.DAT RUN
```

Omit `RUN` to inspect its header, memory layout and sample object names:

```text
Z68 3.ZORK1.DAT
```

With no address argument, it prints the first three object short names as a
text-decoder demonstration. This does not execute story instructions. To
inspect another encoded string, append a hexadecimal story byte address:

```text
Z68 3.ZORK1.DAT BB9
```

Or use `P` followed by a hexadecimal packed address (multiplied by two):

```text
Z68 3.ZORK1.DAT P 8000
```

Byte addresses accept up to five hex digits in `$00000–$1FFFF`; packed addresses
accept four. Hex digits and `P` are case insensitive. An arbitrary address is
not necessarily a string; invalid/inaccessible text produces a diagnostic.

File names follow FLEX's eight-character name and three-character extension
limits. The extension defaults to `.DAT`; an omitted drive uses FLEX's working
drive. Story files must contain the raw Z-machine bytes, without a binary load
record wrapper, and must be written/read with FLEX space compression disabled.
After adding a story, run `make` and refresh your emulator's working image
while the emulator is stopped. Use `make -C ../flex2 rebuild-image` if an
emulator save has overwritten the generated image. This recreates the initial
disks, so preserve any session files first. Tests exercise both local story
loads and synthetic files created through FLEX.

The loader reports version, release, serial number, declared story length,
dynamic-memory size, high-memory base, initial PC, and RAM budget. Length is
reported in hexadecimal bytes (including its seventeenth bit); zero means
unspecified in older V3 headers. The loader checks version and basic memory
ordering, but does not verify the entire story, file length, or checksum.
Header layout follows the
[Z-machine Standard, section 11](https://inform-fiction.org/zmachine/standards/z1point1/sect11.html).

Code, strings, the private 320-byte FCB, and the 64-byte header are loaded from
`$0300`. Static storage is included in the binary and checked to end below
`$7E00` during packaging. Runtime allocation is capped at the lower of FLEX's
`MEMEND` and `$7FFF`. Starting at the image end, Z68 allocates and fills exactly
`header[$0E]` bytes, mapping story address zero to that RAM base. It copies the
already-read 64-byte header, then continues sequential binary reads from offset
64 without reopening or skipping bytes. The loaded copy remains writable;
RUN adjusts Flags 1 to advertise no status line, no split window and fixed-pitch
output. Inspection mode preserves the story bytes.

Above dynamic memory is free growth space. Fixed reservations are placed
below the runtime RAM ceiling:

| Region | Reserved bytes | State |
| --- | --- | --- |
| Sector index | 1,042 | Up to 521 track/sector pairs, built on first static read |
| Read-only story cache | 504 | First 252-byte slot used; second reserved |
| Z-stack and call frames | 2,048 | Evaluation stack and routine frames |
| 6800 hardware stack | 512 | Active while Z68 runs |

All reservation bases, the dynamic exclusive end, and remaining growth bytes
are reported. The capacity check includes every reservation and rejects an
oversized dynamic region before writing any story bytes. A failed/short read
leaves `dynamic_loaded` clear, closes the file, and returns to FLEX; partially
read RAM must not be used as a loaded story. FLEX's incoming stack is restored
on return. If even code and fixed reservations cannot fit, Z68 reports an error
before switching stacks.

With the current build and Zork I release 88, the layout is:

| Region | Address range (end excluded) |
| --- | --- |
| Code and fixed data | `$0300–$2C3B` |
| Writable story | `$2C3B–$5A8E` |
| Free growth space (5,480 bytes) | `$5A8E–$6FF6` |
| Sector index reservation | `$6FF6–$7408` |
| Cache reservation | `$7408–$7600` |
| Z-stack/frame reservation | `$7600–$7E00` |
| Hardware stack | `$7E00–$8000` |

These addresses move as code grows or FLEX's memory limit changes; use the
runtime report. The code never allocates its own data above `$7FFF`. An
emulator test compares every dynamic byte against the story file, exercises
an exact-fit layout, rejects a one-byte overflow without touching dynamic RAM,
checks the 64-byte minimum, recovers from truncated files, and guards memory
above a reduced `MEMEND` and below the reserved CPU stack.

Console output and files use FLEX calls. There are no direct ACIA, SRAM-window,
or bank-latch accesses. Dictionary input, save/restore and debug modules remain
conceptual placeholders and are not linked.

## Packed text and story reads

`z/text.s` implements the V3 three-Z-character word format, lowercase/uppercase
and punctuation alphabets, temporary shifts, all three abbreviation groups,
10-bit ZSCII escapes, padding/incomplete outer constructions, and termination.
Abbreviation expansion saves the outer cursor and buffered word. Nested
abbreviations are rejected as forbidden in V3; incomplete abbreviation escapes
are also rejected. A shared 4,096-word budget prevents unbounded decoding.
Output preserves ASCII case, suppresses null, translates newline through FLEX,
and substitutes `?` for extended/undefined characters. Extended-character
transliteration is future work; this is not a claim of complete V3 compliance.
The implementation follows [section 3 of the Z-machine Standard](https://inform-fiction.org/zmachine/standards/z1point1/sect03.html).

`memory_read_byte` accepts a three-byte `mem_address`, returns A and clear
carry on success, and sets carry for bounds/file errors. X/B are clobbered;
the requested address is preserved. `memory_next` increments all three bytes.
Dynamic reads use the RAM copy. Static reads lazily build a validated linked
file-sector index through FLEX FMS function 9, then fill a 252-byte cache
through the same service. Sector counts, sequence numbers, premature ends,
extra links, and index capacity are checked. Addresses are bounded by the
V3 range, the declared length when nonzero, and indexed file capacity. No
random-file sector map or direct SRAM access is required. Word reads, writes,
and instruction-PC APIs remain to be implemented.

Emulator tests decode handcrafted strings through the actual command and file
reader: alphabets, all punctuation, null/newline/10-bit escapes, abbreviations
and cursor restoration, invalid nesting, incomplete escapes, file-sector
crossings, and strings/abbreviations above 64 KiB. The existing RAM-limit and
full writable-story byte-comparison tests remain in place.

## Variables and evaluation stack

`z/vars.s` resolves operands from left to right into `vm_resolved`, preserving
raw decoder operands. Globals map to the 240 big-endian words in dynamic story
memory. Locals use `vm_local_base` and `vm_local_count`; routine calls
establish those fields. At startup there are no locals.

`var_read` pops variable zero and `var_write` pushes it. `var_peek` and
`var_replace` access its top in place for indirect variable operations.
Each takes the variable number in A and reads/writes the word `vm_value`.
`vm_store_result` applies the decoded store destination. Success clears carry;
invalid variables, missing locals, and stack bounds failures halt with a diagnostic.
The evaluation stack grows upward within the existing 2 KiB stack/frame arena;
`vm_eval_base` protects the current frame's lower boundary. Checked increment
and decrement reuse the indirect-variable path before signed comparison.

Emulator tests cover all 240-word table endpoints, local limits, a full stack,
overflow/underflow, wrapping increment/decrement, indirect stack operands,
random result storage, and a decoded program using these operations.

## Routine calls and returns

`rtrue` and `rfalse` pass 1 and 0 to `vm_return` in `z/calls.s`.
The shared return path restores the caller's locals, evaluation-stack boundary,
17-bit PC, and frame link, discards the callee's stack, and stores the result in
the caller's destination variable. Returning with no caller ends execution.

The private frame header is 12 bytes, followed by callee locals. Its address
also records the caller's saved stack pointer; field offsets are documented in
`calls.s`. `vm_frame_pointer` is zero in the initial context and is reset for
each RUN. Frame bounds and caller links are checked before restoration.
`call` expands the packed address to 17 bits, reads V3 default locals, overrides
locals with the supplied arguments, and creates a bounded frame. Call-to-zero
stores zero without creating a frame. `ret` and `ret_popped` also use the shared
return path. Tests cover nested calls, defaults/arguments, result destinations,
malformed frames and initial-context returns. Return behavior follows
[the standard’s routine-call rules](https://inform-fiction.org/zmachine/standards/z1point1/sect06.html).

## Opcode scaffold and next implementation steps

All **68 V1–V3 opcode names** have separate labels in `z/handlers.s`.
58 execute their V3 operations; `sread` is a deliberate input boundary.
The remaining nine handlers trap with their name, normalized class/number and
17-bit PC: `save`, `restore`, `restart`, `show_status`, `split_window`,
`set_window`, `output_stream`, `input_stream`, and `sound_effect`.
Reserved and V4+ slots report an invalid-opcode error. V1/V2 table entries
are retained, but the loader and text decoder currently accept V3 stories only.

The implementations live in their owning modules: `calls.s`, `branch.s`,
`math.s`, `arrays.s`, `objects.s`, `props.s`, `output.s`, and `verify.s`.
Branching supports both suffix lengths, signed offsets and return branches;
arithmetic uses wrapping 16-bit values and signed division/remainder.
Array writes are confined to dynamic RAM. Object/property support uses the
V3 nine-byte entries, 32 attributes and descending property lists. Tree moves
bound sibling/ancestor walks and reject cycles. `verify` checks original
on-disk bytes, including the original dynamic region, rather than mutated RAM.

`handlers.s` is manual and is not regenerated. Replace a stub or jump into its
owning module when implementing the remaining operations.

`z/ops.s` documents the interface. The decoder supplies:

- `op_class`: 0OP=0, 1OP=1, 2OP=2, VAR=3.
- `op_number`: the normalized opcode number, not the raw instruction byte.
- `op_pc`: the instruction's original three-byte byte address.

`op_lookup` returns a handler in X plus `op_flags`, or carry set for an invalid
slot/version. Flag bits are store-result=1, branch=2, inline text=4, and indirect
variable operand=8. `op_dispatch` calls the handler. The execution loop honors `op_halted`/carry and closes the story before returning
to FLEX. `quit` sets `vm_finished` instead of `op_halted`. Explicit `RUN` mode
enables the small execution core; ordinary invocations still inspect text.

`tools/make-opcodes.py` is the metadata manifest and generator for
`z/opcodes.s`. It follows the
[standard opcode table](https://inform-fiction.org/zmachine/standards/z1point1/sect14.html).
Run it after metadata changes; `make` checks that the generated file is current.
It never rewrites handler bodies. Emulator tests look up every slot for versions
1, 2 and 3, exercise all 68 V3 slots, and check invalid slots, selected suffix
flags, diagnostic PCs, halt state and unchanged story memory.

The decoder preserves raw operand types and values. The execution loop resolves
variables from left to right, dispatches the operation and enforces a
30,000-instruction budget. `vm_input_requested`, `vm_finished` and `op_halted`
distinguish the input milestone, normal termination and errors.

## Random-number service

`z/random.s` is implemented and linked. Call `rnd` with a signed 16-bit range
in A:B (high:low); it returns A:B and the same word in `rnd_result`, carry
clear, preserving X:

- Positive range: a value from 1 through range (up to 32767).
- Negative range: select a repeatable seed using the exact operand bits, and
  return zero. The same seed repeats the same subsequent sequence regardless
  of the date, input timing, previous state or previous range requests.
- Zero: reseed normal mode and return zero.

`rnd_init` is called at application startup and should be called on a future
VM restart. This C68 FLEX build has a date, not a running wall clock. Normal
seeding mixes FLEX's month/day/year (`$AC0E–$AC10`), the C68 input-poll counter
(`$BFF8–$BFF9`), previous generator state and a reseed nonce. The counter advances
while FLEX polls its console; user typing timing therefore influences the seed.
It is not seconds or a time-of-day API, and identical entropy can still reproduce
sequences. No RTC, timer register or host clock is accessed.

The generator uses 32-bit xorshift state with shifts 13/17/5. Range reduction
rejects samples below `65536 mod range` before taking the remainder, avoiding
modulo bias. The state is warmed after seeding, and an accidental zero state
is repaired. Negative seeds use the same PRNG; the standard's optional
small-seed counting sequence is not used.

The `random` handler passes its resolved signed operand to `rnd` and stores the
result through the common variable-store path.
The service itself is complete and emulator-tested against a host reference,
including the most-negative seed, repeatability, forced sample rejection,
range boundaries, normal reseeding and console-counter wrap/register safety.
See the [random opcode](https://inform-fiction.org/zmachine/standards/z1point1/sect15.html#random)
and [random-state requirements](https://inform-fiction.org/zmachine/standards/z1point1/sect02.html#random).

## CZECH V3 and acceptance testing

The unchanged CZECH 0.8 distribution is vendored in `tests/czech`, including
its licence and V3 reference output. The unchanged Inform 6.44 compiler source
is vendored in `../tools/inform6` at commit
`973a81bebcbd613578b1cc6a1b23a009fe06abd8`, with its Artistic 2.0 licence retained.
The compiler and CZECH V3 story are built locally; no network access or globally
installed Inform compiler is needed. Upstream's deprecated `Switches` directive
produces one harmless compiler warning; the source is not patched.

The FLEX image installs `CZECH.DAT`, `VMBOOT.DAT`, `VMFAIL.DAT` and `VMLIMIT.DAT`
on drive 3 along with local stories. These names are reserved for test fixtures.
The three VM fixtures are ours; their results are **not** CZECH conformance
checks. They test a print/nop/newline/quit sequence, a truncated call/store
suffix, and the 30,000-instruction safety limit.

From this directory:

```sh
make acceptance  # bootstrap gates, full CZECH V3, optional local Zork startup
make test        # regression tests plus those acceptance gates
make czech       # strict 349-pass upstream automatic conformance gate
```

At the FLEX prompt:

```text
Z68 3.CZECH.DAT RUN
Z68 3.VMBOOT.DAT RUN
```

The **six bootstrap gates** cover CZECH V3 loading, writable-byte integrity,
instruction forms/suffixes/raw decoding, print/quit execution, truncation
rejection and instruction-budget enforcement. CZECH then runs through normal
execution and must report **349 automatic passes, zero failures and 19 visual
print checks**, followed by `quit`. Visual checks are recorded separately from
automatic conformance; interpreter-specific header output may differ.

If the local `stories/ZORK1.DAT` is present, acceptance also asserts the title,
West of House, its description, the mailbox, `>` and the deliberate first-read
boundary, then verifies that the story file was closed and no error was raised.
No copyrighted story is downloaded by the build.

`../flex2/build/acceptance.json` records results. Transcripts are
`czech-load.txt`, `czech-actual.txt`, `vmboot.txt` and `zork-startup.txt` in that
build directory. `make -C ../flex2 zork` runs a diagnostic startup with the
last 24 decoded operations and opcode counts; output is `ZORK1-run.txt`.

The next milestone is real V3 line input, buffer writes and dictionary
encoding/tokenization. Save/restore, screen/window and stream control remain
separate work.
