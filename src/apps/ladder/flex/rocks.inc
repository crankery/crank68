; Easy Street rock actors. Each slot is X, Y, state (0 inactive,
; 1/2 downward, 3 left, 4 right). Easy Street releases at most five;
; Long Island uses all eight slots.

init_rocks:
        clr rock_count
        ldx #rock_slots
        ldaa #24
init_rock_byte:
        clr 0,x
        inx
        deca
        bne init_rock_byte
        rts

release_rock:
        ldaa #0xff
        staa rock_skip
        ldaa rock_count
        cmpa rock_limit
        bcc release_done
        ldx #rock_slots
        clr rock_slot
release_find:
        ldaa 2,x
        beq release_found
        inx
        inx
        inx
        inc rock_slot
        ldaa rock_slot
        cmpa rock_limit
        bcs release_find
        rts
release_found:
        ldaa #40
        staa 0,x
        ldaa #2
        staa 1,x
        staa 2,x
        inc rock_count
        ldaa rock_slot
        staa rock_skip
release_done:
        rts

move_rocks:
        tst won_level
        bne rocks_done
        jsr release_rock
        jsr check_player_rocks
        tst death_flag
        bne rocks_done
        ldx #rock_slots
        stx rock_ptr
        clr rock_slot
rock_loop:
        ldaa rock_slot
        cmpa rock_limit
        bcc rocks_draw
        cmpa rock_skip
        beq rock_next
        jsr load_rock
        tst rock_state
        beq rock_next
        jsr erase_rock
        jsr step_rock
        jsr save_rock
        tst death_flag
        bne rocks_done
rock_next:
        ldx rock_ptr
        inx
        inx
        inx
        stx rock_ptr
        inc rock_slot
        bra rock_loop
rocks_draw:
        jsr draw_all_rocks
rocks_done:
        rts

load_rock:
        ldx rock_ptr
        ldaa 0,x
        staa rock_x
        ldaa 1,x
        staa rock_y
        ldaa 2,x
        staa rock_state
        rts
save_rock:
        ldx rock_ptr
        ldaa rock_x
        staa 0,x
        ldaa rock_y
        staa 1,x
        ldaa rock_state
        staa 2,x
        rts

check_player_rocks:
        ldx #rock_slots
        stx rock_ptr
        clr rock_slot
check_rock_loop:
        ldaa rock_slot
        cmpa rock_limit
        bcc check_rocks_done
        jsr load_rock
        tst rock_state
        beq check_rock_next
        jsr check_work_contact
        tst death_flag
        bne check_rocks_done
check_rock_next:
        ldx rock_ptr
        inx
        inx
        inx
        stx rock_ptr
        inc rock_slot
        bra check_rock_loop
check_rocks_done:
        rts
check_work_contact:
        ldaa rock_x
        cmpa player_x
        bne contact_clear
        ldaa rock_y
        cmpa player_y
        bne contact_clear
        ldaa #1
        staa death_flag
contact_clear:
        rts

erase_rock:
        ldaa rock_x
        staa target_x
        staa cursor_col
        ldaa rock_y
        staa target_y
        staa cursor_row
        jsr target_tile
        cmpa #'p'
        bne erase_rock_literal
        ldaa #' '
erase_rock_literal:
        staa draw_char
        jsr cursor_to
        ldaa draw_char
        jmp outch
draw_work_rock:
        ldaa rock_x
        staa cursor_col
        ldaa rock_y
        staa cursor_row
        jsr cursor_to
        ldaa #'o'
        jmp outch
draw_all_rocks:
        ldx #rock_slots
        stx rock_ptr
        clr rock_slot
draw_rock_loop:
        ldaa rock_slot
        cmpa rock_limit
        bcc draw_rocks_done
        jsr load_rock
        tst rock_state
        beq draw_rock_next
        jsr draw_work_rock
draw_rock_next:
        ldx rock_ptr
        inx
        inx
        inx
        stx rock_ptr
        inc rock_slot
        bra draw_rock_loop
draw_rocks_done:
        rts

