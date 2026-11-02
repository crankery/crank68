; Dispatch contract for the instruction decoder and execution loop.
; Set op_class (0OP=0, 1OP=1, 2OP=2, VAR=3), op_number (0..31), and
; op_pc (three-byte byte address of the instruction). story_header[0] is version.
; op_lookup returns handler in X and flags in op_flags; carry set for invalid
; group/slot/version. It never fetches operands or changes story memory.
; op_dispatch invokes the handler. Success clears carry; traps set op_halted
; and carry. quit sets vm_finished and carry. The loop closes/returns on carry.
        .equ op_store_flag, 1
        .equ op_branch_flag, 2
        .equ op_text_flag, 4
        .equ op_indirect_flag, 8
op_lookup:
        clr op_flags
        ldaa story_header
        beq op_lookup_bad
        cmpa #3
        bhi op_lookup_bad
        ldaa op_class
        cmpa #4
        bcc op_lookup_bad
        ldab op_number
        cmpb #32
        bcc op_lookup_bad
        asla
        asla
        asla
        asla
        asla
        aba
        tab
        clra
        aslb
        rola
        aslb
        rola
        addb #<opcode_tables
        adca #>opcode_tables
        staa op_descriptor
        stab op_descriptor+1
        ldx op_descriptor
        ldaa 3,x
        beq op_lookup_bad
        cmpa story_header
        bhi op_lookup_bad
        ldaa 2,x
        staa op_flags
        ldx 0,x
        clc
        rts
op_lookup_bad:
        ldx #op_invalid
        sec
        rts
op_dispatch:
        jsr op_lookup
        bcs op_invalid
        jmp 0,x
op_unimplemented:
        stx op_name_pointer
        jsr wrap_finish
        ldx #op_unimplemented_message
        jsr pstrng
        ldx op_name_pointer
        jsr op_print_string
        bra op_report_location
op_invalid:
        jsr wrap_finish
        ldx #op_invalid_message
        jsr pstrng
op_report_location:
        ldx #op_class_message
        jsr op_print_string
        ldx #op_class
        jsr print_hex_byte
        ldx #op_number_message
        jsr op_print_string
        ldx #op_number
        jsr print_hex_byte
        ldx #op_pc_message
        jsr op_print_string
        ldx #op_pc
        jsr print_hex_byte
        inx
        jsr print_hex_word
        jsr pcrlf
        ldaa #1
        staa op_halted
        sec
        rts
op_print_string:
        ldaa 0,x
        beq op_print_done
        jsr putc
        inx
        bra op_print_string
op_print_done:
        rts
op_class: .byte 0
op_number: .byte 0
op_pc: .byte 0,0,0
op_flags: .byte 0
op_halted: .byte 0
op_descriptor: .word 0
op_name_pointer: .word 0
op_unimplemented_message:
        .ascii "Z68: unimplemented opcode "
        .byte 4
op_invalid_message:
        .ascii "Z68: invalid opcode"
        .byte 4
op_class_message: .ascii " class $"
        .byte 0
op_number_message: .ascii " number $"
        .byte 0
op_pc_message: .ascii " at PC $"
        .byte 0
        .include "handlers.s"
        .include "opcodes.s"
