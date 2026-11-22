; LADDER.HIS on the drive from which FLEX loaded LADDER.CMD.
; One FLEX sector: "C68H", then five 16-byte records. Each record has a
; big-endian score, month/day/year bytes, and an 11-byte zero-padded name.
highscore_init:
        ldaa command_drive
        staa score_drive
        jsr clear_highscores
        jsr prepare_score_fcb
        ldaa #1
        staa score_fcb
        ldx #score_fcb
        jsr fms
        bne highscore_init_done
        ldaa #0xff
        staa score_fcb+59
        ldx #score_magic
        stx high_ptr
        ldaa #84
        staa bytes_left
highscore_read_next:
        clr score_fcb
        ldx #score_fcb
        jsr fms
        bne highscore_read_bad
        ldx high_ptr
        staa 0,x
        inx
        stx high_ptr
        dec bytes_left
        bne highscore_read_next
        ldaa score_magic
        cmpa #'C'
        bne highscore_read_bad
        ldaa score_magic+1
        cmpa #'6'
        bne highscore_read_bad
        ldaa score_magic+2
        cmpa #'8'
        bne highscore_read_bad
        ldaa score_magic+3
        cmpa #'H'
        beq highscore_read_close
highscore_read_bad:
        jsr clear_highscores
        ldaa #'C'
        staa score_magic
        ldaa #'6'
        staa score_magic+1
        ldaa #'8'
        staa score_magic+2
        ldaa #'H'
        staa score_magic+3
highscore_read_close:
        ldaa #4
        staa score_fcb
        ldx #score_fcb
        jsr fms
highscore_init_done:
        rts

clear_highscores:
        ldx #top_scores
        ldab #80
clear_highscores_next:
        clr 0,x
        inx
        decb
        bne clear_highscores_next
        rts

prepare_score_fcb:
        ldx #score_fcb
        ldab #64
prepare_score_clear:
        clr 0,x
        inx
        decb
        bne prepare_score_clear
        ldaa score_drive
        staa score_fcb+3
        ldx #score_filename
        ldab #11
        stx high_ptr
        ldx #score_fcb+4
prepare_score_name:
        stx high_dst
        ldx high_ptr
        ldaa 0,x
        inx
        stx high_ptr
        ldx high_dst
        staa 0,x
        inx
        decb
        bne prepare_score_name
        rts

; Called only when the last Lad dies. The original game records scores at
; game over, so returning to the menu during a run does not submit it.
highscore_finish:
        tst highscore_eligible
        beq highscore_finish_done
        ldaa score
        oraa score+1
        beq highscore_finish_done
        ldx #top_scores
highscore_find:
        ldaa score
        cmpa 0,x
        bhi highscore_qualifies
        bcs highscore_next
        ldaa score+1
        cmpa 1,x
        bcc highscore_qualifies
highscore_next:
        ldab #16
highscore_step:
        inx
        decb
        bne highscore_step
        cpx #top_scores+80
        bne highscore_find
highscore_finish_done:
        rts
highscore_qualifies:
        stx insert_ptr
        ldx #top_scores+64
        stx shift_dst
highscore_shift:
        cpx insert_ptr
        beq highscore_insert
        ldab #16
highscore_back:
        dex
        decb
        bne highscore_back
        stx shift_src
        stx shift_base
        ldab #16
highscore_copy:
        ldx shift_src
        ldaa 0,x
        inx
        stx shift_src
        ldx shift_dst
        staa 0,x
        inx
        stx shift_dst
        decb
        bne highscore_copy
        ldx shift_base
        stx shift_dst
        bra highscore_shift
highscore_insert:
        ldaa score
        staa 0,x
        ldaa score+1
        staa 1,x
        ldaa flex_date
        staa 2,x
        ldaa flex_date+1
        staa 3,x
        ldaa flex_date+2
        staa 4,x
        jsr highscore_name
        jsr highscore_save
        rts

highscore_name:
        ldx insert_ptr
        ldab #5
highscore_name_start:
        inx
        decb
        bne highscore_name_start
        stx name_ptr
        ldab #11
highscore_name_clear:
        clr 0,x
        inx
        decb
        bne highscore_name_clear
        clr name_count
        ldx #name_prompt
        jsr print_at_prompt
        ldx #cursor_on_text
        jsr print
highscore_name_key:
        jsr getc
        cmpa #13
        beq highscore_name_done
        cmpa #10
        beq highscore_name_done
        cmpa #8
        beq highscore_name_backspace
        cmpa #127
        beq highscore_name_backspace
        cmpa #32
        bcs highscore_name_key
        cmpa #126
        bhi highscore_name_key
        ldab name_count
        cmpb #10
        bcc highscore_name_key
        ldx name_ptr
        staa 0,x
        inx
        stx name_ptr
        inc name_count
        jsr outch
        bra highscore_name_key
highscore_name_backspace:
        tst name_count
        beq highscore_name_key
        dec name_count
        ldx name_ptr
        dex
        stx name_ptr
        clr 0,x
        ldx #erase_char_text
        jsr print
        bra highscore_name_key
highscore_name_done:
        tst name_count
        bne highscore_name_hide
        ldx insert_ptr
        ldaa #'L'
        staa 5,x
        ldaa #'A'
        staa 6,x
        ldaa #'D'
        staa 7,x
highscore_name_hide:
        ldx #cursor_off_text
        jmp print

