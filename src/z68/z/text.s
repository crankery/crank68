; V3 packed-string decoder. Input mem_address (17-bit byte address).
; Output to FLEX console. On success text_cursor points after the outer string.
; A/B/X clobbered, carry set on bad addresses/abbreviations or word-budget limit.
; One abbreviation frame suffices: V3 forbids abbreviations within abbreviations.
text_print:
        clr text_depth
        clr text_error
        ldx #4096
        stx text_budget
        ldaa mem_address
        staa text_cursor
        ldx mem_address+1
        stx text_cursor+1
        jsr text_reset
text_loop:
        jsr text_get_z
        bcc text_character
        tst text_error
        bne text_failed
        tst text_depth
        beq text_done
        ldaa text_abbrev
        oraa text_escape
        bne text_fail
        ; Restore the interrupted outer string, including its buffered word.
        ldx #text_saved
        stx text_copy_source
        ldx #text_state
        stx text_copy_dest
        jsr text_copy_state
        clr text_depth
        jmp text_loop
text_done:
        clc
        rts
text_fail:
        inc text_error
text_failed:
        sec
        rts
text_character:
        staa text_z
        tst text_abbrev
        beq text_no_abbreviation
        jmp text_expand
text_no_abbreviation:
        tst text_escape
        beq text_regular
        ldaa text_escape
        cmpa #1
        bne text_escape_low
        ldaa text_z
        staa text_escape_high
        inc text_escape
        jmp text_loop
text_escape_low:
        clr text_escape
        ldaa text_escape_high
        cmpa #8
        bcc text_replacement
        asla
        asla
        asla
        asla
        asla
        oraa text_z
        jsr text_emit
        jmp text_loop
text_replacement:
        ldaa #'?'
        jsr putc
        jmp text_loop
text_regular:
        ldaa text_z
        beq text_space
        cmpa #3
        bls text_abbreviation
        cmpa #5
        bls text_shift
        ldab text_alphabet
        clr text_alphabet
        cmpb #2
        beq text_punctuation
        suba #6
        adda #'a'
        tstb
        beq text_output
        suba #32
text_output:
        jsr text_emit
        jmp text_loop
text_space:
        clr text_alphabet
        ldaa #32
        bra text_output
text_shift:
        suba #3
        staa text_alphabet
        jmp text_loop
text_abbreviation:
        staa text_abbrev
        clr text_alphabet
        jmp text_loop
text_punctuation:
        cmpa #6
        bne text_punct_table
        inc text_escape
        jmp text_loop
text_punct_table:
        suba #6
        tab
        ldx #text_a2
text_punct_seek:
        tstb
        beq text_punct_out
        inx
        decb
        bra text_punct_seek
text_punct_out:
        ldaa 0,x
        bra text_output

text_expand:
        tst text_depth
        bne text_expand_fail
        ; Entry = 32*(prefix-1) + next z-char. Convert to word byte offset.
        ldaa text_abbrev
        deca
        asla
        asla
        asla
        asla
        asla
        adda text_z
        tab
        clra
        aslb
        rola
        addb story_header+25
        adca story_header+24
        staa mem_address+1
        stab mem_address+2
        clr mem_address
        clr text_abbrev
        ; Save cursor, remaining Z-chars and alphabet/escape state.
        ldx #text_state
        stx text_copy_source
        ldx #text_saved
        stx text_copy_dest
        jsr text_copy_state
        jsr memory_read_byte
        bcs text_expand_fail
        staa text_target
        jsr memory_next
        jsr memory_read_byte
        bcs text_expand_fail
        tab
        ldaa text_target
        aslb
        rola
        staa text_cursor+1
        stab text_cursor+2
        ldaa #0
        rola
        staa text_cursor
        inc text_depth
        jsr text_reset
        jmp text_loop

text_expand_fail:
        jmp text_fail

; Reset only the decoder fields, retaining the cursor.
text_reset:
        ldx #text_word
        ldab #text_state_end-text_word
text_reset_loop:
        clr 0,x
        inx
        decb
        bne text_reset_loop
        ldaa #3
        staa text_index
        rts
text_copy_state:
        ldab #text_state_end-text_state
text_copy_loop:
        ldx text_copy_source
        ldaa 0,x
        inx
        stx text_copy_source
        ldx text_copy_dest
        staa 0,x
        inx
        stx text_copy_dest
        decb
        bne text_copy_loop
        rts

