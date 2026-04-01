; address bus overview
        .equ ram_start, 0x0000
        .equ ram_end, 0xbfff
        .equ bank_start, 0xc000
        .equ bank_end, 0xdfff
        .equ io_start, 0xe000
        .equ io_end, 0xe0ff
        .equ bios_start, 0xe100
        .equ bios_end, 0xffff

; device settings
        .equ acia_rdrf_mask, 0x1
        .equ acia_tdre_mask, 0x2
