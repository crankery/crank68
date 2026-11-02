; V3 dictionary and parse buffer. Story reads use the common cached byte API.
; dict_prepare validates metadata/destinations before console input is consumed.
; dict_tokenize uses input_buffer/input_length and writes four-byte parse entries.
dict_prepare:
        ldx vm_resolved+2
        stx dict_parse_address
        ldaa vm_resolved+2
        bne dict_parse_start
        ldab vm_resolved+3
        cmpb #64
        bcc dict_parse_start
        jmp dict_error
dict_parse_start:
        clr mem_address
        stx mem_address+1
        jsr memory_write_pointer
        bcc 1f
        rts
1:
        stx dict_parse_host
        ldaa 0,x
        bne 1f
        jmp dict_error_near
1:
        ; Early Infocom/Inform buffers use legacy 120/240 length fields.
        ; Cap these at 59 records (238 bytes), preserving the original field.
        cmpa #120
        beq dict_parse_legacy
        cmpa #240
        bne dict_parse_capacity
dict_parse_legacy:
        ldaa #59
dict_parse_capacity:
        staa dict_parse_limit
        tab
        clra
        aslb
        rola
        aslb
        rola
        addb #1
        adca #0
        addb dict_parse_address+1
        adca dict_parse_address
        bcc 1f
        jmp dict_error_near
1:
        staa dict_parse_end
        stab dict_parse_end+1
        staa mem_address+1
        stab mem_address+2
        jsr memory_write_pointer
        bcc 1f
        rts
1:
        ; Full text and parse extents must not overlap.
        ldaa dict_parse_end
        cmpa input_text_address
        bcs dict_parse_separate
        bhi dict_parse_after
        ldab dict_parse_end+1
        cmpb input_text_address+1
        bcs dict_parse_separate
dict_parse_after:
        ldaa dict_parse_address
        cmpa input_text_end
        bhi dict_parse_separate
        bcc 1f
        jmp dict_error_near
1:
        ldab dict_parse_address+1
        cmpb input_text_end+1
        bhi dict_parse_separate
dict_error_near:
        jmp dict_error
dict_parse_separate:
        ldx story_header+8
        stx mem_address+1
        clr mem_address
        jsr dict_fetch
        bcc 1f
        jmp dict_prepare_done
1:
        staa dict_separator_count
        ldx mem_address+1
        stx dict_separators
        ldab dict_separator_count
        addb mem_address+2
        ldaa mem_address+1
        adca #0
        staa mem_address+1
        stab mem_address+2
        ldaa mem_address
        adca #0
        staa mem_address
        jsr dict_fetch
        bcc 1f
        jmp dict_prepare_done
1:
        cmpa #4
        bcc 1f
        jmp dict_error_near
1:
        staa dict_entry_length
        jsr dict_fetch
        bcc 1f
        jmp dict_prepare_done
1:
        tsta
        bpl 1f
        jmp dict_error_near
1:
        staa dict_entry_count
        jsr dict_fetch
        bcc 1f
        jmp dict_prepare_done
1:
        staa dict_entry_count+1
        tst mem_address
        beq 1f
        jmp dict_error_near
1:
        ldx mem_address+1
        stx dict_entries
        ldx dict_entry_count
        stx dict_index
        jsr dict_index_address
        ldaa mem_address
        beq dict_table_end_ok
        cmpa #1
        beq 1f
        jmp dict_error_near
1:
        ldaa mem_address+1
        oraa mem_address+2
        beq 1f
        jmp dict_error_near
1:
dict_table_end_ok:
        ldx dict_entry_count
        beq dict_prepare_ok
        ldaa mem_address+2
        suba #1
        staa mem_address+2
        ldaa mem_address+1
        sbca #0
        staa mem_address+1
        ldaa mem_address
        sbca #0
        staa mem_address
        jsr memory_read_byte
        bcc 1f
        jmp dict_error_near
1:
dict_prepare_ok:
        clc
dict_prepare_done:
        rts

; Read a byte and advance the 17-bit cursor, returning A and carry clear.
dict_fetch:
        jsr memory_read_byte
        bcs dict_fetch_bad
        psha
        jsr memory_next
        pula
        clc
        rts
dict_fetch_bad:
        jmp dict_error

; mem_address = entries + dict_index * entry_length, without 16-bit truncation.
dict_index_address:
        clr mem_address
        clr mem_address+1
        clr mem_address+2
        clr dict_multiplicand
        ldx dict_index
        stx dict_multiplicand+1
        ldaa dict_entry_length
        staa dict_multiplier
        ldaa #8
        staa dict_multiply_bits
dict_multiply_loop:
        lsr dict_multiplier
        bcc dict_multiply_shift
        ldaa mem_address+2
        adda dict_multiplicand+2
        staa mem_address+2
        ldaa mem_address+1
        adca dict_multiplicand+1
        staa mem_address+1
        ldaa mem_address
        adca dict_multiplicand
        staa mem_address
