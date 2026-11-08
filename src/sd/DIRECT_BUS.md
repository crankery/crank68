# Proposed direct-bus SD board

This is a hardware proposal, not the interface implemented by the current SD
board. [PROTOCOL.md](PROTOCOL.md) specifies that board's PIA transport. This
proposal gives a **separate ATmega328P-PU** its own two-byte memory-mapped
interface to the C68 bus. The AVR runs at 5 V from its internal 8 MHz
oscillator, as in the existing SD project. The SD card stays on level-shifted
SPI. The first firmware milestone can use one FAT32 `/FLEX.DSK` file; the
planned SD-only boot layout below maps up to four raw FLEX images, each with
256-byte sectors. The current image is 128 tracks × 32 sectors; geometry can
be read from each image rather than compiled into the new bridge.

## What the 6800 sees

Use **`$E090/$E091` provisionally**. Decode A7–A1 and the C68 I/O select for
the pair; A0 selects the register. The address can move before layout. It is
separate from VERA's `$E040–$E05F`, sound at `$E060`, and the keyboard byte at
`$E080`.

| Address | Read | Write |
| --- | --- | --- |
| `BASE+0` (`$E090`) | Status, no side effects | Begin a command |
| `BASE+1` (`$E091`) | Read and consume one response byte | Send one parameter or payload byte |

Proposed status bits:

| Bit | Name | Source | Meaning |
| --- | --- | --- | --- |
| 0 | `RX_SPACE` | Hardware flag | A command or data byte can be accepted |
| 1 | `TX_VALID` | Hardware flag | A response byte is ready to read |
| 2 | `BUSY` | AVR output | A transaction is in progress |
| 3 | `ERROR` | AVR output | Last terminal response was nonzero |
| 4 | `MEDIA_READY` | AVR output | Card mounted and D0 image ready for boot |
| 5–7 | Reserved | Tied low | Read as zero |

`RX_SPACE` and `TX_VALID` are the essential handshake bits. The host polls
`RX_SPACE` before **every** write, including a command, and `TX_VALID` before
**every** data read. Reading status never acknowledges a byte. Reading data
clears `TX_VALID` during that read cycle. A selected write captures the byte
and clears `RX_SPACE` during that write cycle. The AVR raises the corresponding
flag only when it has taken the input byte or staged the next output byte.
There is one bus-boundary byte in each direction. SD latency merely keeps a
ready bit low; the 6800 never waits inside a bus cycle.

The AVR should offer `RX_SPACE` only when it expects a command, track/sector,
payload, or checksum byte. It holds that bit low while sending a response.
All commands return at least one status byte through `BASE+1`. The host reads
that byte even when `ERROR` is set; `ERROR` alone does not identify the fault.
`BUSY` can remain high until the final response byte has been consumed.
`ERROR` clears on the next accepted command. Define an AVR reset/timeout path
that discards a partial request and eventually offers a new command.

## Bus and latch blocks

```text
 C68 D0..7 -> [CPU-write HCT574] --tri-state--> AVR PD0..7
                                           +----> [CPU-read HCT574] -> C68 D0..7
 AVR/status flags ------------------------------> [HCT244] --------> C68 D0..7

 /SD_SEL, A0, R/W, BUS_OK, Φ2 -> address/strobe logic -> latch clocks,
                                   read output enables and ready flags
```

The two HCT574s share the AVR's Port D pins but face opposite directions.
Their outputs must never be enabled against another driver. The CPU-write
latch samples the C68 data bus at the **end** of an accepted write. Its
three-state outputs are enabled only while AVR PD0–PD7 are inputs and the AVR
is copying the byte. To publish a byte, disable that latch's outputs, make
PD0–PD7 outputs, pulse the CPU-read latch's clock, then return PD0–PD7 to
inputs. The CPU-read latch holds the byte with no AVR timing dependence; its
outputs drive the C68 bus only for a selected `BASE+1` read.

The separate HCT244 presents status for `BASE+0` reads. Its two output-enable
pins can share the qualified status-read signal. Data-latch and status-buffer
output enables must be mutually exclusive, including during reset. Tie
unused status inputs low and give AVR-supplied status inputs defined levels
while the AVR is reset. A status read must not require the AVR to notice that
read or swap an output latch between adjacent CPU cycles.

