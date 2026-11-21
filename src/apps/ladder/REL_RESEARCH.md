# Ladder CP/M runtime investigation

The original `cpm/LADDER.COM` is a 39,936 byte CP/M load image (`$0100` through
`$9CFF`). The accompanying BASCOM 5.3 archive contains two different runtime
libraries: `BASLIB.REL` (24,960 bytes) and `OBSLIB.REL` (48,384 bytes).

The original COM itself contains the banner `BASLIB #500203 5.2 - OWNED BY
MICROSOFT, 1979` (at `$667D` in `LADDER.COM`, and `$24EE` in `LADCONF.COM`).
Decoding `OBSLIB.REL` reveals a different banner in its `INITS` module:
`BASLIB #000000 5.30 - OWNED BY MICROSOFT, 1980`. The banner is strong evidence
that Ladder carries a 5.2 runtime, although it does not by itself identify
the precise compiler build or library file used to link it.

## First useful match

Microsoft's LINK-80 `.REL` format is a bitstream, mixing literal bytes,
relocatable words, and named symbols. Searching the raw `.REL` bytes for COM
code is therefore misleading. The format is documented in the
[Microsoft Utility Software manual](https://deramp.com/downloads/microsoft/Manuals/Utility%20Software%20Manual.pdf),
section 2.3. `rel_anchors.py` decodes the stream and searches only contiguous
literal runs of at least 12 bytes that occur uniquely in the COM image.

| Library | Modules decoded | Modules with a unique matching run in `LADDER.COM` |
| --- | ---: | ---: |
| `BASLIB.REL` | 91 | 1 |
| `OBSLIB.REL` | 214 | 18 |

The strongest `OBSLIB.REL` anchor is the `Disk` module: 11 distinct runs,
188 matched bytes in total, all imply a program base of `$8574` in
`LADDER.COM`. That yields candidate entry addresses `$DKC=$85F4` and
`$GET=$8B25`. The `MATHPK` module has six runs implying base `$7A7E`,
including a 129 byte exact run, but other runs imply nearby shifted bases;
it should not yet be labeled wholesale. `STRUTL` shows the same kind of
shifted-base ambiguity. The `Disk` module also has 11 consistent runs in
`LADCONF.COM`, at base `$4231`.

## MBASIC 5.2 as a comparison image

The supplied `cpm/msbasic5.2/MBASIC.COM` is 24,320 bytes and contains the
banner `BASIC-80 Rev. 5.2` at `$5F85`. A search for distinct exact runs of at
least 24 bytes, filtering low-diversity byte sequences, finds seven runs
shared with each of `LADDER.COM` and `LADCONF.COM`. The longest is 129 bytes:
MBASIC `$3628`, Ladder `$833A`, and LADCONF `$3FF7`. The REL decoder maps
that run to the `MATHPK` module in the 5.3 `OBSLIB.REL`. Several shorter
shared runs sit in a region that OBSLIB identifies as `Disk`.

MBASIC is thus a useful same-era comparison for selected routines and
constants. It does not supply the missing 5.2 linker symbols or prove that
the entire compiler runtime matches the interpreter. `compare_com.py`
reproduces these exact-run comparisons.

## Rejected loose REL candidate

`cpm/BASLIB (1).REL` (49,664 bytes; SHA-256
`24a3f7e5a2f39e2987d2bb1a5196636253e2eb865db94ea8f7d04567e9ec0029`)
does not form one continuous LINK-80 library stream. Its start matches 340
bytes from near the end of the supplied 5.3 `OBSLIB.REL`; decoding then reaches
an End File marker after only two named modules. Of its 388 128-byte blocks,
52 are entirely `E5` and 34 entirely zero, and offset `$2000` contains
unrelated BASIC source text. It appears to be a mixed or damaged disk extract,
not evidence for the sought 5.2 `BASLIB.REL`. Keep the original file for
provenance rather than modifying it in place.

These are exact loaded-byte matches, including possible constants and strings;
they do not prove that the entire library is an exact version match. The
version banners show that this 5.3 `OBSLIB.REL` is **not** the 5.2 runtime in
Ladder. It is still a useful source of candidate routine labels because some
code survived between releases. The 5.3 compiler help describes `/O` as
producing a standalone program without `BRUN.COM`, but that switch does not
establish how the older Ladder executable was built.

## Reproduce

From `src/apps/ladder`:

```sh
python3 tools/rel_anchors.py cpm/BASCOM53/OBSLIB.REL
python3 tools/rel_anchors.py cpm/BASCOM53/BASLIB.REL
python3 tools/rel_anchors.py cpm/BASCOM53/OBSLIB.REL cpm/LADCONF.COM
python3 tools/compare_com.py cpm/LADDER.COM cpm/msbasic5.2/MBASIC.COM
python3 tools/compare_com.py cpm/LADCONF.COM cpm/msbasic5.2/MBASIC.COM
```

Next, look for the exact 5.2 `BASLIB.REL`, check candidate addresses in a Z80
disassembly, and extend the matcher to normalize relocated 16-bit operands.
Then map calls into confirmed runtime modules, leaving the remaining code and
data as candidates for Ladder logic. Keep the CP/M binaries untouched; derive
all reports from them.
