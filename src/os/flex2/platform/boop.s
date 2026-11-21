; FLEX command to send BEL through the C68 console sound hook.
        .equ outch, 0xad0f
        .equ warms, 0xad03

        .org 0x0300
start:
        ldaa #7
        jsr outch
        jmp warms
