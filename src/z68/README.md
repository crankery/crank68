# Z68 for C68 FLEX

**Remaining work and deferred features: [TODO.md](TODO.md).**

Z68 is a FLEX-loadable **Version 3 Z-machine interpreter in development**.
It executes local V3 stories with interactive console input. Zork I accepts
`open mailbox` and `read leaflet`; Deadline accepts `look` and advances to its
next prompt. Input is lowercased, encoded for the story dictionary, split into
parse entries and handed back to the game's own parser. CZECH V3 completes
with 349 automatic passes, zero failures, and 19 print checks requiring visual
review. Save/restore, restart, window splitting and stream control remain stubs.

From this directory, `make` delegates to `../flex2` to assemble Z68 and package
`Z68.CMD` on drive 0. Outputs are `../flex2/build/z68.bin`, `z68.lst`,
`Z68.CMD`, and the complete `flex2.dsk` image. `make test` runs the FLEX
emulator checks, including Z68. Local files in `stories/` with `.DAT` or `.z3`
extensions are imported as raw binary files on drive 1; their FLEX names are
uppercased and their extensions become `.DAT`. Only Version 3 files are accepted.
Use names of at most eight characters, starting with a letter. Duplicate names
are rejected. Missing/empty `stories/` adds no local stories to drive 1. The build preserves
all supplied bytes, including any trailing padding beyond the declared story
length. No game downloads are performed.

At the FLEX prompt, execute the story:

```text
Z68 1.ZORK1.DAT RUN
```

Omit `RUN` to inspect its header, memory layout and sample object names:

```text
Z68 1.ZORK1.DAT
```

With no address argument, it prints the first three object short names as a
text-decoder demonstration. This does not execute story instructions. To
inspect another encoded string, append a hexadecimal story byte address:

```text
Z68 1.ZORK1.DAT BB9
```

Or use `P` followed by a hexadecimal packed address (multiplied by two):

