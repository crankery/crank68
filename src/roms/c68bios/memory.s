; zero page definitions
        .section .zp, "aw", @nobits

        .global zp_ptr
        .global zp_count

zp_count:
        .space 1
zp_ptr:
        .space 2

; bios storage
        .section .bios_tmp, "aw", @nobits

        .global bios_tmp

bios_tmp:
        .space 0x100