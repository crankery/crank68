; Keyboard AVR on the VERA adapter, decoded independently at $E080.
; The AVR scans, debounces, translates and queues keys. A read returns
; zero when empty, or consumes one nonzero ASCII byte.
        .equ keyboard_data, 0xe080

keyboard_init:
        rts

; Block until a character is available; return it in A.
keyboard_getc:
keyboard_wait:
        ldaa keyboard_data
        beq keyboard_wait
        rts
