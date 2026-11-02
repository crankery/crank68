; V1-3 instruction decoder. Raw operands/types are retained for future
; left-to-right variable resolution. Only metadata-defined suffixes are fetched.
; vm_pc points after the decoded instruction (or at inline text). Carry=error.
vm_fetch:
        ldaa vm_pc
        staa mem_address
        ldx vm_pc+1
        stx mem_address+1
        jsr memory_read_byte
        bcs vm_fetch_done
        staa vm_byte
        jsr memory_next
        ldaa mem_address
        staa vm_pc
        ldx mem_address+1
        stx vm_pc+1
        ldaa vm_byte
        clc
vm_fetch_done:
        rts
vm_decode_early_bad:
        sec
        rts
vm_decode:
        ldaa vm_pc
        staa op_pc
        ldx vm_pc+1
        stx op_pc+1
        clr vm_operand_count
        clr vm_store_variable
        clr vm_branch_first
        clr vm_branch_second
        ldx #vm_operands
        ldab #12
vm_clear_operands:
        clr 0,x
        inx
        decb
        bne vm_clear_operands
        jsr vm_fetch
        bcs vm_decode_early_bad
        staa vm_raw_opcode
        cmpa #0x80
        bcs vm_long
        cmpa #0xc0
        bcc vm_variable
        anda #15
        staa op_number
        ldaa vm_raw_opcode
        lsra
        lsra
        lsra
        lsra
        anda #3
        cmpa #3
        beq vm_zero
        staa vm_current_type
        ldaa #1
        staa op_class
        jsr vm_decode_operand
        bcs vm_decode_early_bad
        jmp vm_suffix
vm_zero:
        clr op_class
        jmp vm_suffix
vm_decode_mid_bad:
        sec
        rts
vm_long:
        anda #31
        staa op_number
        ldaa #2
        staa op_class
        ldaa vm_raw_opcode
        anda #0x40
        jsr vm_long_type
        jsr vm_decode_operand
        bcs vm_decode_mid_bad
        ldaa vm_raw_opcode
        anda #0x20
        jsr vm_long_type
        jsr vm_decode_operand
        bcs vm_decode_mid_bad
        jmp vm_suffix
vm_long_type:
        tsta
        beq vm_long_small
        ldaa #2
        staa vm_current_type
        rts
vm_long_small:
        ldaa #1
        staa vm_current_type
        rts
vm_variable:
        anda #31
        staa op_number
        ldaa vm_raw_opcode
        anda #0x20
        beq vm_variable_2op
        ldaa #3
        bra vm_variable_class
vm_variable_2op:
        ldaa #2
vm_variable_class:
        staa op_class
        jsr vm_fetch
        bcs vm_decode_bad
        staa vm_type_bits
        ldaa #4
        staa vm_types_remaining
vm_type_loop:
        ldaa vm_type_bits
        lsra
        lsra
        lsra
        lsra
        lsra
        lsra
        staa vm_current_type
        cmpa #3
        beq vm_suffix
        jsr vm_decode_operand
        bcs vm_decode_bad
        asl vm_type_bits
        asl vm_type_bits
        dec vm_types_remaining
        bne vm_type_loop
vm_suffix:
        jsr op_lookup
        bcs vm_decode_bad
        ldaa op_flags
        bita #op_store_flag
        beq vm_branch_suffix
        jsr vm_fetch
        bcs vm_decode_bad
        staa vm_store_variable
vm_branch_suffix:
        ldaa op_flags
        bita #op_branch_flag
        beq vm_decode_ok
        jsr vm_fetch
        bcs vm_decode_bad
        staa vm_branch_first
        bita #0x40
        bne vm_decode_ok
        jsr vm_fetch
        bcs vm_decode_bad
        staa vm_branch_second
vm_decode_ok:
        clc
        rts
vm_decode_bad:
        sec
        rts
vm_decode_operand:
        clr vm_operand_hi
        tst vm_current_type
        bne vm_operand_byte
        jsr vm_fetch
        bcs vm_operand_bad
        staa vm_operand_hi
vm_operand_byte:
        jsr vm_fetch
        bcs vm_operand_bad
        staa vm_operand_lo
        ldab vm_operand_count
        ldx #vm_operand_types
vm_type_seek:
        tstb
        beq vm_type_store
        inx
        decb
        bra vm_type_seek
vm_type_store:
        ldaa vm_current_type
        staa 0,x
        ldx #vm_operands
        ldab vm_operand_count
        aslb
vm_operand_seek:
        tstb
        beq vm_operand_store
        inx
        decb
        bra vm_operand_seek
vm_operand_store:
        ldaa vm_operand_hi
        staa 0,x
        ldaa vm_operand_lo
        staa 1,x
        inc vm_operand_count
        clc
        rts
vm_operand_bad:
        sec
        rts
vm_pc: .byte 0,0,0
vm_byte: .byte 0
vm_raw_opcode: .byte 0
vm_operand_count: .byte 0
vm_current_type: .byte 0
vm_type_bits: .byte 0
vm_types_remaining: .byte 0
vm_operand_hi: .byte 0
vm_operand_lo: .byte 0
vm_store_variable: .byte 0
vm_branch_first: .byte 0
vm_branch_second: .byte 0
vm_operands: .space 8,0
vm_operand_types: .space 4,0
