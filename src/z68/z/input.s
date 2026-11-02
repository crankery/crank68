; V3 sread: validate, capture text, tokenize into the parse buffer, then resume.
vm_do_sread:
        clr vm_input_requested
        clr vm_input_complete
        jsr input_prepare_text
        bcs input_sread_done
        jsr dict_prepare
        bcs input_sread_done
        jsr wrap_flush
        jsr vm_do_show_status
        bcs input_sread_done
        ldaa #1
        staa vm_input_requested
        ldaa input_text_capacity
        jsr input_read_line
        jsr input_store_text
        jsr dict_tokenize
        bcs input_sread_done
        clr vm_input_requested
        ldaa #1
        staa vm_input_complete
        ldx #30000
        stx vm_budget
        clc
input_sread_done:
        rts

; Validate the entire V3 text buffer before reading console input or writing.
; Byte 0=n: n-1 characters fit at byte 1, followed by NUL (total n+1 bytes).
; Return A=capacity; save the story address and mapped first-character pointer.
input_prepare_text:
        ldaa vm_operand_count
        cmpa #2
        bne input_text_bad
        ldaa vm_resolved
        bne input_text_start_ok
        ldab vm_resolved+1
        cmpb #64
        bcs input_text_bad
input_text_start_ok:
        ldx vm_resolved
        stx input_text_address
        stx mem_address+1
        clr mem_address
        jsr memory_write_pointer
        bcs input_sread_done
        ldaa 0,x
        cmpa #2
        bcs input_text_bad
        staa input_text_capacity
        inx
        stx input_text_pointer
        ldab input_text_address+1
        addb input_text_capacity
        ldaa input_text_address
        adca #0
        bcs input_text_bad
        staa mem_address+1
        stab mem_address+2
        ; The last byte (the furthest possible terminator) must be writable.
        jsr memory_write_pointer
        bcs input_sread_done
        ldx mem_address+1
        stx input_text_end
        dec input_text_capacity
        ldaa input_text_capacity
        clc
        rts
input_text_bad:
        ldaa #1
        staa op_halted
        ldx #input_text_error
        jsr pstrng
        jsr pcrlf
        sec
        rts

; Both mappings are private pointers; full destination extent was checked above.
; Copy the captured bytes and NUL, leaving byte 0 and unused tail unchanged.
input_store_text:
        ldx #input_buffer
        stx input_copy_source
        ldaa input_length
        inca
        staa input_copy_remaining
input_store_text_loop:
        ldx input_copy_source
        ldaa 0,x
        inx
        stx input_copy_source
        ldx input_text_pointer
        staa 0,x
        inx
        stx input_text_pointer
        dec input_copy_remaining
        bne input_store_text_loop
        clc
        rts

; input_read_line: A=max accepted characters (0..255).
; Result: input_buffer is NUL-terminated lowercase ASCII; input_length and B
; hold its length, carry clear. A/X clobbered. Buffer owns 256 bytes.
; Echo preserves typed case. BS/DEL erase one character; other controls are
; ignored. At capacity printable characters ring BEL and are discarded until
; editing makes room or Enter arrives. CR or LF ends the line. A following LF
; after CR is swallowed on the next call, so CRLF doesn't create an empty line.
input_read_line:
        staa input_limit
        clr input_length
        clr input_buffer
        ldx #input_buffer
        stx input_pointer
input_read_next:
        jsr getc
        staa input_character
        tst input_skip_lf
        beq input_process
        clr input_skip_lf
        cmpa #10
        beq input_read_next
input_process:
        cmpa #13
        beq input_finish_cr
        cmpa #10
        beq input_finish
        cmpa #8
        beq input_backspace
        cmpa #127
        beq input_backspace
        cmpa #32
        bcs input_read_next
        cmpa #126
        bhi input_read_next
        ldab input_length
        cmpb input_limit
        bcc input_full
        cmpa #'A'
        bcs input_store
        cmpa #'Z'
        bhi input_store
        adda #32
input_store:
        ldx input_pointer
        staa 0,x
        inx
        clr 0,x
        stx input_pointer
        inc input_length
        ldaa input_character
        jsr outch
        bra input_read_next
input_full:
        ldaa #7
        jsr outch
        bra input_read_next
input_backspace:
        tst input_length
        beq input_read_next
        dec input_length
        ldx input_pointer
        dex
        clr 0,x
        stx input_pointer
        ldaa #8
        jsr outch
        ldaa #' '
        jsr outch
        ldaa #8
        jsr outch
        bra input_read_next
input_finish_cr:
        ldaa #1
        staa input_skip_lf
input_finish:
        jsr pcrlf
        clr wrap_column
        ldab input_length
        clc
        rts
vm_input_requested: .byte 0
vm_input_complete: .byte 0
input_length: .byte 0
input_limit: .byte 0
input_character: .byte 0
input_skip_lf: .byte 0
input_pointer: .word 0
input_buffer: .space 256,0
input_text_address: .word 0
input_text_end: .word 0
input_text_pointer: .word 0
input_text_capacity: .byte 0
input_copy_source: .word 0
input_copy_remaining: .byte 0
input_text_error:
        .ascii "Z68: invalid V3 text buffer."
        .byte 4