Use two dual HCT74s (four flip-flops) for the proposed control state:

| Flip-flop | Job |
| --- | --- |
| `RX_SPACE` | Clear on accepted CPU write; AVR sets after taking the byte |
| `TX_VALID` | AVR sets after loading output latch; clear on CPU data read |
| `WR_KIND` | Capture A0 with the CPU write: 0=command, 1=data |
| `WR_ARMED` | Capture `RX_SPACE` at write-cycle start so a second write cannot overwrite the pending byte |

For example, the ready flip-flops may clock in zero on their respective
consuming bus strobes and use their asynchronous preset inputs for AVR
release/publish pulses. The exact polarity, write-arm logic, reset wiring,
and setup/hold margins need a schematic and scope check. The AVR must see
the **latched** `WR_KIND`; raw A0 may already have changed by the time its
interrupt runs. An invalid write while `RX_SPACE=0` must leave the pending
byte intact. A sticky overrun indication is optional, but the input latch
must not be clocked for that invalid write.

`/SD_SEL` should qualify only this two-byte address pair. Combine it with
`BUS_OK`, R/W, A0 and **Φ2** to produce write-start, accepted-write-end,
status-read, and data-read strobes. Φ2 goes to this external logic; the AVR
keeps its own 8 MHz clock. Choose the capture edge when CPU data and A0 meet
the HCT574/HCT74 setup and hold requirements. Use address and read direction
to make the two read output enables disjoint. The bus must be high impedance
from this board outside selected read cycles.

| Selected valid cycle | A0 | R/W | Hardware action |
| --- | --- | --- | --- |
| Command write | 0 | 0 | If armed, latch D0–D7 and A0 at write end; clear `RX_SPACE` |
| Data write | 1 | 0 | Same latch/flag action, with A0 latched as data |
| Status read | 0 | 1 | Enable HCT244 only; no flag changes |
| Data read | 1 | 1 | Enable CPU-read HCT574; clear `TX_VALID` at read end |

`WR_ARMED` must hold the value of `RX_SPACE` from the start of a write until
its end; gating the end strobe directly with the flag being cleared by that
same strobe risks a short clock pulse. This is a timing requirement for the
schematic, rather than a specified gate-level circuit.

On power-up or AVR reset, clear both ready flags, disable the data output,
and hold the status driver disabled during reset itself. After reset is
released, status may read as all zero until firmware initializes. The AVR
initializes its pins and SD library, then sets `RX_SPACE` to
accept the first command, whether or not a card mounted. A missing card is
reported by STATUS/INFO or a failed READ/WRITE, not by a permanently dead
interface. Reset during a transaction leaves the C68 polling until the AVR
reinitializes or the ROM timeout expires. Keep the AVR's RESET/ISP pins and
the SD SPI pins accessible for programming.

