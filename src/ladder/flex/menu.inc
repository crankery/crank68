; The opening menu follows the original Ladder logo and option layout.
; Only options supported by this Easy Street port are shown.
start_screen:
        jsr draw_start_screen
menu_wait:
        jsr poll
        bcs menu_has_key
        jsr menu_idle_tick
        bra menu_wait
menu_has_key:
        jsr getc
        jsr menu_key
        ldaa menu_action
        cmpa #1
        beq menu_begin_game
        cmpa #2
        beq menu_exit
        cmpa #3
        beq menu_instructions
        cmpa #4
        beq menu_speed
        bra menu_wait
menu_begin_game:
        rts
menu_exit:
        jmp quit
menu_instructions:
        jsr show_instructions
        bra start_screen
menu_speed:
        jsr change_speed
        jsr show_menu_speed
        bra menu_wait

; A small standalone key decoder makes the menu choices easy to probe.
menu_key:
        clr menu_action
        cmpa #'p'
        beq menu_key_play
        cmpa #'P'
        beq menu_key_play
        cmpa #'e'
        beq menu_key_exit
        cmpa #'E'
        beq menu_key_exit
        cmpa #'i'
        beq menu_key_instructions
        cmpa #'I'
        beq menu_key_instructions
        cmpa #'l'
        beq menu_key_speed
        cmpa #'L'
        beq menu_key_speed
        rts
menu_key_play:
        ldaa #1
        bra menu_key_store
menu_key_exit:
        ldaa #2
        bra menu_key_store
menu_key_instructions:
        ldaa #3
        bra menu_key_store
menu_key_speed:
        ldaa #4
menu_key_store:
        staa menu_action
        rts

draw_start_screen:
        ldx #clear_text
        jsr print
        ldx #menu_text
        jsr print
        clr menu_idle_state
        ldx #0
        stx menu_idle_count
        jmp show_menu_speed
show_menu_speed:
        ldaa #11
        staa cursor_row
        ldaa #52
        staa cursor_col
        jsr cursor_to
        ldaa play_speed
        adda #'0'
        jmp outch

change_speed:
        inc play_speed
        ldaa play_speed
        cmpa #6
        bne speed_select
        ldaa #1
        staa play_speed
speed_select:
        cmpa #1
        bne speed_2
        ldx #12000
        bra speed_store
speed_2:
        cmpa #2
        bne speed_3
        ldx #6000
        bra speed_store
speed_3:
        cmpa #3
        bne speed_4
        ldx #3000
        bra speed_store
speed_4:
        cmpa #4
        bne speed_5
        ldx #1500
        bra speed_store
speed_5:
        ldx #750
speed_store:
        stx tick_delay
        rts

; The original menu occasionally heckles an idle player. Keep the messages
; off the game board and clear each one after the next idle interval.
menu_idle_tick:
        ldx menu_idle_count
        inx
        stx menu_idle_count
        cpx #30000
        bne menu_idle_done
        ldx #0
        stx menu_idle_count
        inc menu_idle_state
        ldaa menu_idle_state
        cmpa #4
        bne menu_idle_select
        clr menu_idle_state
menu_idle_select:
        ldaa #24
        staa cursor_row
        ldaa #1
        staa cursor_col
        jsr cursor_to
        ldaa menu_idle_state
        cmpa #1
        beq menu_idle_quiche
        cmpa #3
        beq menu_idle_hurry
        ldx #menu_idle_clear
        jmp print
menu_idle_quiche:
        ldx #menu_quiche
        jmp print
menu_idle_hurry:
        ldx #menu_hurry
        jmp print
menu_idle_done:
        rts

show_instructions:
        ldx #clear_text
        jsr print
        ldx #menu_instructions_text
        jsr print
instructions_wait:
        jsr getc
        cmpa #13
        beq instructions_done
        cmpa #10
        bne instructions_wait
instructions_done:
        rts

menu_text:
        .ascii "               LL                     dd       dd"
        .byte 13,10
        .ascii "               LL                     dd       dd                      tm"
        .byte 13,10
        .ascii "               LL         aaaa     ddddd    ddddd    eeee   rrrrrrr"
        .byte 13,10
        .ascii "               LL        aa  aa   dd  dd   dd  dd   ee  ee  rr    rr"
        .byte 13,10
        .ascii "               LL        aa  aa   dd  dd   dd  dd   eeeeee  rr"
        .byte 13,10
        .ascii "               LL        aa  aa   dd  dd   dd  dd   ee      rr"
        .byte 13,10
        .ascii "               LLLLLLLL   aaa aa   ddd dd   ddd dd   eeee   rr"
        .byte 13,10,13,10
        .ascii "                                       Version: C68 FLEX"
        .byte 13,10
        .ascii "(c) 1982 Yahoo Software              Terminal: ANSI/VT100"
        .byte 13,10
        .ascii "                                       Play speed: "
        .byte 13,10
        .ascii "                                       Up K/W  Down J/S  Left H/A  Right L/D"
        .byte 13,10
        .ascii "                                       Jump = Space   Stop = Other"
        .byte 13,10,13,10
        .ascii "P = Play game"
        .byte 13,10
        .ascii "L = Change level of difficulty"
        .byte 13,10
        .ascii "I = Instructions"
        .byte 13,10
        .ascii "E = Exit Ladder"
        .byte 13,10,13,10,13,10,13,10
        .ascii "Enter one of the above: "
        .byte 0
menu_quiche:
        .ascii "You eat quiche!"
        .byte 0
menu_hurry:
        .ascii "Come on, we don't have all day!"
        .byte 0
menu_idle_clear:
        .ascii "                                        "
        .byte 0
menu_instructions_text:
        .ascii "Ladder instructions"
        .byte 13,10,13,10
        .ascii "You are a Lad trapped in a maze. Explore the corridors"
        .byte 13,10
        .ascii "and find the hidden treasure ($)."
        .byte 13,10,13,10
        .ascii "Move with H/J/K/L or A/S/W/D. Press SPACE to jump."
        .byte 13,10
        .ascii "Any other key stops Lad. Beware the falling Der Rocks."
        .byte 13,10,13,10
        .ascii "Mind the fire (^) and floors that vanish behind you (-)."
        .byte 13,10,13,10
        .ascii "Good luck Lad."
        .byte 13,10,13,10
        .ascii "Press RETURN to return to the menu: "
        .byte 0
