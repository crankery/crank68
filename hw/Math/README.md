# Math board interface review

The current schematic separates the C68 and Am9511A data buses with two
74LS573 latches. Most control nets are named and connected, but the GAL
program and C68 write-capture timing are not yet established.
Do not transfer it to a PCB until the bus timing is redesigned.

## What the current circuit does

- The processor GAL asserts `/IO_SEL` only for `$E000–$E0FF` while VMA and
  phase 2 are high (`src/pld/cpu.gal`). `BUS_OK` is the same valid bus phase.
- U2 compares A7–A4 with the four DIP switch bits. Its cascade inputs are now
  correctly set for standalone equality. Spare gates combine `SLOT_SEL`,
  `/IO_SEL`, and A3 into active-low `/MATH_SEL` at U7 pin 5. It selects the
  lower eight bytes of the chosen slot. `/IO_SEL` already includes VMA and
  phase 2 qualification.
- C68 D0–D7 reaches U5 D and U6 Q. The separate `DB0–DB7` bus reaches U5 Q,
  U6 D, and the Am9511A. GAL outputs now reach the Am9511A `/CS`, `/RD`,
  and `/WR` pins; C/D receives `OP0`. U5 and U6 output enables and U6 load
  reach GAL outputs. U9 clock and active-low clear reach GAL outputs.
  U5 load is not connected to a driver yet. The Am9511A RESET is inverted
  from C68 `/RESET`, and `/PAUSE` reaches the GAL. `/EACK` and `/SVACK`
  are tied high; `/END` and `SVREQ` are unused.

## Recommended replacement

Use a small **polled register bridge** between the C68 and Am9511A. The
Am9511A does not request ownership of the C68 address bus; this is a
peripheral timing problem, not DMA arbitration. The bridge owns the Am9511A
side of the data bus while a transaction is in progress, and the C68 only
sees ordinary, single-cycle registers.

The four-bit slot switch remains for relocation. The external `/MATH_SEL`
predecode selects the lower eight bytes of its 16-byte slot; live A0–A2
select the registers below. For example, switch setting `$A` places them at
`$E0A0–$E0A7`.

Proposed C68 register contract:

| Offset | Read | Write |
| --- | --- | --- |
| 0 | Bridge `BUSY`, `RESULT_VALID`, and fault bits | No effect |
| 1 | Last captured read byte | No effect |
| 4 | No driver | Queue one Am9511A data write |
| 5 | No driver | Queue one Am9511A command write |
| 6 | No driver | Request an Am9511A data read; byte value ignored |
| 7 | No driver | Request an Am9511A status read; byte value ignored |

All four requests have A2=1; A1:A0 encodes the operation directly, avoiding
an external opcode encoder. Separate addresses for read requests also save a
GAL data input.
`RESULT_VALID` should remain set until another request is accepted; a read of
offset 1 need not generate an asynchronous clear pulse. Mask `RESULT_VALID`
with `!BUSY` so software cannot mistake the previous result for a new one.

The bridge must capture CPU write data and request type during the selected
6800 cycle, then finish the Am9511A operation independently. It must keep
Am9511A `/CS`, C/D, and write data valid through the device's hold interval,
hold `/RD` or `/WR` active while `/PAUSE` is low, and latch read data only
after `/PAUSE` returns high. It must never enable both bus drivers at once.

U5 D is now on C68 D0–D7 and its Q on the **separate** Am9511A `DB0–DB7`
bus. U6 D is on `DB0–DB7` and its Q on C68 D0–D7. U5's output enable must
be off during Am9511A reads; U6's output enable must be off except for the
C68 result register read.
U5 `LE` is active during an accepted C68 request write and closes at its end;
its `/OE` is low only for an Am9511A **write**. U6 `LE` pulses after an
Am9511A **read** has completed while `/RD` is still active; its `/OE` is low
only when the C68 reads the result register. Am9511A `/WR` now reaches the
GAL's provisional `/MATH_WR` output.
The bridge status register also needs a bus driver: two GAL outputs with
programmable output enables might supply the status bits, if the final
GAL22V10 equations fit, or a small tri-state buffer can do it.

The controller must allow for `/PAUSE` to fall after the read/write strobe;
sampling an initial high level as completion would finish a read too early.
It must also handle a write for which `/PAUSE` never falls, which AMD permits.