This is a **block-level part list**, not a finished schematic: two
[HCT574 octal registers](https://www.ti.com/product/SN74HCT574), one
[HCT244 status driver](https://www.ti.com/product/SN74HCT244), two
[HCT74 dual flip-flops](https://www.ti.com/product/SN74HCT74), address/strobe
logic (small gates or a GAL), SD level shifting, reset and decoupling. HCT
inputs suit the C68's 5 V TTL bus. Check actual propagation, setup/hold,
output-enable, and bus-turnaround timing before selecting packages or making
a PCB.

## Provisional ATmega328P-PU pin budget

The internal oscillator frees PB6/PB7 as GPIO if asynchronous Timer2 is not
using them. Arduino Uno pin numbering does not expose these two DIP pins;
firmware would access PORTB directly. This proposal uses all 22 GPIO with
RESET left enabled, so any LEDs or extra card signals need multiplexing or
a pin-map revision.

| AVR pins | Direction | Job |
| --- | --- | --- |
| PD0–PD7 | switched | Shared eight-bit latch bus |
| PB0 | output | Enable CPU-write latch toward AVR |
| PB1 | output | Clock AVR byte into CPU-read latch |
| PB2–PB5 | SPI | SD chip select, MOSI, MISO, SCK |
| PB6 | input | Latched `WR_KIND` (A0) |
| PB7 | output | `BUSY` status |
| PC0 | input | `RX_SPACE` feedback/event |
| PC1 | output | Release/set `RX_SPACE` |
| PC2 | output | Publish/set `TX_VALID` |
| PC3 | input | `TX_VALID` feedback/event |
| PC4 | output | `ERROR` status |
| PC5 | output | `MEDIA_READY` status |

The ready signals may use pin-change interrupts or polling; the flip-flops
hold their state until serviced, so no sub-microsecond ISR is required. Verify
that PB6/PB7 really are available with the chosen fuse/core settings and that
ISP cannot enable either latch onto the bus while programming.

## Byte and sector transactions

Keep INFO, STATUS, READ, WRITE and SYNC as the starting commands. The command
register replaces the old PIA stream's `A5 5A` sync bytes. Sector commands
need a **drive number**, track, and one-based sector number through the data
register; the valid range comes from that drive's mounted image. INFO and
STATUS need a drive number too. All responses begin with the current
numeric status code. Successful READ continues with 256 bytes and the 16-bit
unsigned-byte additive checksum, high byte then low byte. WRITE takes 256
bytes plus that checksum and returns status **after** checked SD sync. The
existing storage engine and error values are candidates for reuse, but this
bus transport needs its own version/identity so a PIA-v2 ROM cannot mistake
it for compatible hardware.

For each configured image, read FLEX's system information record at track 0,
sector 3 (file offset 512). Its bytes 38 and 39 hold the **last track number**
and **sectors per track**. Thus the current image contains `127, 32`, meaning
128 tracks of 32 sectors. Compute the expected file size as
`(last_track + 1) * sectors_per_track * 256`, and reject an image if either
geometry value is implausible or the size differs. The file length alone
cannot distinguish, for example, 128 × 32 from 256 × 16. Return the mounted
geometry per drive in INFO and use it for address validation and file offsets.
Report the last track number rather than an 8-bit track count, so a 256-track
image can still be represented. Keep the 256-byte sector size fixed, since
this FLEX format and the existing sector transfer protocol assume it.

The MIKBUG ROM's `$F000` READ/WRITE/READY/INIT API is a useful starting point,
but it has no drive argument today. Add a unit-select operation or revise the
API so MIKBUG and FLEX can address D0–D3; selecting D0 before boot must be
unambiguous. The ROM also currently checks for **exactly** 128 × 32 in
`sdcard.s`, so it must accept each drive's INFO geometry and use those bounds.
The emulator will need a new two-register device model.

## SD-only boot and volume map

The eventual MIKBUG `F` path should initialize the direct-bus bridge, select
**D0**, read its track-0/sector-1 boot sector into `$0100`, and jump there.
That boot sector must be an SD-aware link that follows `FLEX2.SYS` using the
ROM SD API. FLEX's runtime drive map must agree that the boot image is drive 0.
The present SD image converter copies an SRAM-specific boot sector, so it must
install the SD link and place `FLEX2.SYS` on D0 before this can work. For the
first SD-only build, an absent or invalid D0 can simply print an error and
return to MIKBUG; no SRAM fallback is required.

Proposed root-directory config, using a short 8.3 name such as `VOLUMES.INI`:

```ini
[VOLUMES]
D0=VOL0.DSK
D1=VOL1.DSK
D2=
D3=
```

The AVR parses this once at mount with a short fixed buffer. A nonempty entry
names an existing raw FLEX image; an empty entry means the drive is absent and
its INFO/READ/WRITE reports that state. D0 is mandatory for `F`. Check each
image's SIR geometry against its file length before marking that drive ready.
For now, support only simple root-directory 8.3 names and this one section;
reject duplicate keys, malformed entries, and a missing configured file. A
bad config may stop the mount and report an error instead of attempting
recovery. The AVR may keep one image open at a time and reopen on drive
changes; keeping four file handles is an optimization to assess against its
2 KiB RAM budget. The config controls image names, not hardware wiring.

`D3=RAM,VOL3.DSK` is a separate future design. It would require a policy for
loading, writeback, and ownership of banked SRAM pages. The SD-only map above
does not reserve those pages, leaving banked SRAM available for experiments.

First bench checks: no bus drive on deselection/reset; command/data write
capture and A0 kind; immediate ready-bit changes on back-to-back accesses;
status/data output exclusion; then INFO/STATUS, full READ and WRITE,
checksum error, missing card, and reset in mid-transfer. Scope the C68
address/data/Φ2 signals with both latch clocks and output enables at the
intended CPU speed.
