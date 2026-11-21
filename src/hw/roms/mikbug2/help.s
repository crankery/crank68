; MIKBUG command summary, entered by ? or H/h.
    .org 0xf350
help_command:
    jsr pcrlf
    ldx #help_text
    jsr pdata1
    jmp contrl

help_text:
    .byte "? H  HELP             F  BOOT FLEX",13,10
    .byte "B    LIST BREAKS      C  CONTINUE",13,10
    .byte "D    DELETE BREAKS    G  GO TO ADDRESS",13,10
    .byte "L    LOAD S-RECORDS   M  CHANGE MEMORY",13,10
    .byte "N    NEXT INSTRUCTION P  PUNCH S-RECORDS",13,10
    .byte "R    REGISTERS        S  TTY SPEED",13,10
    .byte "T    TRACE            U  REMOVE BREAK",13,10
    .byte "V    SET BREAK",4
