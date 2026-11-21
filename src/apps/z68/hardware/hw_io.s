; C68 FLEX console services. The raw input driver is fixed at $BF00;
; standard FLEX INCH routes through C68ECHO and would echo editing controls.
; getc returns a seven-bit character in A, preserving B and X.
getc:
        jmp 0xbf00
; Application console output uses FLEX, preserving the hardware abstraction.
; A is the character for putc. X points to a byte for print_hex_byte or to a
; big-endian word for print_hex_word. The word helper advances X to the second byte.
putc:
        tst status_capture
        beq console_putc
        jmp status_putc
console_putc:
        tst wrap_enabled
        beq console_raw_putc
        jmp wrap_putc
console_raw_putc:
        jmp outch
print_hex_word:
        jsr outhex
        inx
print_hex_byte:
        jmp outhex