Only `/PAUSE` is required as an Am9511A output to the GAL for the basic
polled bridge. It tells the controller when the current read/write transfer
can finish; it does **not** by itself mean a long arithmetic command has
completed. `/END` is an active-low open-drain command-complete output. It
needs a pull-up if used as a logic input; with `/EACK` held high, it remains
asserted until an acknowledge, reset, or Am9511A bus access clears it.
`SVREQ` is asserted only when the command requested service with bit 7 and
is unnecessary for polling. Both are disconnected in the current schematic;
software can request an Am9511A status read through the bridge to
inspect command progress. An interrupt feature can be designed separately.

Set `BUSY` as soon as a C68 request is captured; ignore or report a request
made while busy. Software polls `BUSY` before each request and polls
`RESULT_VALID` before reading offset 1. Reset clears both flags. The exact state machine, status
bit assignments, and component choice need a timing diagram before schematic
capture; the register map above is a design target, not implemented hardware.

## GAL and request handoff plan

U7 pin 1 has the board's free-running 2 MHz oscillator. With 74LS175 U9,
the current GAL inputs are pin 2 U9.Q0 (captured A0), pin 3 U9.Q1 (captured
A1), pin 4 live A2, pin 5 `/MATH_SEL`, pin 6 R/W, pin 7 `/RESET`, pin 8
`/PAUSE`, and pin 9 U9.Q2 (`REQ_PENDING`). U9.D2 is tied high and D3 low;
Q3 is unused. Pins 10, 11, and 13 are free inputs. Pins 14 and 15 are free
output macrocells; pins 16–23 have provisional control labels.
The following is a **provisional input assignment**, pending the request
storage and output equations:

| GAL pin | Signal |
| --- | --- |
| 1 | 2 MHz controller clock (wired) |
| 2, 3 | Captured operation bits A0/A1 from U9 (wired) |
| 4, 5 | Live A2, `/MATH_SEL` (wired) |
| 6–8 | R/W, `/RESET`, `/PAUSE` (wired) |
| 9 | Request pending from U9.Q2 (wired; D2 tied high) |
| 10, 11 | Free for live A0 and A1 |
| 13 | Spare input |

Only one pending bit is required: D2 is tied high, making Q2 the held
request when U9 is clocked. D3 is tied low and Q3 unused. Live A0 and A1
must still reach the GAL to distinguish C68 status/result reads and avoid
aliases at offsets 2 and 3. The captured A0/A1 describe the previous
request, not the current C68 bus cycle. `BUS_OK` is not needed because
`/IO_SEL` is already qualified by VMA and phase 2.

A CPU-side latch or flip-flop must capture A1:A0 at the **end**
of the selected 6800 write and assert a persistent `REQUEST_PENDING` level.
U5 captures the write byte at that same boundary. The GAL samples the held
request on its own clock, carries out the Am9511A cycle, and acknowledges it
afterward. A short `/IO_SEL` pulse must not be used as the only registered
request: the free-running GAL clock might miss it. Gate new CPU requests
while pending or busy so U5 and the operation code cannot be overwritten.
A 74LS175 is now placed as the request register: clock A1, A0, and a
constant high into three flip-flops on the accepted CPU write's trailing
edge; the third Q becomes `REQUEST_PENDING`. The GAL clears that register
after completing the request, preserving the operation bits throughout the
transaction. This is a topology proposal, not yet a checked
clock or reset circuit.

Provisional controller phases:

| Phase | Action |
| --- | --- |
| Idle | Am9511A controls inactive; wait for held request |
| Setup | Set C/D and data direction; assert `/CS` with data stable |
| Strobe | Assert `/RD` or `/WR`; allow for `/PAUSE` assertion delay |
| Wait | Hold the strobe while `/PAUSE` is low; satisfy minimum strobe width even if it never falls |
| Capture | On a read, latch valid Am9511A data into U6 before releasing `/RD` |
| Hold | Deassert strobe, then retain `/CS`, C/D, and write data for the specified hold time |
| Finish | Release `/CS`, record read validity, acknowledge the held request, return idle |

This is a state budget, not a GAL program. A 22V10 has ten output macrocells;
state bits, control pins, and bus-visible status all compete for them. Some
controls may be formed with the spare gates, but the equations should be
assembled and checked for product-term limits before the remaining GAL pins
are committed.

Candidate GAL-controlled functions, before pin assignment:

| Function | Destination or use |
| --- | --- |
| Accepted-write pulse | U9 rising-edge clock; inverted phase can load U5 |
| Request clear | U9 active-low clear, combined with system reset |
| `/CS`, `/RD`, `/WR` | Am9511A transaction strobes |
| U5 `/OE` | Drive `DB0–DB7` only during Am9511A writes |
| U6 load | Capture `DB0–DB7` after a completed Am9511A read |
| U6 `/OE` | Drive C68 D0–D7 only for a result-register read |
| `BUSY`, `RESULT_VALID` | C68-readable status bits |

