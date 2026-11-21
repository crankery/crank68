; zero page definitions
        .section .zp, "aw", @nobits

        .global zp_ptr
        .global zp_count
        .global zp_end
        .global zp_input
        .global zp_value
        .global zp_digits
        .global zp_nibble
        .global zp_range
        .global zp_row_count
        .global zp_ascii_ptr
        .global zp_ascii_row

zp_count:
        .space 1
zp_ptr:
        .space 2
zp_end:
        .space 2
zp_input:
        .space 2
zp_value:
        .space 2
zp_digits:
        .space 1
zp_nibble:
        .space 1
zp_range:
        .space 1
zp_row_count:
        .space 1
zp_ascii_ptr:
        .space 2
zp_ascii_row:
        .space 16

; bios storage
        .section .bios_tmp, "aw", @nobits

        .global bios_tmp

bios_tmp:
        .space 0x100