; Carry set means end-of-string unless text_error is nonzero.
text_get_z:
        ldaa text_index
        cmpa #3
        bcs text_buffered
        tst text_last
        bne text_get_end
        ldaa text_budget
        oraa text_budget+1
        beq text_get_error
        ldaa text_budget
        ldab text_budget+1
        subb #1
        sbca #0
        staa text_budget
        stab text_budget+1
        jsr text_read_byte
        bcs text_get_error
        staa text_word
        anda #0x80
        staa text_last
        jsr text_read_byte
        bcs text_get_error
        staa text_word+1
        anda #31
        staa text_chars+2
        ldaa text_word
        lsra
        lsra
        anda #31
        staa text_chars
        ldaa text_word+1
        lsra
        lsra
        lsra
        lsra
        lsra
        staa text_chars+1
        ldaa text_word
        anda #3
        asla
        asla
        asla
        oraa text_chars+1
        staa text_chars+1
        clr text_index
text_buffered:
        ldab text_index
        ldx #text_chars
text_char_seek:
        tstb
        beq text_char_ready
        inx
        decb
        bra text_char_seek
text_char_ready:
        ldaa 0,x
        inc text_index
        clc
        rts
text_get_error:
        inc text_error
text_get_end:
        sec
        rts
text_read_byte:
        ldaa text_cursor
        staa mem_address
        ldx text_cursor+1
        stx mem_address+1
        jsr memory_read_byte
        bcs text_read_error
        staa text_byte
        jsr memory_next
        ldaa mem_address
        staa text_cursor
        ldx mem_address+1
        stx text_cursor+1
        ldaa text_byte
        clc
text_read_error:
        rts

; Serial terminal baseline: ASCII, null and newline. Extended/undefined ZSCII
; prints '?' rather than sending terminal control bytes. Case is preserved.
text_emit:
        tsta
        beq text_emit_done
        cmpa #13
        beq text_newline
        cmpa #32
        bcs text_emit_unknown
        cmpa #126
        bhi text_emit_unknown
        jmp putc
text_emit_unknown:
        ldaa #'?'
        jmp putc
text_newline:
        jmp pcrlf
text_emit_done:
        rts

; A small visible smoke test from the story's object table, not VM execution.
text_demo:
        ldaa story_header+10
        oraa story_header+11
        beq text_demo_done
        ldaa story_header+10
        ldab story_header+11
        addb #69                 ; 31 default words + property pointer offset 7
        adca #0
        staa demo_entry
        stab demo_entry+1
        ldaa #3
        staa demo_count
        ldx #demo_message
        jsr pstrng
        jsr pcrlf
text_demo_loop:
        clr mem_address
        ldx demo_entry
        stx mem_address+1
        jsr memory_read_byte
        bcs text_demo_error
        staa text_target
        jsr memory_next
        jsr memory_read_byte
        bcs text_demo_error
        staa mem_address+2
        ldaa text_target
        staa mem_address+1
        jsr memory_read_byte      ; property table's short-name word count
        bcs text_demo_error
        tsta
        beq text_demo_next
        jsr memory_next
        jsr text_print
        bcs text_demo_error
        jsr pcrlf
text_demo_next:
        ldaa demo_entry
        ldab demo_entry+1
        addb #9
        adca #0
        staa demo_entry
        stab demo_entry+1
        dec demo_count
        bne text_demo_loop
text_demo_done:
        clc
        rts
text_demo_error:
        ldx #text_error_message
        jsr pstrng
        jsr pcrlf
        sec
        rts

text_state:
text_cursor: .byte 0,0,0
text_word: .word 0
text_chars: .byte 0,0,0
text_index: .byte 0
text_last: .byte 0
text_alphabet: .byte 0
text_abbrev: .byte 0
text_escape: .byte 0
text_escape_high: .byte 0
text_state_end:
text_saved: .space text_state_end-text_state,0
text_depth: .byte 0
text_error: .byte 0
text_budget: .word 0
text_copy_source: .word 0
text_copy_dest: .word 0
text_z: .byte 0
text_target: .byte 0
text_byte: .byte 0
demo_entry: .word 0
demo_count: .byte 0
text_a2: .byte 0,13,48,49,50,51,52,53,54,55,56,57,46,44,33,63,95,35,39,34,47,92,45,58,40,41
demo_message:
        .ascii "Decoded object-name samples (not story execution):"
        .byte 4
