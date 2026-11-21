# BASCOM 5.30 tiny-program experiment

On 2026-11-18, compiled this source with the archived files in `cpm/BASCOM53`:

```basic
10 PRINT 1
20 END
```

The experiment used a temporary CP/M directory under `/private/tmp/ladder-bascom-tiny`; the archived compiler and libraries were not modified.

## Compiler workaround

The archived `BASCOM.COM` performs a machine-specific memory/port check at `$4436`: it disables interrupts, writes to port 0, and expects address `$0100` to become read-only. `iz-cpm` leaves `$0100` writable and the compiler exits before processing source. In a **temporary copy only**, bytes at file offset `$4336` (loaded address `$4436`) were changed from `F3 D3 00` (`DI; OUT (0),A`) to `C3 50 44` (`JP $4450`), bypassing that check. This copy was named `BASCHK.COM`. The compiler then reported zero fatal errors. The exact original hardware behavior is unverified.

## Commands and output

With `TINY.BAS` written as CP/M text (CRLF, trailing Ctrl-Z):

```text
BASCHK TINY,TINY=TINY/O
L80 TINY,TINY/N/E
TINY
```

The output is `1`. `TINY.REL` is 256 bytes, and the standalone `TINY.COM` is 8,832 bytes. The COM begins with `JP $0114` and contains the string `BASLIB #000000 5.30 - OWNED BY MICROSOFT, 1980` near file offset `$40`.

The compiler's `.PRN` listing exposes the small program's generated logic and symbolic runtime calls:

```text
CALL $530
CALL $PR0A
LXI  H,0001
CALL $PV2C
CALL $END
CALL $END
```

The last `$END` is the compiler's implicit end-of-program call. L80 resolves these symbols and pulls the required runtime modules into the standalone COM. In the linked code, the sequence starts at `$0128` and includes calls to `$0263`, `$086A`, `$0708`, and `$0304` (twice), with `LXI H,$0001` between the second and third calls.

For comparison, compiling the same source without `/O` and linking it as `TINYR` yields a 512-byte `TINYR.COM`. It also prints `1` when `BRUN.COM` (15,488 bytes) is available. The non-`/O` COM has a loader stub that places its program at `$4000`, and L80 reports code entry `$4011` and data range `$4000–$4189`.

## Relevance to LADDER.COM

The original `cpm/LADDER.COM` is 39,936 bytes, begins with a direct `JP` entry, and embeds `BASLIB #500203 5.2 - OWNED BY MICROSOFT, 1979` at file offset 25,981. This looks like the same standalone linking pattern: compiled program logic plus selected runtime modules and relocated references. The 5.30 experiment shows that generated BASIC code can be very small beside the linked runtime, and the `.PRN` listing maps compiler-generated code to library symbols. It does not establish identical module layout or bytes for BASCOM 5.2.
