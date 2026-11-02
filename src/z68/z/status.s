; Optional 80x24 VT100 status line. Row 1 is outside the scrolling region.
; All terminal bytes go through FLEX; only putc's private capture mode diverts
; decoded room names/numbers into a bounded, space-filled 80-byte line.
terminal_begin:
        clr terminal_active
        clr status_capture
        tst terminal_enabled
        beq terminal_done
        inc terminal_active
        ldx #terminal_setup
        jsr terminal_string
terminal_done:
        clc
        rts
terminal_end:
        tst terminal_active
        beq terminal_done
        clr terminal_active
        clr status_capture
        ldx #terminal_reset
        jsr terminal_string
        clc
        rts
 ; FLEX PSTRNG prefixes CR/LF. Terminal sequences must not move the cursor.
terminal_string:
        stx terminal_sequence
terminal_string_loop:
        ldx terminal_sequence
        ldaa 0,x
        cmpa #4
        beq terminal_string_done
        inx
        stx terminal_sequence
        jsr outch
        bra terminal_string_loop
terminal_string_done:
        rts
vm_do_show_status:
        tst terminal_active
        bne status_draw
        clc
        rts
status_draw:
        ldx vm_resolved
        stx status_saved_operand
        ldx vm_value
        stx status_saved_value
        ldx #status_line
        ldab #80
        ldaa #' '
status_fill:
        staa 0,x
        inx
        decb
        bne status_fill
        ldaa #1
        staa status_position
        staa status_capture
        clr status_clipped
        ldaa #48
        staa status_limit
        ldaa #16
        jsr var_read
        bcc 1f
        jmp status_failed
1:
        ldx vm_value
        stx vm_resolved
        beq status_room_done
        jsr vm_do_print_obj
        bcc 1f
        jmp status_failed
1:
status_room_done:
        tst status_clipped
        beq status_right
        ldaa #'.'
        staa status_line+45
        staa status_line+46
        staa status_line+47
status_right:
        ldaa #49
        staa status_position
        ldaa #80
        staa status_limit
        ldaa app_end+1
        bita #2
        bne status_clock
        ldx #status_score_label
        jsr status_label
        ldaa #17
        jsr status_number
        bcc 1f
        jmp status_failed
1:
        ldx #status_moves_label
        jsr status_label
        ldaa #18
        jsr status_number
        bcc 1f
        jmp status_failed
1:
        bra status_emit
status_clock:
        ldx #status_time_label
        jsr status_label
        ldaa #17
        jsr var_read
        bcc 1f
        jmp status_failed
1:
        tst vm_value
        bne status_invalid
        ldaa vm_value+1
        cmpa #23
        bhi status_invalid
        jsr status_two_digits
        ldaa #':'
        jsr putc
        ldaa #18
        jsr var_read
        bcc 1f
        jmp status_failed
1:
        tst vm_value
        bne status_invalid
        ldaa vm_value+1
        cmpa #59
        bhi status_invalid
        jsr status_two_digits
status_emit:
        clr status_capture
        ldx #terminal_status_start
        jsr terminal_string
        ldx #status_line
        stx status_emit_pointer
        ldaa #80
        staa status_emit_count
status_emit_loop:
        ldx status_emit_pointer
        ldaa 0,x
        inx
        stx status_emit_pointer
        jsr outch
        dec status_emit_count
        bne status_emit_loop
        ldx #terminal_status_end
        jsr terminal_string
        jsr status_restore
        clc
        rts
status_invalid:
        jsr vars_fault
status_failed:
        jsr status_restore
        sec
        rts
status_restore:
        clr status_capture
        ldx status_saved_operand
        stx vm_resolved
        ldx status_saved_value
        stx vm_value
        rts
status_number:
        jsr var_read
        bcs status_number_done
        ldx vm_value
        stx vm_resolved
        jsr vm_do_print_num
status_number_done:
        rts
status_two_digits:
        ldab #'0'
status_tens:
        cmpa #10
        bcs status_digits
        suba #10
        incb
        bra status_tens
status_digits:
        staa status_ones
        tba
        jsr putc
        ldaa status_ones
        adda #'0'
        jmp putc
; Labels must use putc too: FLEX PSTRNG bypasses the capture adapter.
status_label:
        stx status_label_pointer
status_label_loop:
        ldx status_label_pointer
        ldaa 0,x
        beq status_label_done
        inx
        stx status_label_pointer
        jsr putc
        bra status_label_loop
status_label_done:
        rts
; Capture hook preserves the usual console A/B/X contract. Ignore controls.
status_putc:
        psha
        pshb
        stx status_output_x
        staa status_character
        cmpa #32
        bcs status_capture_done
        cmpa #126
        bhi status_capture_done
        ldab status_position
        cmpb status_limit
        bcc status_capture_full
        ldx #status_line
status_capture_seek:
        tstb
        beq status_capture_store
        inx
        decb
        bra status_capture_seek
status_capture_store:
        ldaa status_character
        staa 0,x
        inc status_position
        bra status_capture_done
status_capture_full:
        ldaa #1
        staa status_clipped
status_capture_done:
        ldx status_output_x
        pulb
        pula
        rts
terminal_sequence: .word 0
terminal_enabled: .byte 0
terminal_active: .byte 0
status_capture: .byte 0
status_clipped: .byte 0
status_position: .byte 0
status_limit: .byte 0
status_character: .byte 0
status_ones: .byte 0
status_saved_operand: .word 0
status_saved_value: .word 0
status_output_x: .word 0
status_emit_pointer: .word 0
status_emit_count: .byte 0
status_label_pointer: .word 0
status_line: .space 80,0
terminal_setup:
        .byte 27
        .ascii "[0m"
        .byte 27
        .ascii "[2J"
        .byte 27
        .ascii "[2;24r"
        .byte 27
        .ascii "[24;1H"
        .byte 4
terminal_reset:
        .byte 27,'7',27
        .ascii "[0m"
        .byte 27
        .ascii "[r"
        .byte 27,'8',4
terminal_status_start:
        .byte 27,'7',27
        .ascii "[1;1H"
        .byte 27
        .ascii "[7m"
        .byte 4
terminal_status_end:
        .byte 27
        .ascii "[0m"
        .byte 27,'8',4
status_score_label: .ascii "Score: "
        .byte 0
status_moves_label: .ascii " Moves: "
        .byte 0
status_time_label: .ascii "Time: "
        .byte 0
