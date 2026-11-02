# Z68 for C68 FLEX

Z68 is currently a FLEX-loadable **Version 3 story memory loader**.
It opens the supplied file through FLEX, reads its binary header, calculates
a conventional-RAM layout, and loads the complete writable story region.
It reports the header and RAM layout, demonstrates packed-text decoding,
closes the file, and returns to FLEX.
Explicit `RUN` mode currently executes only `nop`, inline `print`, `new_line`,
and `quit`; all other operations still stop with a diagnostic.

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

At the FLEX prompt:

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
interpreter capability adjustments will be added with execution support.

Above dynamic memory is free growth space. Fixed reservations are placed
below the runtime RAM ceiling:

| Region | Reserved bytes | State |
| --- | --- | --- |
| Sector index | 1,042 | Up to 521 track/sector pairs, built on first static read |
| Read-only story cache | 504 | First 252-byte slot used; second reserved |
| Z-stack and call frames | 2,048 | Reserved; execution not implemented |
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
| Code and fixed data | `$0300–$1D95` |
| Writable story | `$1D95–$4BE8` |
| Free growth space (9,230 bytes) | `$4BE8–$6FF6` |
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
or bank-latch accesses. The other `z/` modules remain conceptual placeholders
and are not linked; opcode execution and save/restore remain future work.

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

## Opcode scaffold and next implementation steps

All **68 V1–V3 opcode names** now have separate handler labels in
`z/handlers.s`. Most are deliberately unimplemented: their handlers report the name,
normalized opcode class/number, and 17-bit instruction address, set `op_halted`,
and return carry set. Four handlers now implement `nop`, inline `print`,
`new_line`, and `quit`. Reserved and V4+ opcode slots report an
invalid-opcode error. The metadata includes V3's special `sound_effect` case
for The Lurking Horror. Header loading and text decoding still support V3 only;
adding V1/V2 metadata does not claim those story formats run yet.

Start editing **`z/handlers.s`** when implementing operations. It is a manual
source file and is not regenerated. Unimplemented bodies are short jumps to the
common diagnostic; replace one body at a time, or jump into its owning module
(objects, calls, variables, etc.). Inline `print` is connected to the text decoder; the other print operations
remain stubs.

`z/ops.s` documents the interface. The future decoder supplies:

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

Operand forms and suffixes are now decoded, preserving raw operand values and
types. Variable resolution, the Z-stack, branch/store handling and routine
calls/returns remain the next work. Tiny synthetic programs should establish
those pieces before running Zork's initializer.

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

The opcode `op_random` remains a deliberate trap until operand decoding and
result-variable storage exist. Its eventual body should pass its resolved
operand to `rnd`, then store `rnd_result` using the common variable-store path.
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
suffix, and the 10,000-instruction safety limit.

From this directory:

```sh
make acceptance  # passing bring-up gates, with explicit CZECH blocked status
make test        # regression tests plus those acceptance gates
make czech       # strict upstream conformance gate; currently FAILS as blocked
```

At the FLEX prompt:

```text
Z68 3.CZECH.DAT RUN
Z68 3.VMBOOT.DAT RUN
```

The current **six bootstrap gates** cover CZECH V3 loading, writable-byte
integrity, instruction forms/suffixes/raw operand decoding, print/quit execution,
truncation rejection, and instruction-budget enforcement. The real CZECH entry
instruction is decoded and then traps at unimplemented `call` (VAR:00), PC
`$000823` in this compiler build. **Zero upstream CZECH checks have passed.**
CZECH needs calls, variables and stack behavior before its tests can run.

`../flex2/build/acceptance.json` records this distinction. Transcripts are
`czech-load.txt`, `czech-actual.txt` and `vmboot.txt` in the same build directory.
The upstream full V3 baseline is **349 automatic passes, zero failures and
19 visual print checks** (368 total); interpreter-specific header output may
differ. The strict target will not treat a successful file load or a known
unsupported opcode as a passing suite. As execution support advances, extend
the acceptance runner and replace the current expected-blocker assertion.

`z/decode.s` handles long, short and variable forms, raw operands/types, store
bytes and one-/two-byte branch suffixes through the 17-bit story reader. It does
not resolve variables, apply branches or store results yet. `z/execute.s` has
the bounded loop and four implemented operations. A future implementation must
not execute other operand-taking handlers until their variable-resolution and
result-store paths are available.
