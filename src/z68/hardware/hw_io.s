; Application console output uses FLEX, preserving the hardware abstraction.
; A is the character for putc. X points to a byte for print_hex_byte or to a
; big-endian word for print_hex_word. The word helper advances X to the second byte.
putc:
        jmp outch
print_hex_word:
        jsr outhex
        inx
print_hex_byte:
        jmp outhex