```text
Z68 1.ZORK1.DAT P 8000
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
RUN adjusts Flags 1 to advertise no split window and fixed-pitch output;
status-line support is advertised only with the optional VT100 terminal mode. Inspection mode preserves the story bytes.

Above dynamic memory is free growth space. Fixed reservations are placed
below the runtime RAM ceiling:

| Region | Reserved bytes | State |
| --- | --- | --- |
| Sector index | 1,042 | Up to 521 track/sector pairs, built on first static read |
| Read-only story cache | 504 | Two 252-byte slots with LRU replacement |
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
| Code and fixed data | `$0300–$382A` |
| Writable story | `$382A–$667D` |
| Free growth space (2,425 bytes) | `$667D–$6FF6` |
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
or bank-latch accesses. Save/restore remains future work; unused conceptual
source placeholders have been removed.

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
file-sector index through FLEX FMS function 9, then fill one of two 252-byte
cache slots through the same service. Both slots use the existing 504-byte
reservation. A hit updates recency; misses fill invalid slots before replacing
the least recently used slot. A failed fill invalidates only its victim. Sector counts, sequence numbers, premature ends,
extra links, and index capacity are checked. Addresses are bounded by the
V3 range, the declared length when nonzero, and indexed file capacity. No
random-file sector map or direct SRAM access is required. Word reads/writes and
instruction fetching use the same bounded story-memory layer.

Emulator tests decode handcrafted strings through the actual command and file
reader: alphabets, all punctuation, null/newline/10-bit escapes, abbreviations
and cursor restoration, invalid nesting, incomplete escapes, file-sector
crossings, and strings/abbreviations above 64 KiB. The existing RAM-limit and
full writable-story byte-comparison tests remain in place.

## Story-read performance

Cache misses divide the 17-bit story offset by 252 in exactly 17 bit steps;
ordinary cache hits perform no division or disk read. Tests exhaust all 131,072
V3 byte offsets against host quotient/remainder arithmetic and exercise two-slot
hits, replacement, failed fills, address boundaries and mutable-RAM precedence.

The diagnostic runner reports modeled CPU cycles and calls to
`story_read_sector`, separating startup from the supplied first command.
Compared with the previous single-slot/repeated-subtraction reader (measurements
taken with the earlier four-volume SRAM layout):

| Command | Cycles before | Cycles after | Fewer cycles | Sector reads before → after |
| --- | ---: | ---: | ---: | ---: |
| Zork OPEN MAILBOX | 7,836,559 | 5,096,032 | 35.0% | 206 → 113 |
| Deadline LOOK | 9,811,934 | 7,076,589 | 27.9% | 215 → 141 |

These are deterministic emulator measurements using immediate scripted input,
not physical-board or UART timings. Counts cover indexed story-sector reads,
including index construction at startup; they exclude other FLEX disk calls.
Startup cycles fell from 15,943,951 to 14,224,880 for Zork and 17,434,875 to
17,247,147 for Deadline. The per-byte dynamic loader and full chain-index scan
remain candidates for reducing the initial pause; see TODO.md.
Run `make -C ../flex2 zork`, or use `build/story-runner DEADLINE --expect-prompt`
from `flex2`, to collect current counters with the normal functional checks.

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
60 execute their V3 operations, including interactive V3 `sread`.
The remaining eight handlers trap with their name, normalized class/number and
17-bit PC: `save`, `restore`, `restart`, `split_window`,
`set_window`, `output_stream`, `input_stream`, and `sound_effect`.
Reserved and V4+ slots report an invalid-opcode error. V1/V2 table entries
are retained, but the loader and text decoder currently accept V3 stories only.

The implementations live in their owning modules: `calls.s`, `branch.s`,
`math.s`, `arrays.s`, `objects.s`, `props.s`, `output.s`, `status.s`, `dict.s`, and `verify.s`.
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
30,000-instruction budget. `vm_input_requested`, `vm_input_complete`, `vm_finished` and `op_halted`
distinguish waiting for a line, completed input, normal termination and errors.
The instruction budget is refreshed after each completed input line.

## VT100 status line

Use an 80-column, 24-row VT100-compatible terminal and run:

```text
Z68 1.ZORK1.DAT RUN VT100
Z68 1.DEADLINE.DAT RUN VT100
```

VT100 mode clears the screen and reserves row 1 for an inverse-video status
bar; rows 2–24 form the scrolling story area. The room's short name appears
on the left, with score/moves on the right for score games, or a 24-hour HH:MM
clock for time games. Long room names are clipped with an ellipsis. The line
is updated by `show_status` and immediately before reading console input.
The story cursor and attributes are saved/restored around each redraw. On
normal exit or VM error, Z68 restores normal attributes and
full-screen scrolling before returning to FLEX. The terminal dimensions are
fixed; window resizing and the separate Z-machine upper window are not supported.
Plain `RUN` emits no terminal escapes and advertises no status line.

`z/status.s` formats into an 80-byte private buffer. The `putc` capture hook
reuses the existing room-name decoder and signed number printer; story operands
and the VM value are restored afterward. Tests use a small terminal model to
check cursor restoration, row-1 protection during scrolling, clipping, score/time
formatting and cleanup, plus real Zork and optional local Deadline startup.
The behavior follows the [V3 status-line rules](https://inform-fiction.org/zmachine/standards/z1point1/sect08.html#status).

## Story word wrapping

Plain and VT100 RUN modes both wrap story text to 80 columns. `z/wrap.s`
buffers one word across string, character and number print operations, deferring
inter-word spaces until the next word is known to fit. Explicit newlines and
paragraph breaks are preserved, as are spaces that fit on the line. Separating
spaces are dropped at a wrap boundary; only words longer than 80 characters
are split across lines. The wrapper owns an 80-byte word buffer.

Prompts and trailing spaces are flushed before console input; pending text is
also flushed on normal exit and before VM error diagnostics. Status capture,
terminal escapes, the fixed status row and console echo/editing bypass wrapping.
Inspection-mode output and FLEX itself keep their existing output behavior.
Tests cover exact-width lines, split print operations, long words, indentation,
paragraphs, prompt visibility, error ordering and terminal cursor behavior.
A real Deadline room paragraph is checked for line lengths and intact words.

## Console line capture

`Z68 1.ZORK1.DAT RUN` now waits for a line at the first prompt. Type a command
and press Enter: Z68 fills the text and parse buffers and resumes the story.
Use the game’s `quit` command to return to FLEX (confirm when the game asks).

`input_read_line` in `z/input.s` takes A=maximum accepted characters (0–255).
It returns a NUL-terminated lowercase ASCII string in the private 256-byte
`input_buffer`; B and `input_length` hold its length, carry is clear.
Echo preserves typed case. Backspace and DEL erase one character; other controls
are ignored. Printable characters beyond capacity ring BEL and are discarded;
backspace still makes room. CR or LF ends the line, and CRLF is handled across
successive reads. Empty lines and a zero-character capacity are supported.
`sread` takes the first resolved operand as the story text-buffer byte address.
Its length byte n permits n-1 typed characters and a NUL terminator at byte n;
characters begin at byte 1. The full n+1-byte buffer must fit in dynamic RAM,
start beyond the 64-byte header and have at least three bytes. Invalid extents
or operand counts halt before input is consumed or story RAM is changed.
Only the text and its terminator are written; the length byte, unused tail and
parse buffer remain untouched. Tests cover empty input, truncated lines, the
maximum V3 capacity (254), exact-fit allocation and rejected invalid buffers.
The layout follows the [V3 read specification](https://inform-fiction.org/zmachine/standards/z1point1/sect15.html#read).

`getc` in the hardware adapter uses the C68 FLEX raw input entry at `$BF00`.
The normal FLEX INCH entry echoes at its monitor adapter, so it cannot provide
controlled line editing. No ACIA registers are accessed by Z68. Emulator tests
check this driver entry, buffer guards, exact echo/editing, capacity boundaries,
case conversion and successive CRLF reads.

## V3 dictionary and parse buffer

`z/dict.s` validates the parse-buffer extent, text/parse separation and dictionary
metadata before console input. Spaces separate words and are discarded;
dictionary separators (usually comma, full stop and double quote) become tokens
of their own. Each token is encoded into six Z-characters, padded with 5s or
truncated to four packed bytes. Alphabet shifts and ten-bit escapes are handled.
Binary search uses the dictionary's entry stride and sorted encoded keys.

Each parse entry stores the dictionary byte address (zero for an unknown word),
the original word length and its position starting at 1 in the V3 text buffer.
The count goes in parse byte 1; parsing stops at capacity without overwriting
unused entries or the text. Empty input produces a zero-word parse table.
The local Infocom stories declare legacy capacity 120; historical 240 is also
accepted. Both are capped at 59 records (238 bytes) and their length byte is
preserved, avoiding writes into adjacent buffers. Other capacities use their
normal word-count interpretation.

Tests cover all key encodings, separators, unknown words, token lengths versus
key truncation, first/last dictionary entries, parse capacities, malformed
metadata and RAM guards. Interactive checks open the mailbox, read the leaflet,
process Deadline's LOOK, refresh VT100 status, and quit cleanly through each
story's confirmation. See the [dictionary/lexical rules](https://inform-fiction.org/zmachine/standards/z1point1/sect13.html)
and [V3 read/parse format](https://inform-fiction.org/zmachine/standards/z1point1/sect15.html#read).

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
on drive 1 along with local stories. These names are reserved for test fixtures.
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
Z68 1.CZECH.DAT RUN
Z68 1.VMBOOT.DAT RUN
```

