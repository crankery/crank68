# AM9511A performance preflight

Goal: predict and then measure the benefit of an AM9511A math board on the C68,
first for MITS/Microsoft 6800 BASIC trig functions and later for a VERA
Mandelbrot renderer. There is no measured speedup yet: the board and its 6800
driver do not exist. A chip execution time alone is not a BASIC benchmark.

## Published chip cost

[AMD's Am9511A command table](https://bitsavers.trailing-edge.com/components/amd/z8000/1980_AM-PUB098_AmZ8000_Family_Data_Book.pdf)
gives these **chip clock cycles**. Times below assume a 2 MHz AM9511A clock;
the installed chip's speed grade and board clock still need confirming.

| Command | Chip cycles | At 2 MHz |
| --- | ---: | ---: |
| FADD | 54–368 | 27–184 µs |
| FSUB | 70–370 | 35–185 µs |
| FMUL | 146–168 | 73–84 µs |
| SIN | 3,796–4,808 | 1.90–2.40 ms |
| COS | 3,840–4,878 | 1.92–2.44 ms |
| TAN | 4,894–5,886 | 2.45–2.94 ms |
| ATAN | 4,992–6,536 | 2.50–3.27 ms |

These exclude 6800 data transfers, command/status accesses, format conversion,
polling, BASIC dispatch, and display output. Data-dependent cycle ranges are
real, so use several inputs rather than one attractive example. At 3 MHz,
divide the chip-only times by 1.5 if the part and board support that clock.

## What to compare

The BASIC source has four adjacent trig dispatch entries at `$012D–$0134` in
`c68basic.s`. Its startup can disable trig functions, so the baseline must
enable them. For each SIN/COS/TAN/ATN call measure:

1. Existing BASIC call from expression entry to result available, in **6800
   cycles**, with terminal output excluded.
2. Patched BASIC call over the same boundary: conversion into AM9511A format,
   operand transfer, chip execution/wait, status/error handling, conversion
   back, and return.
3. Whole BASIC loop with the same number of calls, so dispatch, interpreter,
   and loop overhead appear in the result.

Use inputs such as zero, small positive/negative values, values near `pi/2`,
large angles, and TAN near its poles. Check numerical differences and errors
as well as cycles. The AM9511A has a 7-bit signed exponent and a 24-bit
mantissa; BASIC's accumulator format must be verified before designing the
conversion or claiming equivalent range/rounding.

The emulator already counts 6800 cycles in `Cpu::cycles_`. A temporary,
isolated profiling mode can record entry/return cycle counts for the software
math routines. Do not use host wall-clock time: emulator speed, terminal I/O,
and throttling would obscure the comparison. Model the AM9511A using its
published cycle range, then replace that model with bench measurements on the
real board. A FLEX tester should first measure transfer and polling overhead
without BASIC.

## Mandelbrot bound

For one hand-written iteration, keep `x*x` and `y*y` for both escape testing
and the next value. A straightforward implementation uses three floating
multiplies (`x*x`, `y*y`, `x*y`), four adds and one subtract, with `2*x*y`
formed by adding `x*y` to itself. The chip-only execution bound at 2 MHz is:

`3*FMUL + 4*FADD + FSUB = 724–2346 chip cycles = 0.36–1.17 ms/iteration`.

This is a **lower bound**, not an expected frame time. It omits all host
transfers, BASIC interpretation if used, loop control, pixel output, and
possibly additional chip operations required by the stack schedule. At a
fixed 50 iterations per pixel, even that lower bound is 55–180 seconds for
64×48 pixels or 19–63 minutes for 320×200 pixels. Real Mandelbrot pixels
escape at different iterations, so benchmark a fixed viewport and iteration
limit, and report the actual total iteration count.

Compare the same algorithm in (a) unmodified BASIC, (b) BASIC with chip math,
and (c) a dedicated 6800 renderer using the chip. Count cycles spent in math,
loop/interpreter, and VERA writes separately. The speedup for a complete
image is `baseline total cycles / accelerated total equivalent time`, not the
ratio of isolated chip and software multiply timings.
