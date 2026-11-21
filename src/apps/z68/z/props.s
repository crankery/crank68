; V3 descending property lists. All table/data reads use the story memory API.
property_start:
        jsr object_property_address
        bcc 1f
        jmp property_done
1:
        jsr memory_read_byte
        bcc 1f
        jmp property_io_bad
1:
        tab
        clra
        aslb
        rola
        addb mem_address+2
        adca mem_address+1
        addb #1
        adca #0
        bcc 1f
        jmp property_bad
1:
        staa property_pointer
        stab property_pointer+1
        ldaa #32
        staa property_previous
        clc
property_done:
        rts
property_header:
        clr mem_address
        ldx property_pointer
        stx mem_address+1
        jsr memory_read_byte
        bcc 1f
        jmp property_io_bad
1:
        staa property_size
        anda #31
        staa property_number
        beq property_header_end
        cmpa property_previous
        bcs 1f
        jmp property_bad
1:
        staa property_previous
        ldaa property_size
        lsra
        lsra
        lsra
        lsra
        lsra
        inca
        staa property_size
property_header_end:
        clc
        rts
property_advance:
        ldaa property_pointer
        ldab property_pointer+1
        addb property_size
        adca #0
        addb #1
        adca #0
        bcc 1f
        jmp property_bad
1:
        staa property_pointer
        stab property_pointer+1
        rts
property_find:
        tst vm_resolved+2
        beq 1f
        jmp property_bad
1:
        ldaa vm_resolved+3
        bne 1f
        jmp property_bad
1:
        cmpa #31
        bls 1f
        jmp property_bad
1:
        jsr property_start
        bcc 1f
        jmp property_done
1:
property_find_loop:
        jsr property_header
        bcc 1f
        jmp property_done
1:
        ldaa property_number
        cmpa vm_resolved+3
        bhi 1f
        bra property_found_or_absent
1:
        jsr property_advance
        bcc 1f
        jmp property_done
1:
        bra property_find_loop
property_found_or_absent:
        clc
        rts
property_bad:
        jmp vars_fault
property_io_bad:
        jmp vm_run_error
property_data_address:
        clr mem_address
        ldx property_pointer
        stx mem_address+1
        jmp memory_next
vm_do_get_prop:
        jsr property_find
        bcc 1f
        jmp property_done
1:
        ldaa property_number
        cmpa vm_resolved+3
        bne property_default
        jsr property_data_address
        ldaa property_size
        cmpa #1
        bne property_read_word
        jsr memory_read_byte
        bcc 1f
        jmp property_io_bad
1:
        clr vm_value
        staa vm_value+1
        jmp vm_store_result
property_default:
        ldab vm_resolved+3
        decb
        clra
        aslb
        rola
        addb story_header+11
        adca story_header+10
        staa mem_address+1
        stab mem_address+2
        clr mem_address
property_read_word:
        jsr memory_read_word
        bcc 1f
        jmp property_io_bad
1:
        jmp vm_store_result
vm_do_get_prop_addr:
        jsr property_find
        bcc 1f
        rts
1:
        clr vm_value
        clr vm_value+1
        ldaa property_number
        cmpa vm_resolved+3
        bne property_addr_store
        ldx property_pointer
        inx
        stx vm_value
property_addr_store:
        jmp vm_store_result
vm_do_put_prop:
        jsr property_find
        bcc 1f
        rts
1:
        ldaa property_number
        cmpa vm_resolved+3
        beq 1f
        jmp property_bad
1:
        jsr property_data_address
        ldx vm_resolved+4
        stx vm_value
        ldaa property_size
        cmpa #1
        beq property_put_byte
        cmpa #2
        beq 1f
        jmp property_bad
1:
        jmp memory_write_word
property_put_byte:
        jmp memory_write_byte
vm_do_get_prop_len:
        clr vm_value
        clr vm_value+1
        ldaa vm_resolved
        oraa vm_resolved+1
        beq property_addr_store
        ldaa vm_resolved
        ldab vm_resolved+1
        subb #1
        sbca #0
        staa mem_address+1
        stab mem_address+2
        clr mem_address
        jsr memory_read_byte
        bcc 1f
        jmp property_io_bad
1:
        lsra
        lsra
        lsra
        lsra
        lsra
        inca
        staa vm_value+1
        jmp vm_store_result
vm_do_get_next_prop:
        tst vm_resolved+2
        beq 1f
        jmp property_bad
1:
        tst vm_resolved+3
        beq property_next_first
        jsr property_find
        bcc 1f
        rts
1:
        ldaa property_number
        cmpa vm_resolved+3
        beq 1f
        jmp property_bad
1:
        jsr property_advance
        bcc 1f
        jmp property_next_done
1:
        bra property_next_header
property_next_first:
        jsr property_start
        bcc 1f
        jmp property_next_done
1:
property_next_header:
        jsr property_header
        bcc 1f
        jmp property_next_done
1:
        clr vm_value
        ldaa property_number
        staa vm_value+1
        jmp vm_store_result
property_next_done:
        rts
property_pointer: .word 0
property_number: .byte 0
property_size: .byte 0
property_previous: .byte 0