That is already ten logical functions. Separate registered state outputs would
exceed a one-output-per-function allocation. The control outputs may themselves
serve as state bits through GAL feedback; spare NAND/inverter gates can also
derive some enables. Treat this as a fit problem until GAL equations are
assembled. Keep both 573 `/OE` pins pulled high by default so neither drives
a bus while the controller is unprogrammed or resetting.

The schematic has provisional U7 outputs on pins 16–23: `REQ_CLEAR`,
`REQ_CAPTURE`, `/HOST_TO_MATH_LATCH_OE`, `/MATH_TO_HOST_LATCH_OE`,
`MATH_TO_HOST_LOAD`, `/MATH_WR`, `/MATH_RD`, and `/MATH_CS`. These are not
a proved GAL pin assignment. `REQ_CLEAR` reaches U9's active-low clear pin,
so its equation must be low on system reset and on completion, and high
while U9 must retain its operation bits. `REQ_CAPTURE` reaches U9's
positive-edge clock pin, so its rising edge must occur while live A0/A1
meet setup and hold. The 22V10's output macrocells have different
product-term capacities; assign physical pins after equations are assembled.

U9's shared active-low clear should respond directly to host reset. Define
the GAL completion pulse as active-low `/REQ_CLEAR` and drive
`U9./MR = /RESET AND /REQ_CLEAR` with a spare NAND followed by an inverter.
Keep `/REQ_CLEAR` inactive through the transaction so Q0/Q1/Q2 retain the
operation and pending bit; assert it only in the finish state. The reset
path then works even before the GAL state machine has run.

### Latest schematic review

- All eight `D` and `DB` bit paths connect to the intended sides of U5/U6.
  There is no direct host-to-Am9511A byte-bus connection.
- `HOST_TO_MATH_LOAD` is on U5 pin 11, but its label near U7 is dangling.
  It needs a defined, active-high load window and a timely falling edge.
- Live host A0/A1 are not yet inputs to U7. The captured `OP0`/`OP1` cannot
  decode later host status/result reads. U7 pins 10/11 are available.
- A host-readable status path is still absent. U7 pins 14/15 are candidates
  to drive D0/D1 using their programmable output enables, subject to a GAL
  equation and bus-contention check.
- U5/U6 `/OE` nets currently rely on GAL outputs alone. Pull them high by
  default so both buses stay undriven during reset or before a GAL is fitted.
- The C68 connector exposes raw Φ2 on J1 pin B3. The processor can release
  write data only 10 ns after Φ2 falls. U5 load must close against that
  edge, so a load pulse derived only from the slower `/MATH_SEL` decode
  cannot be assumed to meet the latch hold-time requirement. Analyze the
  path using the actual processor-board 74LS245 and chosen latch/gate parts
  before committing the GAL `REQ_CAPTURE` and U5 load timing.
- The current Processor schematic has its 74LS245 U4 `/CE` pin on a lone
  `/Φ2` net with no driver; Processor ERC reports it undriven. Verify the
  actual processor-board revision or correct that schematic before using
  its bus-data timing as an input to this design.

## Why direct access is unsafe

At the schematic's 2 MHz Am9511A clock, AMD gives a **minimum** PAUSE-low
time of `3.5 × 500 ns + 50 ns = 1.8 µs` for a data read and
`1.5 × 500 ns + 50 ns = 0.8 µs` for a status read. The C68's roughly 1 MHz
6800 bus cycle cannot simply wait for those reads, because `/PAUSE` has no
connection to the processor clock control. AMD's 6809 interface also calls
for at least 60 ns of `/CS` and C/D hold after `/WR` rises and adds a data
latch to satisfy write-data hold. The previous direct interface did not
establish those margins. Slowing the Am9511A clock
would lengthen its read pause.

Sources: [AMD Peripheral Processor Interface Guide, sections 7.1.1 and
9.1.1](https://www.applefritter.com/files/2019/04/27/AMD%20-%20Peripheral%20Processor%20Interface%20Guide%201985.pdf),
[TI SN74LS85 data sheet](https://www.ti.com/lit/ds/symlink/sn74ls85.pdf).

The 10 ns host write-data hold figure above comes from Motorola's
[M6800 Microprocessor Applications Manual, section 4-2.5.1](https://www.bitsavers.org/components/motorola/6800/M6800_Microprocessor_Applications_Manual_1975.pdf).
