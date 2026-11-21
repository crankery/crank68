# Start menu key dispatch in LADDER.COM 1.10

The menu poll at `$4160` enters `start_key_dispatch` at `$41C3` when it gets a
character. The dispatch converts the character to a one-byte string, stores
it at `$0F64`, and compares it with both cases of each menu letter. The
descriptors in the original COM contain `E/e`, `P/p`, `C/c`, `I/i`, and `L/l`
at `$5D8B..$5D5A`.

| Call target | Name in disassembly | Role in this path |
| --- | --- | --- |
| `$75B5` | `character_string` | Make a one-character string from the key code or CR. |
| `$74DB` | `string_assign` | Store the key or input string at `$0F64`. |
| `$7399` | `string_equal` | Compare `$0F64` with a letter; return `$FFFF` for equal, zero otherwise. |
| `$6FEA` | `print_setup` | Begin a PRINT operation. |
| `$6E92` | `print_string_line` | Print a string followed by a line ending. |
| `$68BB` | `program_end` | Terminate the game after printing `Exiting...`. |
| `$6E6E` | `print_string` | Print the instructions prompt without a line ending. |
| `$8E38` | `input_string` | Read one character from the console in the instructions wait. |
| `$73B8` | `branch_if_strings_unequal` | Jump through the following word if that character is not CR. |
| `$7646` | `integer_mod_inline` | Compute the play speed modulo the following word, then add one. |

The branches are `E/e` to the exit at `$41EE`, `P/p` to game setup at `$436F`,
`C/c` to `$3A9A`, `I/i` to the instructions at `$4279`, and `L/l` to the
speed change at `$4360`. Other keys return to the menu scan at `$4142`.

The instruction wait calls `$8E38` with `DE=1` and `HL=$00FF`, then compares
the result with `CHR$(13)`. The word at `$435B` is the branch target `$433F`,
which repeats the read. The speed path calls `$7646` with inline divisor 5
at `$4366`; it increments the result and stores it at `$0F07`.

The labels are defined in `disasm/ladder_110.sym`. The two inline words are
marked in `disasm/ladder_110.blocks`, so regenerating the listing preserves
their interpretation.
