; Streaming 80-column story word wrapping. Words survive print-op boundaries;
; spaces are deferred until the next word is known to fit. Only overlong words
; are split. Raw terminal/status/input output bypasses this path.
wrap_begin:
        ldaa #1
        staa wrap_enabled
        clr wrap_column
        clr wrap_length
        clr wrap_spaces
        rts
wrap_finish:
        jsr wrap_flush
        clr wrap_enabled
        rts
wrap_flush:
        tst wrap_enabled
        bne 1f
        rts
1:
        jsr wrap_word_flush
        jsr wrap_space_flush
wrap_done:
        rts
story_newline:
        tst wrap_enabled
        beq wrap_plain_newline
        jsr wrap_flush
        clr wrap_column
wrap_plain_newline:
        jmp pcrlf

; Preserve console A/B/X while accepting a printable character from putc.
wrap_putc:
        psha
        pshb
        stx wrap_saved_x
        staa wrap_character
        cmpa #' '
        beq wrap_accept_space
        ldaa wrap_length
        cmpa #80
        bcs wrap_append
        jsr wrap_word_flush
wrap_append:
        ldx #wrap_word
        ldab wrap_length
wrap_append_seek:
        tstb
        beq wrap_append_here
        inx
        decb
        bra wrap_append_seek
wrap_append_here:
        ldaa wrap_character
        staa 0,x
        inc wrap_length
        bra wrap_putc_done
wrap_accept_space:
        jsr wrap_word_flush
        ldaa wrap_spaces
        cmpa #80
        bcs wrap_space_room
        jsr wrap_space_flush
wrap_space_room:
        inc wrap_spaces
wrap_putc_done:
        ldx wrap_saved_x
        pulb
        pula
        rts

wrap_word_flush:
        tst wrap_length
        bne 1f
        rts
1:
        ldaa wrap_column
        adda wrap_spaces
        adda wrap_length
        cmpa #80
        bls wrap_word_fits
        tst wrap_column
        beq wrap_drop_spaces
        jsr pcrlf
        clr wrap_column
wrap_drop_spaces:
        clr wrap_spaces
wrap_word_fits:
        jsr wrap_space_flush
        ldx #wrap_word
        stx wrap_emit_pointer
        ldaa wrap_length
        staa wrap_emit_remaining
wrap_emit_loop:
        ldx wrap_emit_pointer
        ldaa 0,x
        inx
        stx wrap_emit_pointer
        jsr outch
        inc wrap_column
        dec wrap_emit_remaining
        bne wrap_emit_loop
        clr wrap_length
        rts
wrap_space_flush:
        tst wrap_spaces
        bne 1f
        rts
1:
wrap_space_loop:
        ldaa wrap_column
        cmpa #80
        bcs wrap_emit_space
        jsr pcrlf
        clr wrap_column
wrap_emit_space:
        ldaa #' '
        jsr outch
        inc wrap_column
        dec wrap_spaces
        bne wrap_space_loop
        rts
wrap_enabled: .byte 0
wrap_column: .byte 0
wrap_length: .byte 0
wrap_spaces: .byte 0
wrap_character: .byte 0
wrap_saved_x: .word 0
wrap_emit_pointer: .word 0
wrap_emit_remaining: .byte 0
wrap_word: .space 80,0