text_error_message:
        .ascii "Z68: invalid or inaccessible packed text."
        .byte 4

; Optional command argument: hexadecimal byte address, or P packed-address.
; Parse the remaining FLEX line directly; accept both cases and up to 17 bits.
text_parse:
        clr vm_requested
        clr text_requested
        clr text_packed
        clr text_digits
        clr text_request
        clr text_request+1
        clr text_request+2
        ldx 0xac14
text_parse_spaces:
        ldaa 0,x
        cmpa #32
        bne text_parse_first
        inx
        bra text_parse_spaces
text_parse_run_near:
        jmp text_parse_run
text_parse_none:
        clc
        rts
text_parse_first:
        cmpa #'R'
        beq text_parse_run_near
        cmpa #'r'
        beq text_parse_run_near
        cmpa #13
        beq text_parse_none
        cmpa 0xac02
        beq text_parse_none
        anda #0xdf
        cmpa #'P'
        bne text_parse_digit
        inc text_packed
        inx
text_parse_p_spaces:
        ldaa 0,x
        cmpa #32
        bne text_parse_digit
        inx
        bra text_parse_p_spaces
text_parse_digit:
        ldaa 0,x
        cmpa #13
        beq text_parse_end
        cmpa 0xac02
        beq text_parse_end
        cmpa #32
        beq text_parse_trailing
        cmpa #'0'
        bcs text_parse_bad
        cmpa #'9'
        bls text_parse_decimal
        anda #0xdf
        cmpa #'A'
        bcs text_parse_bad
        cmpa #'F'
        bhi text_parse_bad
        suba #'A'-10
        bra text_parse_nibble
text_parse_decimal:
        suba #'0'
text_parse_nibble:
        staa text_nibble
        inc text_digits
        ldaa text_digits
        cmpa #5
        bhi text_parse_bad
        ldab #4
text_parse_shift:
        asl text_request+2
        rol text_request+1
        rol text_request
        decb
        bne text_parse_shift
        ldaa text_request+2
        oraa text_nibble
        staa text_request+2
        inx
        bra text_parse_digit
text_parse_trailing:
        inx
        ldaa 0,x
        cmpa #32
        beq text_parse_trailing
        cmpa #13
        beq text_parse_end
        cmpa 0xac02
        bne text_parse_bad
text_parse_end:
        tst text_digits
        beq text_parse_bad
        tst text_packed
        beq text_parse_bound
        ldaa text_digits
        cmpa #4
        bhi text_parse_bad
        asl text_request+2
        rol text_request+1
        rol text_request
text_parse_bound:
        ldaa text_request
        cmpa #1
        bhi text_parse_bad
        inc text_requested
text_parse_empty:
        clc
        rts
text_parse_bad:
        ldx #text_usage
        jsr pstrng
        sec
        rts
text_run:
        tst text_requested
        bne text_run_requested
        jmp text_demo
text_run_requested:
        ldx #text_preview_message
        jsr pstrng
        jsr pcrlf
        ldaa text_request
        staa mem_address
        ldx text_request+1
        stx mem_address+1
        jsr text_print
        bcc text_run_done
        jmp text_demo_error
text_run_done:
        jmp pcrlf
text_requested: .byte 0
text_packed: .byte 0
text_digits: .byte 0
text_nibble: .byte 0
text_request: .byte 0,0,0
text_usage:
        .ascii "Usage: Z68 story [hex-byte-address | P hex-packed-address]"
        .byte 4
text_preview_message:
        .ascii "Decoded text (not story execution):"
        .byte 4

; RUN is a separate explicit action; plain invocations still inspect text.
text_parse_run:
        ldaa 1,x
        anda #0xdf
        cmpa #'U'
        bne text_parse_run_bad
        ldaa 2,x
        anda #0xdf
        cmpa #'N'
        bne text_parse_run_bad
        inx
        inx
        inx
text_parse_run_end:
        ldaa 0,x
        cmpa #32
        bne text_parse_run_terminator
        inx
        bra text_parse_run_end
text_parse_run_terminator:
        cmpa #13
        beq text_parse_run_ok
        cmpa 0xac02
        bne text_parse_run_bad
text_parse_run_ok:
        inc vm_requested
        clc
        rts
text_parse_run_bad:
        jmp text_parse_bad
vm_requested: .byte 0
