; Reset-time boop for the SN76489AN board at $E060.
; Revision 1 has TI D0 wired to CPU D0, so its command bytes are reversed.
; Revision 2 crosses the data lines and takes native SN76489AN commands.
    .if SOUND_BOARD_REV=2
    .equ SOUND_MUTE1, 0x9f
    .equ SOUND_MUTE2, 0xbf
    .equ SOUND_MUTE3, 0xdf
    .equ SOUND_MUTE_NOISE, 0xff
    .equ SOUND_TONE_LOW, 0x8c
    .equ SOUND_TONE_HIGH, 0x11
    .equ SOUND_VOLUME, 0x92
    .else
    .equ SOUND_MUTE1, 0xf9
    .equ SOUND_MUTE2, 0xfd
    .equ SOUND_MUTE3, 0xfb
    .equ SOUND_MUTE_NOISE, 0xff
    .equ SOUND_TONE_LOW, 0x31
    .equ SOUND_TONE_HIGH, 0x88
    .equ SOUND_VOLUME, 0x49
    .endif

    .org 0xf300
sound_startup:
    ; Establish a known silent state before playing the short tone.
    ldaa #SOUND_MUTE1
    jsr sound_write
    ldaa #SOUND_MUTE2
    jsr sound_write
    ldaa #SOUND_MUTE3
    jsr sound_write
    ldaa #SOUND_MUTE_NOISE
    jsr sound_write

    ; Divider $11C at 4 MHz gives about 440 Hz.
    ldaa #SOUND_TONE_LOW
    jsr sound_write
    ldaa #SOUND_TONE_HIGH
    jsr sound_write
    ldaa #SOUND_VOLUME
    jsr sound_write

    ldab #0xc0
sound_duration_outer:
    ldaa #0xff
sound_duration_inner:
    deca
    bne sound_duration_inner
    decb
    bne sound_duration_outer

    ldaa #SOUND_MUTE1
    jsr sound_write
    rts

; READY is not connected. 20 iterations exceed the chip's 32-clock
; transfer time even at a 2 MHz CPU clock and 4 MHz sound clock.
sound_write:
    staa 0xe060
    ldab #20
sound_write_wait:
    decb
    bne sound_write_wait
    rts
