vm_do_print_addr:
        clr mem_address
        ldx vm_resolved
        stx mem_address+1
        bra output_string
vm_do_print_paddr:
        clr mem_address
        ldx vm_resolved
        stx mem_address+1
        asl mem_address+2
        rol mem_address+1
        rol mem_address
output_string:
        jsr text_print
        bcc output_done
        jmp vm_run_error
output_done:
        rts
vm_do_print_ret:
        jsr vm_do_print
        bcs output_done
        jsr story_newline
        jmp vm_do_rtrue
vm_do_print_char:
        tst vm_resolved
        bne output_character_unknown
        ldaa vm_resolved+1
        jsr text_emit
        clc
        rts
output_character_unknown:
        ldaa #'?'
        jsr putc
        clc
        rts
vm_do_print_num:
        ldx vm_resolved
        stx output_number
        clr output_started
        tst output_number
        bpl output_decimal_start
        ldaa #'-'
        jsr putc
        ldaa output_number
        ldab output_number+1
        coma
        comb
        addb #1
        adca #0
        staa output_number
        stab output_number+1
output_decimal_start:
        ldx #output_divisors
        stx output_divisor_pointer
        ldaa #5
        staa output_places
output_decimal_place:
        ldx output_divisor_pointer
        ldx 0,x
        stx output_divisor
        clr output_digit
output_decimal_subtract:
        ldaa output_number
        ldab output_number+1
        subb output_divisor+1
        sbca output_divisor
        bcs output_decimal_emit
        staa output_number
        stab output_number+1
        inc output_digit
        bra output_decimal_subtract
output_decimal_emit:
        ldaa output_digit
        bne output_decimal_show
        tst output_started
        bne output_decimal_show
        ldab output_places
        cmpb #1
        bne output_decimal_next
output_decimal_show:
        adda #'0'
        jsr putc
        inc output_started
output_decimal_next:
        ldx output_divisor_pointer
        inx
        inx
        stx output_divisor_pointer
        dec output_places
        bne output_decimal_place
        clc
        rts
output_divisors: .word 10000,1000,100,10,1
output_number: .word 0
output_divisor: .word 0
output_divisor_pointer: .word 0
output_places: .byte 0
output_digit: .byte 0
output_started: .byte 0