The **six bootstrap gates** cover CZECH V3 loading, writable-byte integrity,
instruction forms/suffixes/raw decoding, print/quit execution, truncation
rejection and instruction-budget enforcement. CZECH then runs through normal
execution and must report **349 automatic passes, zero failures and 19 visual
print checks**, followed by `quit`. Visual checks are recorded separately from
automatic conformance; interpreter-specific header output may differ.

If local stories are present, acceptance executes commands and waits for the
next input prompt: Zork opens its mailbox and reads the leaflet; Deadline
processes LOOK. It checks VT100 score/moves and time displays, then exercises
each game's QUIT confirmation and verifies file/terminal cleanup. No copyrighted
story is downloaded by the build.

`../flex2/build/acceptance.json` records results. Transcripts are
`czech-load.txt`, `czech-actual.txt`, `vmboot.txt` and `zork-startup.txt` in that
build directory. `make -C ../flex2 zork` runs a diagnostic startup with the
last 24 decoded operations and opcode counts; output is `ZORK1-run.txt`.

Save/restore, restart, window splitting and stream control remain separate work.
Story text now wraps at word boundaries in an 80-column output area.

The diagnostic runner also supports another locally supplied story, for example:

```sh
cd ../flex2
make image build/story-runner
./build/story-runner DEADLINE --expect-prompt
```

It supplies a test line when the console line reader is entered, then stops
the harness when the story reaches its next input prompt. It checks the prompt,
VM flags and command bytes in the story text buffer.
Zork uses `OPEN MAILBOX`; other stories use `LOOK`. Local Deadline release 27,
serial 831005, reaches South Lawn, accepts `LOOK`, and fills its text buffer.
Both stories execute their command and remain running at the next prompt.