dict_multiply_shift:
        asl dict_multiplicand+2
        rol dict_multiplicand+1
        rol dict_multiplicand
        dec dict_multiply_bits
        bne dict_multiply_loop
        ldaa mem_address+2
        adda dict_entries+1
        staa mem_address+2
        ldaa mem_address+1
        adca dict_entries
        staa mem_address+1
        ldaa mem_address
        adca #0
        staa mem_address
        rts

; Encode the token into six Z-characters (two packed words), truncating/padding.
dict_encode:
        ldx #dict_zchars
        ldab #6
        ldaa #5
dict_encode_pad:
        staa 0,x
        inx
        decb
        bne dict_encode_pad
        clr dict_zcount
        ldaa dict_word_start
        staa dict_encode_position
        ldaa dict_word_length
        staa dict_encode_remaining
dict_encode_loop:
        tst dict_encode_remaining
        bne 1f
        jmp dict_pack
1:
        ldaa dict_zcount
        cmpa #6
        bcs 1f
        jmp dict_pack
1:
        ldx #input_buffer
        ldab dict_encode_position
dict_encode_seek:
        tstb
        beq dict_encode_character
        inx
        decb
        jmp dict_encode_seek
dict_encode_character:
        ldaa 0,x
        staa dict_encode_char
        inc dict_encode_position
        dec dict_encode_remaining
        cmpa #32
        beq dict_encode_space
        cmpa #'a'
        bcs dict_encode_punct
        cmpa #'z'
        bhi dict_encode_punct
        suba #'a'-6
        jsr dict_append
        jmp dict_encode_loop
dict_encode_space:
        clra
        jsr dict_append
        jmp dict_encode_loop
dict_encode_punct:
        ldx #text_a2+1
        ldab #7
dict_punct_loop:
        ldaa 0,x
        cmpa dict_encode_char
        beq dict_punct_found
        inx
        incb
        cmpb #32
        bcs dict_punct_loop
        ldaa #5
        jsr dict_append
        ldaa #6
        jsr dict_append
        ldaa dict_encode_char
        lsra
        lsra
        lsra
        lsra
        lsra
        jsr dict_append
        ldaa dict_encode_char
        anda #31
        jsr dict_append
        jmp dict_encode_loop
dict_punct_found:
        stab dict_punct_code
        ldaa #5
        jsr dict_append
        ldaa dict_punct_code
        jsr dict_append
        jmp dict_encode_loop
dict_pack:
        ldaa dict_zchars
        asla
        asla
        ldab dict_zchars+1
        lsrb
        lsrb
        lsrb
        aba
        staa dict_key
        ldaa dict_zchars+1
        asla
        asla
        asla
        asla
        asla
        oraa dict_zchars+2
        staa dict_key+1
        ldaa dict_zchars+3
        asla
        asla
        ldab dict_zchars+4
        lsrb
        lsrb
        lsrb
        aba
        oraa #0x80
        staa dict_key+2
        ldaa dict_zchars+4
        asla
        asla
        asla
        asla
        asla
        oraa dict_zchars+5
        staa dict_key+3
        rts
dict_append:
        ldab dict_zcount
        cmpb #6
        bcs 1f
        jmp dict_append_done
1:
        ldx #dict_zchars
dict_append_seek:
        tstb
        beq dict_append_store
        inx
        decb
        jmp dict_append_seek
dict_append_store:
        staa 0,x
        inc dict_zcount
dict_append_done:
        rts

; Binary search a sorted V3 dictionary; unknown words return dict_match=0.
dict_lookup:
        clr dict_match
        clr dict_match+1
        clr dict_lower
        clr dict_lower+1
        ldx dict_entry_count
        stx dict_upper
dict_lookup_loop:
        ldaa dict_lower
        cmpa dict_upper
        bcs dict_lookup_mid
        bls 1f
        jmp dict_lookup_done
1:
        ldab dict_lower+1
        cmpb dict_upper+1
        bcs 1f
        jmp dict_lookup_done
1:
dict_lookup_mid:
        ldaa dict_upper
        ldab dict_upper+1
        subb dict_lower+1
        sbca dict_lower
        lsra
        rorb
        addb dict_lower+1
        adca dict_lower
        staa dict_index
        stab dict_index+1
        jsr dict_index_address
        ldx mem_address+1
        stx dict_candidate
        clr dict_compare_position
dict_lookup_compare:
        jsr dict_fetch
        bcc 1f
        jmp dict_lookup_failed
1:
        staa dict_compare_char
        ldab dict_compare_position
        ldx #dict_key
dict_compare_seek:
        tstb
        beq dict_compare_byte
        inx
        decb
        jmp dict_compare_seek
