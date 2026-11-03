# crank68 emulator

Build with `make`; run tests with `make test`.

The SRAM card provides 1 MiB (two 512K × 8 chips), mapped through two
independent 4 KiB windows:

| CPU addresses | Write-only page latch | Page values |
| --- | --- | --- |
| `$C000–$CFFF` | `$E002` | `$00–$FF` |
| `$D000–$DFFF` | `$E003` | `$00–$FF` |

Both windows address the same storage, so selecting the same page aliases
its contents. The physical image offset is `page * 4096 + window_offset`.
Latch bit 7 selects the chip; bits 0–6 select one of its 128 pages.
Latch reads return `$FF`. SRAM and both latches start at zero for a new
emulator process; CPU reset does not clear them.

Add `--sram-image flex.sram` to your usual emulator command, for example:

```sh
build/bin/emu --load ../roms/mikbug2/mikbug2_trim.bin@E100 --sram-image flex.sram
```

An existing image must be exactly 1,048,576 bytes. A missing image starts
with cleared SRAM and is created on exit. The file contains all 256 pages
in page-number order, without headers or latch state. It is saved when the
emulator exits with Ctrl-] or stops its execution loop (including caught
CPU errors). Forced termination does not save it. Saving writes a temporary
`<image>.tmp` file and renames it over the image after closing successfully.
Without `--sram-image`, SRAM lasts only for the current process.

Existing `--load file@address` loads through the CPU memory map; it does not
load the full SRAM image or change I/O latches.

## SD bridge

Add `--sd-image FLEX.DSK` to connect the first PIA at `$E020–$E023` to a host
image through the SD bridge's normal byte protocol. The image must already
exist, be writable, and be exactly 1,048,576 bytes. Sector writes are flushed
to the file immediately; the emulator does not create or resize it. It uses
the AVR firmware's protocol parser, including INFO, STATUS, checksums and
sector addresses, while completing the PIA handshakes immediately.

From `src`, `make run` prepares separate writable SRAM and SD session images
and passes both to the emulator. `make DRIVE_LAYOUT=sd-first run` puts SD at
FLEX drive 0 and keeps the two SRAM volumes at drives 1 and 2. MIKBUG's `F`
command still starts from physical SRAM; SD boot is a separate step.

## TCP console

Add `--tcp-console 6800` to connect ACIA #1 to a raw TCP client instead of
stdin/stdout. The listener binds to **127.0.0.1** and accepts one client.
Example from this directory, using your existing working SRAM image:

```sh
build/bin/emu --load ../roms/mikbug2/mikbug2_trim.bin@E100 --sram-image ../flex2/build/session.dsk --tcp-console 6800
```

In PuTTY (or another terminal emulator), select **Raw**, host `127.0.0.1`,
port `6800`. Set **Local echo** and **Local line editing** to **Force off**;
the guest software handles those. Configure Return to send carriage return.
This is a raw serial-byte stream, with no Telnet negotiation. A basic connection
can also be opened with `nc 127.0.0.1 6800`.

The CPU waits for the first connection so the boot banner is not lost. On
disconnect it pauses; reconnecting continues the existing machine without a
reset or banner replay. Extra simultaneous clients are closed. Socket buffers
are bounded, with CPU backpressure if the output queue fills. Unsent bytes in
the disconnected client's transport queues are discarded, as for a disconnected
serial terminal; this is not a terminal-screen history service.

Socket input/output preserves every byte, including letter case, NUL,
backspace, and escape sequences. The local console's historical case swap,
backspace rendering and `--show-control` display apply only to local mode.
Use uppercase input when running software that requires it, such as BASIC.

The launching terminal remains the debug/control console. Stop there with
**Ctrl-]** (Control plus `]`), or send SIGINT/SIGTERM to the emulator process;
normal exit saves the SRAM image as before. Ctrl-] received over TCP is guest
input, not a shutdown command. Breakpoint messages and continuation keys remain
on the launching terminal. Without `--tcp-console`, the existing local console
continues to work.

`make test` covers raw transport bytes, connection rejection/reconnect,
bounded output queuing, occupied-port errors, and a real 6800 ACIA echo program
through the executable. The process test checks its startup banner, reconnect,
signal shutdown/SRAM save, port validation, and the default local-console path.
These tests require permission to bind localhost sockets.
