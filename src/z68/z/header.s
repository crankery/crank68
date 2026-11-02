; Z-machine Standard 1.1 section 11: read the 64-byte header, big-endian words.
; Version 3 header validation and metadata reporting; loading is in memory.s.
header_read:
        ldx #story_header
        stx header_pointer
        ldaa #64
        staa header_count
header_read_loop:
        jsr story_read_byte
        bcs header_io_failed
        ldx header_pointer
        staa 0,x
        inx
        stx header_pointer
        dec header_count
        bne header_read_loop
        ldaa story_header
        cmpa #3
        bne header_unsupported
        ; Static memory starts at the end of writable (dynamic) memory.
        ldaa story_header+14
        bne header_dynamic_ok
        ldab story_header+15
        cmpb #64
        bcs header_invalid
header_dynamic_ok:
        ; Unsigned comparisons by bytes: MC6800 CPX does not set carry.
        ldaa story_header+4
        cmpa story_header+14
        bcs header_invalid
        bhi header_high_ok
        ldab story_header+5
        cmpb story_header+15
        bcs header_invalid
header_high_ok:
        ldaa story_header+6
        cmpa story_header+4
        bcs header_invalid
        bhi header_layout_ok
        ldab story_header+7
        cmpb story_header+5
        bcs header_invalid
header_layout_ok:
        clc
        rts
header_io_failed:
        ldx #read_message
        jsr io_report
        sec
        rts
header_unsupported:
        ldx #version_message
        jsr pstrng
        ldx #story_header
        jsr print_hex_byte
        jsr pcrlf
        sec
        rts
header_invalid:
        ldx #invalid_message
        jsr pstrng
        sec
        rts
header_report:
        ldx #title_message
        jsr pstrng
        ldx #release_message
        jsr pstrng
        ldx #story_header+2
        jsr print_hex_word
        ldx #serial_message
        jsr pstrng
        ldx #story_header+18
        stx serial_pointer
        ldaa #6
        staa serial_count
serial_loop:
        ldx serial_pointer
        ldaa 0,x
        inx
        stx serial_pointer
        cmpa #32
        bcs serial_bad
        cmpa #126
        bls serial_out
serial_bad:
        ldaa #'?'
serial_out:
        jsr putc
        dec serial_count
        bne serial_loop
        ldx #length_message
        jsr pstrng
        ; V3 length is in two-byte units. Print a full 17-bit byte count.
        ldaa story_header+26
        ldab story_header+27
        staa length_word
        stab length_word+1
        clr length_high
        aslb
        rola
        rol length_high
        staa length_word
        stab length_word+1
        ldx #length_high
        jsr print_hex_byte
        ldx #length_word
        jsr print_hex_word
        ldx #dynamic_message
        jsr pstrng
        ldx #story_header+14
        jsr print_hex_word
        ldx #high_message
        jsr pstrng
        ldx #story_header+4
        jsr print_hex_word
        ldx #pc_message
        jsr pstrng
        ldx #story_header+6
        jsr print_hex_word
        ldx #budget_message
        jsr pstrng
        ldx #ram_budget
        jsr print_hex_word
        jmp pcrlf
length_high: .byte 0
length_word: .word 0
read_message:
        .ascii "Z68: cannot read header; FLEX error $"
        .byte 4
version_message:
        .ascii "Z68: only V3 is supported; header version $"
        .byte 4
invalid_message:
        .ascii "Z68: invalid V3 memory layout."
        .byte 4
title_message:
        .ascii "Z68: V3 story header"
        .byte 4
release_message:
        .ascii "Release: $"
        .byte 4
serial_message:
        .ascii "Serial: "
        .byte 4
length_message:
        .ascii "Declared story bytes (zero=unknown): $"
        .byte 4
dynamic_message:
        .ascii "Dynamic bytes: $"
        .byte 4
high_message:
        .ascii "High memory: $"
        .byte 4
pc_message:
        .ascii "Initial PC: $"
        .byte 4
budget_message:
        .ascii "Dynamic RAM capacity (after all reservations): $"
        .byte 4