dict_compare_byte:
        ldaa dict_compare_char
        cmpa 0,x
        bcs dict_lookup_larger_index
        bhi dict_lookup_smaller_index
        inc dict_compare_position
        ldaa dict_compare_position
        cmpa #4
        bcs dict_lookup_compare
        ldx dict_candidate
        stx dict_match
        jmp dict_lookup_done
dict_lookup_larger_index:
        ldx dict_index
        inx
        stx dict_lower
        jmp dict_lookup_loop
dict_lookup_smaller_index:
        ldx dict_index
        stx dict_upper
        jmp dict_lookup_loop
dict_lookup_done:
        clc
dict_lookup_failed:
        rts

; A=current input byte. Separators are standalone tokens; spaces are discarded.
dict_input_character:
        ldx #input_buffer
        ldab dict_cursor
dict_input_seek:
        tstb
        beq dict_input_found
        inx
        decb
        jmp dict_input_seek
dict_input_found:
        ldaa 0,x
        rts
dict_is_separator:
        staa dict_separator_char
        ldaa dict_separator_count
        staa dict_separator_remaining
        beq dict_not_separator
        ldx dict_separators
        stx mem_address+1
        clr mem_address
dict_separator_loop:
        jsr dict_fetch
        bcc 1f
        jmp dict_lookup_failed
1:
        cmpa dict_separator_char
        beq dict_yes_separator
        dec dict_separator_remaining
        bne dict_separator_loop
dict_not_separator:
        clra
        clc
        rts
dict_yes_separator:
        ldaa #1
        clc
        rts

dict_tokenize:
        clr dict_cursor
        clr dict_token_count
        ldx dict_parse_host
        inx
        clr 0,x
        inx
        stx dict_parse_pointer
dict_token_loop:
        ldaa dict_token_count
        cmpa dict_parse_limit
        bcs 1f
        jmp dict_tokens_done
1:
        ldaa dict_cursor
        cmpa input_length
        bcs 1f
        jmp dict_tokens_done
1:
        jsr dict_input_character
        cmpa #32
        bne dict_token_start
        inc dict_cursor
        jmp dict_token_loop
dict_token_start:
        ldaa dict_cursor
        staa dict_word_start
        clr dict_word_length
        jsr dict_input_character
        jsr dict_is_separator
        bcc 1f
        jmp dict_tokens_failed
1:
        tsta
        beq dict_word_loop
        inc dict_word_length
        inc dict_cursor
        jmp dict_token_commit
dict_word_loop:
        inc dict_word_length
        inc dict_cursor
        ldaa dict_cursor
        cmpa input_length
        bcc dict_token_commit
        jsr dict_input_character
        cmpa #32
        beq dict_token_commit
        jsr dict_is_separator
        bcc 1f
        jmp dict_tokens_failed
1:
        tsta
        beq dict_word_loop
dict_token_commit:
        jsr dict_encode
        jsr dict_lookup
        bcc 1f
        jmp dict_tokens_failed
1:
        ldx dict_parse_pointer
        ldaa dict_match
        staa 0,x
        ldaa dict_match+1
        staa 1,x
        ldaa dict_word_length
        staa 2,x
        ldaa dict_word_start
        inca
        staa 3,x
        inx
        inx
        inx
        inx
        stx dict_parse_pointer
        inc dict_token_count
        jmp dict_token_loop
dict_tokens_done:
        ldx dict_parse_host
        ldaa dict_token_count
        staa 1,x
        clc
dict_tokens_failed:
        rts
dict_error:
        jsr wrap_finish
        ldaa #1
        staa op_halted
        ldx #dict_error_message
        jsr pstrng
        jsr pcrlf
        sec
        rts

dict_parse_address: .word 0
dict_parse_end: .word 0
dict_parse_host: .word 0
dict_parse_pointer: .word 0
dict_parse_limit: .byte 0
dict_separator_count: .byte 0
dict_separators: .word 0
dict_separator_char: .byte 0
dict_separator_remaining: .byte 0
dict_entries: .word 0
dict_entry_count: .word 0
dict_entry_length: .byte 0
dict_index: .word 0
dict_multiplicand: .space 3,0
dict_multiplier: .byte 0
dict_multiply_bits: .byte 0
dict_key: .space 4,0
dict_zchars: .space 6,0
dict_zcount: .byte 0
dict_encode_position: .byte 0
dict_encode_remaining: .byte 0
dict_encode_char: .byte 0
dict_punct_code: .byte 0
dict_match: .word 0
dict_candidate: .word 0
dict_lower: .word 0
dict_upper: .word 0
dict_compare_position: .byte 0
dict_compare_char: .byte 0
dict_cursor: .byte 0
dict_token_count: .byte 0
dict_word_start: .byte 0
dict_word_length: .byte 0
dict_error_message:
        .ascii "Z68: invalid V3 dictionary or parse buffer."
        .byte 4
