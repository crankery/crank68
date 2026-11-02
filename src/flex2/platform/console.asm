; Polling MC6850 console, based on mikbug2's inchmits/outchmits/polcat_mits.
; FLEX uses A for characters. Preserve B and X; input never echoes.
C68IN PSHB
C68INW INC C68TICKS+1
 BNE C68INSTATUS
 INC C68TICKS
C68INSTATUS LDAB $E010
 ASRB
 BCC C68INW
 LDAA $E011
 ANDA #$7F
 PULB
 RTS
C68OUT PSHB
C68OUTW LDAB $E010
 ASRB
 ASRB
 BCC C68OUTW
 STAA $E011
 PULB
 RTS
; Carry set when a character is ready; A and X unchanged, B clobbered.
C68POLL LDAB $E010
 ASRB
 RTS
; This FLEX's GETCHR expects the monitor-style input entry to echo.
C68ECHO JSR C68IN
 JMP C68OUT
; MON leaves FLEX and restarts whichever BIOS/monitor is installed.
C68MON SEI
 LDX $FFFE
 JMP 0,X
