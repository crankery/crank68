; Verify original on-disk bytes [64, declared length), never mutated dynamic RAM.
vm_do_verify:
        clr vm_condition
        clr verify_sum
        clr verify_sum+1
        clr verify_end
        ldx story_header+26
        stx verify_end+1
        asl verify_end+2
        rol verify_end+1
        rol verify_end
        ldaa verify_end
        oraa verify_end+1
        oraa verify_end+2
        beq verify_false
        clr mem_address
        clr mem_address+1
        ldaa #64
        staa mem_address+2
verify_loop:
        ldaa mem_address
        cmpa verify_end
        bcs verify_read
        bhi verify_false
        ldaa mem_address+1
        cmpa verify_end+1
        bcs verify_read
        bhi verify_false
        ldaa mem_address+2
        cmpa verify_end+2
        bcc verify_compare
verify_read:
        jsr memory_static
        bcs verify_false
        adda verify_sum+1
        staa verify_sum+1
        ldaa verify_sum
        adca #0
        staa verify_sum
        jsr memory_next
        bra verify_loop
verify_compare:
        ldaa verify_sum
        cmpa story_header+28
        bne verify_false
        ldaa verify_sum+1
        cmpa story_header+29
        bne verify_false
        inc vm_condition
verify_false:
        jmp vm_branch
verify_end: .space 3,0
verify_sum: .word 0