highscore_save:
        jsr prepare_score_fcb
        ldaa #1                 ; find the existing sequential file
        staa score_fcb
        ldx #score_fcb
        jsr fms
        beq highscore_update
        jsr prepare_score_fcb
        ldaa #2                 ; first high score creates the file
        staa score_fcb
        ldx #score_fcb
        jsr fms
        beq highscore_create
        jmp highscore_save_error
highscore_create:
        ldaa #0xff
        staa score_fcb+59
        ldx #score_magic
        stx high_ptr
        ldaa #84
        staa bytes_left
highscore_create_next:
        ldx high_ptr
        ldaa 0,x
        inx
        stx high_ptr
        clr score_fcb
        ldx #score_fcb
        jsr fms
        bne highscore_save_close_error
        dec bytes_left
        bne highscore_create_next
        bra highscore_save_close
highscore_update:
        ldaa score_fcb+15      ; honor FLEX's write-protect attribute
        bita #0x80
        bne highscore_save_close_error
        ldaa #0xff
        staa score_fcb+59
        clr score_fcb           ; read one byte to load the first sector
        ldx #score_fcb
        jsr fms
        bne highscore_save_close_error
        ldx #score_magic
        stx high_ptr
        ldx #score_fcb+68       ; sector bytes 4..87 hold our payload
        stx high_dst
        ldaa #84
        staa bytes_left
highscore_update_next:
        ldx high_ptr
        ldaa 0,x
        inx
        stx high_ptr
        ldx high_dst
        staa 0,x
        inx
        stx high_dst
        dec bytes_left
        bne highscore_update_next
        ldaa #10                ; FLEX write-current-sector service
        staa score_fcb
        ldx #score_fcb
        jsr fms
        bne highscore_save_close_error
highscore_save_close:
        ldaa #4
        staa score_fcb
        ldx #score_fcb
        jsr fms
        bne highscore_save_error
        rts
highscore_save_close_error:
        ldaa #4
        staa score_fcb
        ldx #score_fcb
        jsr fms
highscore_save_error:
        ldx #score_save_error_text
        jmp print_at_prompt

show_highscores:
        ldaa #17
        staa cursor_row
        ldaa #40
        staa cursor_col
        jsr cursor_to
        ldx #highscore_heading
        jsr print
        ldx #top_scores
        stx high_ptr
        ldaa #18
        staa high_row
        ldaa #1
        staa high_rank
show_highscores_next:
        ldaa high_row
        staa cursor_row
        ldaa #40
        staa cursor_col
        jsr cursor_to
        ldaa high_rank
        adda #'0'
        jsr outch
        ldaa #')'
        jsr outch
        ldaa #' '
        jsr outch
        ldx high_ptr
        ldaa 0,x
        oraa 1,x
        beq show_highscores_empty
        ldx 0,x
        stx score_work
        ldx #10000
        jsr score_digit
        ldx #1000
        jsr score_digit
        ldx #100
        jsr score_digit
        ldx #10
        jsr score_digit
        ldx #1
        jsr score_digit
        ldaa #' '
        jsr outch
        ldx high_ptr
        ldaa 2,x
        jsr highscore_two_digits
        ldaa #'/'
        jsr outch
        ldx high_ptr
        ldaa 3,x
        jsr highscore_two_digits
        ldaa #'/'
        jsr outch
        ldx high_ptr
        ldaa 4,x
        jsr highscore_two_digits
        ldaa #' '
        jsr outch
        ldx high_ptr
        ldab #5
highscore_name_offset:
        inx
        decb
        bne highscore_name_offset
        ldab #10
highscore_print_name:
        ldaa 0,x
        beq show_highscores_empty
        jsr outch
        inx
        decb
        bne highscore_print_name
show_highscores_empty:
        ldx high_ptr
        ldab #16
show_highscores_step:
        inx
        decb
        bne show_highscores_step
        stx high_ptr
        inc high_row
        inc high_rank
        ldaa high_rank
        cmpa #6
        beq show_highscores_done
        jmp show_highscores_next
show_highscores_done:
        rts

highscore_two_digits:
        clrb
highscore_tens:
        cmpa #10
        bcs highscore_ones
        suba #10
        incb
        bra highscore_tens
highscore_ones:
        staa high_digit
        tba
        adda #'0'
        jsr outch
        ldaa high_digit
        adda #'0'
        jmp outch

score_filename: .ascii "LADDER  HIS"
score_magic:    .ascii "C68H"
top_scores:     .space 80,0
score_fcb:      .space 320,0
score_drive:    .byte 0
highscore_eligible: .byte 0
bytes_left:     .byte 0
high_ptr:       .word 0
high_dst:       .word 0
insert_ptr:     .word 0
shift_dst:      .word 0
shift_src:      .word 0
shift_base:     .word 0
name_ptr:       .word 0
name_count:     .byte 0
high_row:       .byte 0
high_rank:      .byte 0
high_digit:     .byte 0
name_prompt:    .ascii "High score! Name (10 chars): "
                .byte 0
cursor_on_text: .byte 27
                .ascii "[?25h"
                .byte 0
cursor_off_text: .byte 27
                .ascii "[?25l"
                .byte 0
erase_char_text: .byte 8,32,8,0
score_save_error_text:
                .ascii "Could not save LADDER.HIS.                             "
                .byte 0
highscore_heading:
                .ascii "High Scores"
                .byte 0
