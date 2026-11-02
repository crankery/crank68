; Sixteen-bit arithmetic, wrapping modulo 65536. Resolved operands are words.
vm_do_add:
        ldaa vm_resolved
        ldab vm_resolved+1
        addb vm_resolved+3
        adca vm_resolved+2
        bra math_store
vm_do_sub:
        ldaa vm_resolved
        ldab vm_resolved+1
        subb vm_resolved+3
        sbca vm_resolved+2
        bra math_store
vm_do_and:
        ldaa vm_resolved
        anda vm_resolved+2
        ldab vm_resolved+1
        andb vm_resolved+3
        bra math_store
vm_do_or:
        ldaa vm_resolved
        oraa vm_resolved+2
        ldab vm_resolved+1
        orab vm_resolved+3
        bra math_store
vm_do_not:
        ldaa vm_resolved
        coma
        ldab vm_resolved+1
        comb
math_store:
        staa vm_value
        stab vm_value+1
        jmp vm_store_result
vm_do_mul:
        ldx vm_resolved
        stx math_left
        ldx vm_resolved+2
        stx math_right
        clr vm_value
        clr vm_value+1
        ldaa #16
        staa math_count
math_mul_loop:
        lsr math_right
        ror math_right+1
        bcc math_mul_shift
        ldaa vm_value
        ldab vm_value+1
        addb math_left+1
        adca math_left
        staa vm_value
        stab vm_value+1
math_mul_shift:
        asl math_left+1
        rol math_left
        dec math_count
        bne math_mul_loop
        jmp vm_store_result
vm_do_div:
        clr math_modulo
        bra math_divide
vm_do_mod:
        ldaa #1
        staa math_modulo
math_divide:
        ldx vm_resolved
        stx math_left
        ldx vm_resolved+2
        stx math_right
        bne math_div_nonzero
        jmp vars_fault
math_div_nonzero:
        ldaa math_left
        staa math_sign
        eora math_right
        staa math_quotient_sign
        tst math_left
        bpl math_left_positive
        ldaa math_left
        ldab math_left+1
        coma
        comb
        addb #1
        adca #0
        staa math_left
        stab math_left+1
math_left_positive:
        tst math_right
        bpl math_right_positive
        ldaa math_right
        ldab math_right+1
        coma
        comb
        addb #1
        adca #0
        staa math_right
        stab math_right+1
math_right_positive:
        clr math_remainder
        clr math_remainder+1
        ldaa #16
        staa math_count
math_div_loop:
        asl math_left+1
        rol math_left
        rol math_remainder+1
        rol math_remainder
        ldaa math_remainder
        ldab math_remainder+1
        subb math_right+1
        sbca math_right
        bcs math_div_shift
        staa math_remainder
        stab math_remainder+1
        inc math_left+1
math_div_shift:
        dec math_count
        bne math_div_loop
        tst math_modulo
        bne math_use_remainder
        ldx math_left
        stx vm_value
        ldaa math_quotient_sign
        bra math_apply_sign
math_use_remainder:
        ldx math_remainder
        stx vm_value
        ldaa math_sign
math_apply_sign:
        tsta
        bpl math_div_store
        ldaa vm_value
        ldab vm_value+1
        coma
        comb
        addb #1
        adca #0
        staa vm_value
        stab vm_value+1
math_div_store:
        jmp vm_store_result
math_left: .word 0
math_right: .word 0
math_remainder: .word 0
math_count: .byte 0
math_sign: .byte 0
math_quotient_sign: .byte 0
math_modulo: .byte 0
