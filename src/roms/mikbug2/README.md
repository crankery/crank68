# MIKBUG2

`make` builds the 8 KiB `mikbug2.rom` image mapped at `$E000–$FFFF`.

Type `F` at the monitor prompt to cold boot FLEX 2 from banked SRAM.
The same handoff is available at the fixed address `$FFC0` (`G FFC0`,
or `JMP $FFC0` from a program). It does not return to its caller.

Preload the raw disk image built by `src/flex2` into banked SRAM first.
The routine masks interrupts, initializes the first ACIA at `$E010/$E011`
for polling, selects SRAM page zero through `$E002`, copies its first
256 bytes to `$0100–$01FF`, then jumps to `$0100`. The sector loader follows
the linked FLEX system file and starts FLEX. No disk validation is performed
by the ROM handoff; it requires a valid bootable image.

Booting clobbers A, X, SP and the sector buffer. FLEX takes over the monitor
workspace and stack; return to MIKBUG through reset. Existing monitor entry
addresses are preserved.

After building the sibling FLEX project, `make test` uses its generated disk
and the sibling emulator's 6800 CPU to test both reset → `F` → FLEX and the
direct `$FFC0` entry. Each path loads MSBASIC and checks `PRINT 2+2`.
Test binaries are temporary; the disk image is read into memory.
