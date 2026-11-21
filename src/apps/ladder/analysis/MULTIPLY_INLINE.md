# BASLIB multiply with an inline constant

Ladder 1.30 runtime entry `$7863` is the relocated form of Ladder 1.10's
`$768E`. It implements this call convention:

```asm
        LD HL,value
        CALL $7863       ; $768E in Ladder 1.10
        DW factor        ; two operand bytes immediately after CALL
        ; execution resumes here with HL = value × factor (mod 65536)
```

The wrapper swaps the saved return address into `HL`, reads the following
little-endian word into `DE`, and advances the return address past those two
bytes. It restores the caller's `BC` and `DE` and returns the product in
`HL`. In 1.30, `$7873` calls the arithmetic core at `$9C9E`; in 1.10 the
corresponding entries are `$769E` and `$9AC9`. The core performs sixteen
shift-and-add steps, so the result is the low 16 bits of the product.

Both COM files contain 34 `CALL` byte patterns to their respective wrapper entry.
The inline factors have the **same distribution** in both builds:

| Factor | Call sites | Example use in Ladder 1.10 |
| ---: | ---: | --- |
| `$0003` (3) | 7 | callers not yet classified |
| `$0051` (81) | 25 | 81-cell row stride in level-map indexing |
| `$00A2` (162) | 1 | twice that row stride |
| `$0064` (100) | 1 | extra-lad score threshold at `$5744` |

For the climb path, `$4CD8` passes a candidate Y value in `HL` and embeds
`DW $0051`. The left-turn trace first observed `HL=$0012` there, giving
`$0012 × $0051 = $05B2` (18 × 81 = 1458). The caller then adds the X word
at `$0FB4`, doubles the sum, and adds base `$010A` to address a table of
16-bit map cells. The fall path at `$4D44` uses the same factor.

The two bytes after each call are **data**, despite appearing as Z80
instructions in a linear disassembly. Treating them as an inline operand
also explains why the wrapper rearranges the return address on the stack.
