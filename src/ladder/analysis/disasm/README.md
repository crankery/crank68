# LADDER.COM 1.10 labeled disassembly

`ladder_110.asm` is a complete first-pass disassembly of `cpm/LADDER.COM` made with `z80dasm 1.2.0`. The input SHA-256 is `583399fa98acbe725d15a91f5a3028b195fbe0b28b09d93e26199a90d72d0e67`. CP/M loads the COM at `$0100`; each listing line includes its memory address and original bytes.

`z80dasm -l` supplies temporary `lXXXXh` labels for branch targets and `sub_XXXXh` labels for called routines. `ladder_110.sym` adds a small set of established names for the entry, main code, HUD words, and runtime entries. These names can be edited as analysis progresses.

`ladder_110.blocks` marks several known non-code ranges:

- Initial header/padding `$0103..$0136` and startup record `$1000..$100D`.
- Compiled-game data and text `$58DF..$617C`; runtime code starts at `$617D`.
- The BASLIB banner `$6678..$66AA`.
- All 34 inline 16-bit operands following `CALL $768E` (`$IMUG`). Their factors include 81 for map indexing and 100 for score handling.

For example, the climb calculation at `$4CD8` now reads as `call integer_mul_inline`, then `defw $0051`, then code resumes at `$4CDD`. The keyboard poll loop at `$4160` shows `call keyboard_poll` at `$4163`.

The first compiled instruction at `$100E` loads `HL=$00FF` and calls `$705E`. A BASCOM 5.30 probe of `WIDTH 255` produces `LXI H,00FF; CALL $WID`; its linked `$WID` routine has the same instruction structure as Ladder `$705E`, apart from relocated addresses. The symbol file therefore names `$705E` `width_setting`.

Rebuild from `src/ladder` with:

```sh
z80dasm -a -l -t -c \
  -S analysis/disasm/ladder_110.sym \
  -b analysis/disasm/ladder_110.blocks \
  -g 0x100 \
  -o analysis/disasm/ladder_110.asm \
  cpm/LADDER.COM
python3 tools/label_bdos_calls.py
```

The second command names calls to CP/M's `$0005` BDOS entry and annotates the function number loaded into `C`. It leaves numeric constants with the same value alone.

This is a **linear first pass**. Other inline operands and embedded tables remain to be marked, and some generated labels may point into data. `z80dasm` reports possible non-8080 instructions and self-modifying code. The runtime does write code-region bytes, including around `$6677`; the warning should not be dismissed without examining individual sites. The readable listing is a navigation aid, not a recovered source program. The suggestion that 5.2's string garbage collector differed substantially from 5.3 is plausible background but has not been verified here, so routine names are based on byte structure and the existing traces.

Verification: the byte columns in the generated listing reconstruct all 39,936 bytes of the input COM with no gaps or mismatches.
