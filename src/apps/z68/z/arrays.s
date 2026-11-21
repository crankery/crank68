; Array effective addresses are byte addresses. Arithmetic uses 17-bit story
; addresses; reads use the cache, writes are confined to resident dynamic RAM.
array_byte_address:
        clr mem_address
        ldx vm_resolved+2
        stx mem_address+1
        bra array_add_base
array_word_address:
        clr mem_address
        ldx vm_resolved+2
        stx mem_address+1
        asl mem_address+2
        rol mem_address+1
        rol mem_address
array_add_base:
        ldaa mem_address+2
        adda vm_resolved+1
        staa mem_address+2
        ldaa mem_address+1
        adca vm_resolved
        staa mem_address+1
        ldaa mem_address
        adca #0
        staa mem_address
        rts
memory_read_word:
        jsr memory_read_byte
        bcs array_done
        staa memory_word_high
        jsr memory_next
        jsr memory_read_byte
        bcs array_done
        staa vm_value+1
        ldaa memory_word_high
        staa vm_value
        clc
array_done:
        rts
memory_write_pointer:
        tst mem_address
        bne array_bad
        ldaa mem_address+1
        cmpa dynamic_size
        bhi array_bad
        bcs array_write_in_range
        ldab mem_address+2
        cmpb dynamic_size+1
        bcc array_bad
array_write_in_range:
        ldaa mem_address+1
        ldab mem_address+2
        addb #<app_end
        adca #>app_end
        staa vars_pointer_word
        stab vars_pointer_word+1
        ldx vars_pointer_word
        clc
        rts
array_bad:
        jmp vars_fault
memory_write_word:
        jsr memory_write_pointer
        bcs array_done
        ldx #app_end
        stx vars_low
        ldx dynamic_end
        stx vars_high
        jsr vars_check_word
        bcs array_done
        jmp vars_write_pointer
memory_write_byte:
        jsr memory_write_pointer
        bcs array_done
        ldaa vm_value+1
        staa 0,x
        clc
        rts
vm_do_loadb:
        jsr array_byte_address
        jsr memory_read_byte
        bcs array_read_bad
        staa vm_value+1
        clr vm_value
        jmp vm_store_result
vm_do_loadw:
        jsr array_word_address
        jsr memory_read_word
        bcs array_read_bad
        jmp vm_store_result
array_read_bad:
        jmp vm_run_error
vm_do_storeb:
        jsr array_byte_address
        ldx vm_resolved+4
        stx vm_value
        jmp memory_write_byte
vm_do_storew:
        jsr array_word_address
        ldx vm_resolved+4
        stx vm_value
        jmp memory_write_word
memory_word_high: .byte 0
