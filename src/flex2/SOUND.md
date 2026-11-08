# SN76489AN sound board

Set the 76489 board's address jumpers to decode **`$E060`**. On reset, MIKBUG
plays a short tone before its banner. Run `BOOP` at the FLEX prompt to play it
again. FLEX also plays the same tone whenever a program writes
ASCII BEL (`$07`) through its normal console output routine. The BEL still goes
to ACIA 1, so a connected terminal may sound its own bell as well.

The tone uses channel 1 at about 440 Hz with the board's 4 MHz oscillator.
The code mutes all four channels before starting and mutes channel 1 at the end.
The board does not connect the chip's READY pin, so both ROM and FLEX wait
between register writes. The built revision `.01` connects CPU D0 to TI D0,
which TI defines as the *most significant* bit; its command bytes are reversed
in software. Revision `.02` crosses the data lines on the PCB. Build with
`make SOUND_BOARD_REV=2` when using that revision. The default is revision 1.

The emulator currently ignores writes to the unattached sound address. The
smoke test records them and checks the command sequence, but the actual sound,
volume and timing need a check on the assembled board.
