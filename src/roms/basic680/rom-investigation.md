# ROM conversion investigation

This is an audit of the current `c68basic.s`, not a working ROM port.
Addresses below refer to the original layout. Keep the original disassembly
and syntax-only reproduction as the byte-exact historical baseline.

## Layout constraints

The emulator currently maps RAM at $0000-$BFFF, ROM at $E100-$FFFF,
and I/O separately. MIKBUG2 starts at $E100 and owns the vectors at $FFF8.
Its source reserves monitor RAM at $BE00 and a stack page at $BC00;
the separate trimmed variant instead uses stack page $BF00.
Choose which monitor image is authoritative before allocating BASIC RAM.

The entire existing ROM window is only 7936 bytes. The current BASIC image
is 6868 bytes including RAM state, so fitting BASIC alongside the monitor
needs an actual size/layout check. $C000-$DFFF is a possible 8 KiB window
only if hardware decoding and emulator mapping are changed to support it;
the current emulator does not map it as ROM.

Keep frequently accessed state in low RAM initially. Put program text,
variables, arrays, strings and stack in explicitly bounded RAM. Program
storage must not follow the interpreter in ROM. Use configurable ROM base,
program RAM start, RAM limit, stack policy, terminal width and trig support.

## Confirmed instruction patches

| Site | Current behavior | ROM conversion |
| --- | --- | --- |
| $00BF/$00C7 | CHRGET/CHRGOT increments the operand of `LDAA` at $00C7; $00C8/$00C9 is the text pointer | Separate RAM text pointer and indexed fetch, preserving X and the character classification flags |
| $03D0 -> $00D7 | Stores X into $00D8/$00D9, the operand of `STX`; later writes the next line address through that operand | Separate RAM link destination and explicit indirect store, retaining X as the next line pointer |
| INIT -> $0004 | Replaces RDYJSR JMP INIT with JSR READY | Distinct immutable cold and warm entry routines; preserve the subsequent command-loop behavior |
| INIT -> $0113 | Changes x0112 JMP INIT into JMP STROUT | Remove startup indirection and call STROUT directly after explicit initialization |

These are confirmed sites, not an exhaustive proof that all code writes
have been found. Indexed stores and stack-based copies need separate review.
The 6800 has no general indirect load/store addressing mode. Replacements
must account for its single index register, stack use and condition flags.
Moving the patched instructions to RAM would allow ROM storage but would
not meet the objective of eliminating self-modifying code.

## Startup questionnaire

INIT currently performs these operations:

1. MEMORY SIZE: accepts a value or probes RAM by writing $37 and $36,
   then initializes $0088 and $0084 to the selected top address.
2. TERMINAL WIDTH: initializes $000C and the derived print-column value
   at $000D. The default path sets them to $48 and $38.
3. Reserves $32 bytes below the selected memory top for the initial
   stack setting at $0082/$0083.
4. WANT SIN-COS-TAN-ATN: Y retains the functions; A disables ATN;
   N disables all four. Disabling changes dispatch entries at $012D,
   $012F, $0131 and $0133 to the error routine at $0D4C.
5. Places the program start ($007A/$007B) immediately after $18F2,
   $18A2 or $1812 according to that choice, reclaiming unused math and
   initialization storage. Initializes an empty program and enters the loop.

Replace the questions and destructive probe with explicit configuration.
Initially retaining all math functions avoids coupling ROM conversion to
feature removal. Static dispatch entries can implement other configurations;
actually omitting math routines requires a dependency audit. Removing INIT
also requires replacing every state initialization it currently supplies.

## Relocation traps

- Dispatch and function tables contain absolute addresses represented as
  FCB/FCC bytes. Convert them to symbolic word entries before relocation.
  Recover their actual structure rather than treating every pair as a pointer.
- `START` currently equals zero. Several `LDX #START` uses clear numeric
  accumulators or pointers ($0767, $09B5 region, $0F88, $1526). Those must
  become explicit zero constants, not follow the relocated entry address.
- Initial data contains meaningful nonzero values, including the random
  seed at $010D. Identify RAM initialization templates and persistent state.
- Apparent instructions inside constants, tables and strings are not
  executable code. Their apparent writes are not evidence of code mutation.
- The $0618 console-break path still reads Altair address $F002.
- The C68 console routines currently follow INIT, in an area the historical
  startup makes available for program storage. They belong in resident ROM.

## Implementation and acceptance sequence

1. Recover symbolic code/data boundaries and pointer tables while retaining
   byte identity for both historical and current C68 builds.
2. Create a separate ROM target with explicit RAM allocation and startup
   configuration. Preserve the existing targets and the user's current edits.
3. Replace instruction patching, then relocate code and immutable tables.
4. Run with ROM writes diagnosed as failures and trace execution from RAM
   to detect remaining generated or patched instructions. Whitelist no RAM
   code for the final port.
5. Exercise cold/warm entry, numbered-line insertion/replacement/deletion,
   LIST/RUN/NEW, DATA/READ/RESTORE, loops and subroutines, strings and garbage
   collection, floating-point and trig functions, errors, break handling,
   and program/string/stack memory exhaustion.

Assembly success alone cannot establish that the ROM conversion works.
