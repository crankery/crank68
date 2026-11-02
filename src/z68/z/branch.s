; vm_condition is Boolean. Branch suffix bytes have already been consumed.
vm_branch:
        ldaa vm_branch_first
        anda #0x80
        beq branch_on_false
        tst vm_condition
        bne branch_taken
        clc
        rts
branch_on_false:
        tst vm_condition
        beq branch_taken
        clc
        rts
branch_taken:
        ldaa vm_branch_first
        anda #0x3f
        ldab vm_branch_second
        staa branch_offset
        stab branch_offset+1
        ldaa vm_branch_first
        bita #0x40
        beq branch_long
        ldaa branch_offset
        staa branch_offset+1
        clr branch_offset
        bra branch_special
branch_long:
        ldaa branch_offset
        bita #0x20
        beq branch_special
        oraa #0xc0
        staa branch_offset
branch_special:
        tst branch_offset
        bne branch_jump
        ldaa branch_offset+1
        cmpa #1
        bhi branch_jump
        staa vm_value+1
        clr vm_value
        jmp vm_return
branch_jump:
        ; Sign-extend before adding, then subtract two in the 24-bit container.
        clr branch_sign
        tst branch_offset
        bpl branch_positive
        dec branch_sign
branch_positive:
        ldaa vm_pc+2
        adda branch_offset+1
        staa vm_pc+2
        ldaa vm_pc+1
        adca branch_offset
        staa vm_pc+1
        ldaa vm_pc
        adca branch_sign
        staa vm_pc
        ldaa vm_pc+2
        suba #2
        staa vm_pc+2
        ldaa vm_pc+1
        sbca #0
        staa vm_pc+1
        ldaa vm_pc
        sbca #0
        staa vm_pc
        cmpa #1
        bls branch_ok
        jmp vars_fault
branch_ok:
        clc
        rts
vm_do_jump:
        ldx vm_resolved
        stx branch_offset
        jmp branch_jump
vm_do_jz:
        clr vm_condition
        ldaa vm_resolved
        oraa vm_resolved+1
        beq 1f
        jmp branch_test_done
1:
        inc vm_condition
branch_test_done:
        jmp vm_branch
vm_do_je:
        clr vm_condition
        ldaa vm_operand_count
        cmpa #2
        bcs branch_bad
        cmpa #4
        bhi branch_bad
        deca
        staa branch_count
        ldx #vm_resolved+2
branch_equal_loop:
        ldaa 0,x
        cmpa vm_resolved
        bne branch_equal_next
        ldaa 1,x
        cmpa vm_resolved+1
        beq branch_equal_yes
branch_equal_next:
        inx
        inx
        dec branch_count
        bne branch_equal_loop
        jmp vm_branch
branch_equal_yes:
        inc vm_condition
        jmp vm_branch
branch_bad:
        jmp vars_fault
vm_do_jl:
        ldx vm_resolved
        stx branch_left
        ldx vm_resolved+2
        stx branch_right
        bra branch_compare
vm_do_jg:
        ldx vm_resolved+2
        stx branch_left
        ldx vm_resolved
        stx branch_right
branch_compare:
        jsr branch_less
        jmp vm_branch
branch_less:
        clr vm_condition
        ldaa branch_left+1
        suba branch_right+1
        ldaa branch_left
        sbca branch_right
        bge branch_less_done
        inc vm_condition
branch_less_done:
        rts
vm_do_test:
        clr vm_condition
        ldaa vm_resolved
        anda vm_resolved+2
        cmpa vm_resolved+2
        beq 1f
        jmp branch_test_done
1:
        ldaa vm_resolved+1
        anda vm_resolved+3
        cmpa vm_resolved+3
        beq 1f
        jmp branch_test_done
1:
        inc vm_condition
        jmp vm_branch
vm_do_dec_chk:
        jsr vars_dec_value
        bcs branch_chk_done
        ldx vm_value
        stx branch_left
        ldx vm_resolved+2
        stx branch_right
        bra branch_compare
vm_do_inc_chk:
        jsr vars_inc_value
        bcs branch_chk_done
        ldx vm_value
        stx branch_right
        ldx vm_resolved+2
        stx branch_left
        bra branch_compare
branch_chk_done:
        rts
vm_condition: .byte 0
branch_offset: .word 0
branch_sign: .byte 0
branch_left: .word 0
branch_right: .word 0
branch_count: .byte 0
