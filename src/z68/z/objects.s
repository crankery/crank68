; V3 objects: 62-byte defaults table followed by nine-byte entries.
object_first:
        tst vm_resolved
        beq 1f
        jmp object_bad
1:
        ldaa vm_resolved+1
object_address:
        tsta
        bne 1f
        jmp object_bad
1:
        staa object_id
        deca
        tab
        clra
        staa object_offset
        stab object_offset+1
        aslb
        rola
        aslb
        rola
        aslb
        rola
        addb object_offset+1
        adca object_offset
        addb story_header+11
        adca story_header+10
        bcc 1f
        jmp object_bad
1:
        addb #62
        adca #0
        bcc 1f
        jmp object_bad
1:
        addb #<app_end
        adca #>app_end
        bcc 1f
        jmp object_bad
1:
        staa object_pointer
        stab object_pointer+1
        staa vars_pointer_word
        stab vars_pointer_word+1
        ldx #app_end
        stx vars_low
        ldx dynamic_end
        stx vars_high
        jsr vars_check_word
        bcc 1f
        jmp object_done
1:
        ldaa object_pointer
        ldab object_pointer+1
        addb #7
        adca #0
        staa vars_pointer_word
        stab vars_pointer_word+1
        jsr vars_check_word
        bcc 1f
        jmp object_done
1:
        ldx object_pointer
        clc
object_done:
        rts
object_bad:
        jmp vars_fault
vm_do_get_parent:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        ldaa 4,x
        bra object_result
vm_do_get_child:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        ldaa 6,x
        bra object_store_branch
vm_do_get_sibling:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        ldaa 5,x
object_store_branch:
        clr vm_condition
        tsta
        beq object_branch_zero
        inc vm_condition
object_branch_zero:
        jsr object_result
        bcc 1f
        jmp object_done
1:
        jmp vm_branch
object_result:
        staa vm_value+1
        clr vm_value
        jmp vm_store_result
vm_do_jin:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        clr vm_condition
        tst vm_resolved+2
        beq 1f
        jmp object_jin_done
1:
        ldaa 4,x
        cmpa vm_resolved+3
        beq 1f
        jmp object_jin_done
1:
        inc vm_condition
object_jin_done:
        jmp vm_branch
object_attribute:
        tst vm_resolved+2
        beq 1f
        jmp object_bad
1:
        ldaa vm_resolved+3
        cmpa #31
        bls 1f
        jmp object_bad
1:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        ldab vm_resolved+3
        lsrb
        lsrb
        lsrb
object_attr_byte:
        tstb
        beq object_attr_mask
        inx
        decb
        bra object_attr_byte
object_attr_mask:
        stx object_attr_pointer
        ldab vm_resolved+3
        andb #7
        ldaa #0x80
object_attr_shift:
        tstb
        beq object_attr_ready
        lsra
        decb
        bra object_attr_shift
object_attr_ready:
        staa object_mask
        clc
        rts
vm_do_test_attr:
        jsr object_attribute
        bcc 1f
        jmp object_done
1:
        clr vm_condition
        ldaa 0,x
        anda object_mask
        bne 1f
        jmp object_attr_test_done
1:
        inc vm_condition
object_attr_test_done:
        jmp vm_branch
vm_do_set_attr:
        jsr object_attribute
        bcc 1f
        jmp object_done
1:
        ldaa 0,x
        oraa object_mask
        staa 0,x
        clc
        rts
vm_do_clear_attr:
        jsr object_attribute
        bcc 1f
        jmp object_done
1:
        ldaa object_mask
        coma
        anda 0,x
        staa 0,x
        clc
        rts
object_property_address:
        jsr object_first
        bcc 1f
        jmp object_done
1:
        ldx 7,x
        stx mem_address+1
        clr mem_address
        clc
        rts
vm_do_print_obj:
        jsr object_property_address
        bcc 1f
        jmp object_done
1:
        jsr memory_read_byte
        bcc 1f
        jmp object_text_bad
1:
        tsta
        beq object_print_empty
        jsr memory_next
        jsr text_print
        bcc 1f
        jmp object_text_bad
1:
object_print_empty:
        clc
        rts
object_text_bad:
        jmp vm_run_error
object_id: .byte 0
object_offset: .word 0
object_pointer: .word 0
object_attr_pointer: .word 0
object_mask: .byte 0

vm_do_remove_obj:
        jmp tree_detach
vm_do_insert_obj:
        tst vm_resolved+2
        bne tree_bad
        ldaa vm_resolved+3
        beq tree_bad
        staa tree_destination
        ldaa #255
        staa tree_budget
        ; Reject insertion into self or a descendant before changing links.
        ldaa tree_destination
 tree_ancestor_loop:
        cmpa vm_resolved+1
        beq tree_bad
        jsr object_address
        bcs tree_done
        ldaa 4,x
        beq tree_insert_valid
        dec tree_budget
        bne tree_ancestor_loop
        bra tree_bad
 tree_insert_valid:
        ldaa tree_destination
        jsr object_address
        bcs tree_done
        stx tree_destination_pointer
        jsr tree_detach
        bcs tree_done
        ldx tree_destination_pointer
        ldaa 6,x
        staa tree_old_child
        ldaa tree_target
        staa 6,x
        ldx tree_target_pointer
        ldaa tree_destination
        staa 4,x
        ldaa tree_old_child
        staa 5,x
        clc
 tree_done:
        rts
 tree_bad:
        jmp vars_fault
 tree_detach:
        jsr object_first
        bcs tree_done
        stx tree_target_pointer
        ldaa vm_resolved+1
        staa tree_target
        ldaa 5,x
        staa tree_old_sibling
        ldaa 4,x
        beq tree_clear_links
        jsr object_address
        bcs tree_done
        ldaa 6,x
        cmpa tree_target
        bne tree_seek_sibling
        ldaa tree_old_sibling
        staa 6,x
        bra tree_clear_links
 tree_seek_sibling:
        ldaa #255
        staa tree_budget
        ldaa 6,x
 tree_sibling_loop:
        tsta
        beq tree_bad
        jsr object_address
        bcs tree_done
        ldaa 5,x
        cmpa tree_target
        beq tree_replace_sibling
        dec tree_budget
        bne tree_sibling_loop
        bra tree_bad
 tree_replace_sibling:
        ldaa tree_old_sibling
        staa 5,x
 tree_clear_links:
        ldx tree_target_pointer
        clr 4,x
        clr 5,x
        clc
        rts
 tree_target: .byte 0
 tree_target_pointer: .word 0
 tree_old_sibling: .byte 0
 tree_destination: .byte 0
 tree_destination_pointer: .word 0
 tree_old_child: .byte 0
 tree_budget: .byte 0