step_rock:
        ldaa rock_x
        staa target_x
        ldaa rock_y
        staa target_y
        jsr target_tile
        cmpa #'*'
        bne rock_not_eaten
        clr rock_state
        dec rock_count
        rts
rock_not_eaten:
        ldaa rock_state
        cmpa #3
        bcs rock_down
        ldaa rock_x
        staa target_x
        ldaa rock_y
        staa target_y
        jsr target_tile
        cmpa #'H'
        beq rock_on_ladder
        jsr rock_below
        bcs rock_horizontal
        jmp rock_fall_step
rock_on_ladder:
        jsr rng_three
        cmpa #0
        beq rock_ladder_reverse
        cmpa #1
        bne rock_horizontal
        jsr rock_below
        bcc rock_fall_step
        jsr reverse_rock
        rts
rock_ladder_reverse:
        jsr reverse_rock
        bra rock_horizontal

rock_down:
        jsr rock_below
        bcc rock_fall_step
        jsr rng_two
        staa rock_state
        rts
rock_fall_step:
        inc rock_y
        ldaa #2
        staa rock_state
        jmp check_work_contact

rock_below:
        ldaa rock_y
        cmpa #19
        bcc rock_below_blocked
        inca
        staa target_y
        ldaa rock_x
        staa target_x
        jsr target_tile
        jmp rock_tile_blocked
rock_below_blocked:
        sec
        rts

rock_horizontal:
        ldaa rock_state
        cmpa #3
        beq rock_left
        ldaa rock_x
        cmpa #79
        beq rock_turn
        inca
        staa target_x
        bra rock_side_target
rock_left:
        ldaa rock_x
        cmpa #1
        beq rock_turn
        deca
        staa target_x
rock_side_target:
        ldaa rock_y
        staa target_y
        jsr target_tile
        jsr rock_tile_blocked
        bcs rock_turn
        ldaa target_x
        staa rock_x
        jmp check_work_contact
rock_turn:
        jsr reverse_rock
        rts
reverse_rock:
        ldaa rock_state
        cmpa #3
        beq rock_set_right
        ldaa #3
        staa rock_state
        rts
rock_set_right:
        ldaa #4
        staa rock_state
        rts

; Carry set for original terrain codes 1..5.
rock_tile_blocked:
        cmpa #'-'
        beq rock_tile_yes
        cmpa #'='
        beq rock_tile_yes
        cmpa #'$'
        beq rock_tile_yes
        cmpa #'|'
        beq rock_tile_yes
        cmpa #'V'
        beq rock_tile_yes
        clc
        rts
rock_tile_yes:
        sec
        rts

; Low 24 bits of the original generator: state = 5*state + 3.
rng_next:
        ldaa rng0
        staa rng_old0
        ldaa rng1
        staa rng_old1
        ldaa rng2
        staa rng_old2
        asl rng0
        rol rng1
        rol rng2
        asl rng0
        rol rng1
        rol rng2
        ldaa rng0
        adda #3
        adda rng_old0
        staa rng0
        ldaa rng1
        adca rng_old1
        staa rng1
        ldaa rng2
        adca rng_old2
        staa rng2
        rts
rng_two:
        jsr rng_next
        ldaa rng2
        bmi rng_two_right
        ldaa #3
        rts
rng_two_right:
        ldaa #4
        rts

; Exact thirds of the low-24-bit value, including boundary cells.
rng_three:
        jsr rng_next
        ldaa rng2
        cmpa #0x55
        bcs rng_three_zero
        bhi rng_three_upper
        ldaa rng1
        cmpa #0x55
        bcs rng_three_zero
        bhi rng_three_one
        ldaa rng0
        cmpa #0x55
        bls rng_three_zero
        bra rng_three_one
rng_three_upper:
        ldaa rng2
        cmpa #0xaa
        bcs rng_three_one
        bhi rng_three_two
        ldaa rng1
        cmpa #0xaa
        bcs rng_three_one
        bhi rng_three_two
        ldaa rng0
        cmpa #0xaa
        bls rng_three_one
rng_three_two:
        ldaa #2
        rts
rng_three_one:
        ldaa #1
        rts
rng_three_zero:
        clra
        rts
