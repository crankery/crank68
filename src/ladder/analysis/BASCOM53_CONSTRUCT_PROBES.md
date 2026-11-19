# BASCOM 5.30 construct probes against Ladder 5.2

On 2026-11-18, tiny programs were compiled with the archived BASCOM 5.30 and their `.PRN` listings inspected. All 14 probes reported zero fatal errors. The compiler was run in a temporary CP/M directory with the same `BASCHK.COM` emulator workaround described in [BASCOM53_TINY_EXPERIMENT.md](BASCOM53_TINY_EXPERIMENT.md). Original archive files were not modified.

Each probe was compiled as `BASCHK NAME,NAME=NAME/O`. Selected probes were linked as `L80 NAME,NAME/N/E`. The listing gives symbolic runtime calls before L80 replaces them with relocated addresses.

| BASIC example | Generated pattern in `.PRN` |
| --- | --- |
| `PRINT 1` | `CALL $PR0A; LXI H,1; CALL $PV2C` |
| `PRINT "HI"` | `CALL $PR0A; LXI H,<const>; CALL $PV2D` |
| `A%=1` | `LXI H,1; SHLD A%` |
| `B%=A%+2` | `LHLD A%; INX H; INX H; SHLD B%` |
| `GOTO 30` | `JMP L00030` |
| `GOSUB 100` / `RETURN` | `CALL L00100` / `RET` |
| `FOR I%=1 TO 3` / `NEXT I%` | Direct integer loads, increments, arithmetic, and branches; no loop runtime call in this constant-bound example |
| `IF A%=1 THEN 40` | `LHLD A%; LXI D,FFFF; DAD D; MOV A,H; ORA L; JZ L00040` |
| `A=1`, `B=A+2` | `CALL $FASA` and `CALL $FADA` / `$FASO`, with inline `DW` operands |
| `FOR I=1 TO 3` / `NEXT I` | `CALL $LFMA`, `$FADA`, `$FASO`, `$LEJA`, each with inline `DW` operands as needed |
| `A$=INKEY$` | `CALL $INK; LXI D,A$; CALL $SASA` |
| `INPUT A$` | `CALL $IN0A`, `$IPUA`, `$IPUB`, with inline bytes |
| `A%=INP(0)` | Direct `IN 00; MOV L,A; MVI H,00; SHLD A%` |
| `PRINT CHR$(27);` | `CALL $PR0A; LXI H,001B; CALL $CHR; CALL $PV1D` |
| `A=RND(1)` | `CALL $RAN; CALL $FASO` |

Every program begins with `CALL $530` for initialization and ends with `CALL $END`, including a compiler-added implicit final `$END`. These are compiler patterns for these specific examples; expression complexity and variable types change generated code.

## Direct names for Ladder runtime entries

**Integer multiplication: `$IMUG` → Ladder `$768E`.** The probe `A%=B%*81` generated:

```asm
LHLD B%
CALL $IMUG
DB   51,00
SHLD A%
```

`C%=A%*100` used the same call followed by `DB 64,00`. In the linked 5.30 probe, `$IMUG` is at `$06ED`; in Ladder 1.10, the equivalent entry is `$768E`. Both wrappers have the same 15 instruction bytes apart from the relocated target of their one internal call:

```text
5.30 $06ED: EB E3 D5 5E 23 56 23 E3 CD FD 06 EB E1 E3 EB C9
5.2  $768E: EB E3 D5 5E 23 56 23 E3 CD 9E 76 EB E1 E3 EB C9
```

The inline factors `$0051` (81) and `$0064` (100) already occur in Ladder at this entry. See [MULTIPLY_INLINE.md](MULTIPLY_INLINE.md) for the behavioral analysis. This comparison establishes the `$IMUG` symbol for that routine.

**PRINT setup: `$PR0A` → Ladder `$6FEA`.** `PRINT 1` links `$PR0A` at `$086A` in the 5.30 COM. The first 20 bytes at `$086A` and Ladder `$6FEA` have the same opcode sequence and different relocated data/call addresses. Ladder's dynamic trace counted 9,476 executions at `$6FEA`. This supports the earlier PRINT/output setup reading.

**String assignment: `$SASA` → Ladder `$74DB`.** `A$=INKEY$` links `$SASA` at `$0A44` in the 5.30 COM. The first 48 bytes match Ladder `$74DB` instruction for instruction except for relocated addresses. The dynamic trace had already associated `$74DB` with string assignment. This supplies the compiler's symbol name.

**WIDTH setting: `$WID` → Ladder `$705E`.** A later probe, `10 WIDTH 255`, generated `LXI H,00FF; CALL $WID`. Ladder's first compiled instructions at `$100E` are `LD HL,$00FF; CALL $705E`. The first 16 bytes of the linked 5.30 `$WID` routine at `$0B88` and Ladder's `$705E` have the same instruction structure, differing only in relocated addresses. This identifies the startup call as `WIDTH 255` with high confidence.

The `$INK` listing shows how BASCOM 5.30 expresses `INKEY$`; Ladder's `$617D` poll calls BDOS function 6 with `E=$FF`, uppercases ASCII, and writes a null-terminated result through `HL`. Its symbol is **not yet established** by a matching 5.30 routine. The 5.30 linked `$INK` entry has a different wrapper, so calling `$617D` `$INK` would currently be an inference.

These matches use linked COM bytes, not just similar behavior. Relocation changes address operands, while the instruction structure can remain recognizable across library versions. Exact byte matching of whole runtime modules is still unsuitable when module contents differ.
