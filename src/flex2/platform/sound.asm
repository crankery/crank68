; SN76489AN sound board. Strap its eight address jumpers for $E060.
; Revision 1 needs bit-reversed bytes; revision 2 crosses the data lines.
 IF SOUND_BOARD_REV=2
C68MUTE1 EQU $9F
C68MUTE2 EQU $BF
C68MUTE3 EQU $DF
C68MUTEN EQU $FF
C68TONELO EQU $8C
C68TONEHI EQU $11
C68VOL EQU $92
 ELSE
C68MUTE1 EQU $F9
C68MUTE2 EQU $FD
C68MUTE3 EQU $FB
C68MUTEN EQU $FF
C68TONELO EQU $31
C68TONEHI EQU $88
C68VOL EQU $49
 ENDIF
C68BEEP PSHA
; Mute all channels first, since the chip's power-on state is unspecified.
 LDAA #C68MUTE1
 JSR C68SND
 LDAA #C68MUTE2
 JSR C68SND
 LDAA #C68MUTE3
 JSR C68SND
 LDAA #C68MUTEN
 JSR C68SND
; With the board's 4 MHz oscillator, divider $11C gives about 440 Hz.
 LDAA #C68TONELO
 JSR C68SND
 LDAA #C68TONEHI
 JSR C68SND
 LDAA #C68VOL
 JSR C68SND
 LDAB #$C0
C68BOOP1 LDAA #$FF
C68BOOP2 DECA
 BNE C68BOOP2
 DECB
 BNE C68BOOP1
 LDAA #C68MUTE1
 JSR C68SND
 PULA
 RTS

; READY is not wired. Wait well beyond the chip's 32 clock load time
; between writes (8 us at the board's 4 MHz oscillator).
C68SND STAA $E060
 LDAB #20
C68SNDW DECB
 BNE C68SNDW
 RTS
