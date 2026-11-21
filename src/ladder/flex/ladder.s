; Easy Street prototype for C68 FLEX and an ANSI/VT100 terminal.
; Terrain is generated from Pascal layouts with original-game corrections.
; Movement follows the probed original CP/M Ladder rules.
; SPDX-License-Identifier: GPL-2.0-or-later
        .equ outch, 0xad0f
        .equ warms, 0xad03
        .equ getc, 0xbf00
        .equ poll, 0xbf2a

        .org 0x0300
start:
        sts saved_sp
        ldaa #6
        staa player_x
        ldaa #19
        staa player_y
        clr direction
        clr jump_step
        clr won_level
        ldx #clear_text
        jsr print
        jsr draw_level
        jsr draw_player
game_loop:
        ldx #12000             ; approximate game tick; tune on hardware
tick_wait:
        dex
        bne tick_wait
        jsr move_player
        jsr poll
        bcc game_loop
        jsr getc
        jsr handle_key
        bra game_loop

handle_key:
        cmpa #'q'
        beq quit
        cmpa #'Q'
        beq quit
        cmpa #'h'
        beq key_left
        cmpa #'a'
        beq key_left
        cmpa #'l'
        beq key_right
        cmpa #'d'
        beq key_right
        cmpa #'k'
        beq key_up
        cmpa #'w'
        beq key_up
        cmpa #'j'
        beq key_down
        cmpa #'s'
        beq key_down
        cmpa #' '
        beq key_jump
        clr direction
        rts
key_left:
        ldaa #1
        staa direction
        rts
key_right:
        ldaa #2
        staa direction
        rts
key_up:
        ldaa #3
        staa direction
        rts
key_down:
        ldaa #4
        staa direction
        rts
key_jump:
        tst jump_step
        bne jump_key_done
        jsr is_solid
        tst solid_flag
        beq jump_key_done
        ldaa #1
        staa jump_step
jump_key_done:
        rts
quit:
        ldx #exit_text
        jsr print
        lds saved_sp
        jmp warms

move_player:
        tst won_level
        beq active_level
        rts
active_level:
        ldaa player_x
        staa old_x
        ldaa player_y
        staa old_y
        tst jump_step
        beq move_regular
        jsr move_jump
        jmp move_done
move_regular:
        ldaa direction
        cmpa #1
        beq move_left
        cmpa #2
        beq move_right
        cmpa #3
        beq move_up
        cmpa #4
        bne move_still
        jmp move_down
move_still:
        jsr fall_if_needed
        jmp move_done
move_left:
        jsr is_solid
        tst solid_flag
        bne left_supported
        jmp fall_only
left_supported:
        ldaa player_x
        cmpa #1
        bne left_in_bounds
        jmp move_done
left_in_bounds:
        deca
        staa target_x
        ldaa player_y
        staa target_y
        bra move_horizontal
move_right:
        jsr is_solid
        tst solid_flag
        bne right_supported
        jmp fall_only
right_supported:
        ldaa player_x
        cmpa #79
        bne right_in_bounds
        jmp move_done
right_in_bounds:
        inca
        staa target_x
        ldaa player_y
        staa target_y
move_horizontal:
        jsr target_tile
        jsr is_wall
        bcs move_done
        ldaa target_x
        staa player_x
        jsr clear_departed_floor
        bra move_done

move_up:
        jsr is_solid
        tst solid_flag
        bne up_supported
        jmp fall_only
up_supported:
        ldaa player_x
        staa target_x
        ldaa player_y
        staa target_y
        ldaa player_y
        cmpa #1
        beq move_done
        deca
        staa target_y
        jsr target_tile
        cmpa #'H'
        beq climb_up
        cmpa #'&'
        beq climb_up
        cmpa #'$'
        bne move_done
climb_up:
        dec player_y
        bra move_done
move_down:
        ldaa player_y
        cmpa #19
        beq move_done
        ldaa player_x
        staa target_x
        ldaa player_y
        staa target_y
        jsr target_tile
        cmpa #'H'
        beq down_allowed
        inc target_y
        jsr target_tile
        cmpa #'H'
        bne move_done
down_allowed:
        ldaa player_y
        inca
        staa target_y
        jsr target_tile
        jsr is_down_blocked
        bcs move_done
        inc player_y
        bra move_done
fall_only:
        jsr fall_if_needed
        bra move_done
move_done:
        ldaa player_x
        cmpa old_x
        bne moved
        ldaa player_y
        cmpa old_y
        bne moved
        rts
moved:
        jsr restore_old
        jsr draw_player
        ldaa player_x
        staa target_x
        ldaa player_y
        staa target_y
        jsr target_tile
        cmpa #'$'
        beq level_done
        cmpa #'^'
        beq fire_reset
        rts
level_done:
        clr direction
        clr jump_step
        ldaa #1
        staa won_level
        ldx #win_text
        jsr print_at_prompt
        rts
fire_reset:
        ldaa #6
        staa player_x
        ldaa #19
        staa player_y
        clr direction
        clr jump_step
        jmp draw_player

; Ordinary sideways movement consumes '-' below the departed cell.
; A jump's horizontal apex uses move_jump and leaves that floor intact.
clear_departed_floor:
        ldaa old_x
        staa target_x
        staa cursor_col
        ldaa old_y
        inca
        staa target_y
        staa cursor_row
        jsr target_tile
        cmpa #'-'
        bne floor_clear_done
        ldaa #' '
        staa 0,x
        jsr cursor_to
        ldaa #' '
        jsr outch
floor_clear_done:
        rts

fall_if_needed:
        jsr is_solid
        tst solid_flag
        bne fall_done
        ldaa player_y
        cmpa #19
        bcc fall_done
        inc player_y
fall_done:
        rts

; Original jump: up/up, two apex steps, down/down.
; Horizontal motion is applied on each step of a moving jump.
move_jump:
        ldaa player_x
        staa target_x
        ldaa player_y
        staa target_y
        ldaa jump_step
        cmpa #3
        bcc jump_not_up
        dec target_y
        bra jump_vertical_done
jump_not_up:
        cmpa #5
        bcs jump_vertical_done
        inc target_y
jump_vertical_done:
        ldaa direction
        cmpa #1
        beq jump_to_left
        cmpa #2
        bne jump_target_ready
        inc target_x
        bra jump_target_ready
jump_to_left:
        dec target_x
jump_target_ready:
        ldaa target_x
        beq jump_wall
        cmpa #80
        bcc jump_wall
        ldaa target_y
        beq jump_blocked
        cmpa #20
        bcc jump_blocked
        jsr target_tile
        cmpa #'|'
        beq jump_wall
        cmpa #'='
        beq jump_blocked
        cmpa #'H'
        beq jump_ladder
        ldaa target_x
        staa player_x
        ldaa target_y
        staa player_y
        inc jump_step
        ldaa jump_step
        cmpa #7
        bcs jump_return
        clr jump_step
jump_return:
        rts
jump_blocked:
        clr jump_step
        jmp fall_if_needed
jump_ladder:
        ldaa target_x
        staa player_x
        ldaa target_y
        staa player_y
        clr jump_step
        rts
jump_wall:
        ldaa direction
        cmpa #1
        beq jump_wall_right
        cmpa #2
        bne jump_return
        ldaa #1
        staa direction
        rts
jump_wall_right:
        ldaa #2
        staa direction
        rts

; Return solid_flag=1 if on a ladder or above support codes 1 through 5.
; A ladder one row below does not support Lad: he falls into it.
is_solid:
        clr solid_flag
        ldaa player_x
        staa target_x
        ldaa player_y
        staa target_y
        jsr target_tile
        cmpa #'H'
        beq solid_yes
        ldaa player_y
        cmpa #19
        bcc solid_yes
        inc target_y
        jsr target_tile
        cmpa #'='
        beq solid_yes
        cmpa #'-'
        beq solid_yes
        cmpa #'$'
        beq solid_yes
        cmpa #'|'
        beq solid_yes
        cmpa #'V'
        bne solid_done
solid_yes:
        ldaa #1
        staa solid_flag
solid_done:
        rts

; Horizontal movement blocks solid floor and wall. A disposable floor
; can be entered sideways, but blocks a downward climb.
is_wall:
        cmpa #'='
        beq wall_yes
        cmpa #'|'
        beq wall_yes
        clc
        rts
is_down_blocked:
        cmpa #'-'
        beq wall_yes
        cmpa #'V'
        beq wall_yes
        jmp is_wall
wall_yes:
        sec
        rts

; Look up target_x,target_y (1-based). Return character in A.
target_tile:
        ldx #row_pointers
        ldab target_y
        decb
target_row:
        tstb
        beq row_found
        inx
        inx
        decb
        bra target_row
row_found:
        ldx 0,x
        ldab target_x
        decb
target_col:
        tstb
        beq col_found
        inx
        decb
        bra target_col
col_found:
        ldaa 0,x
        rts

draw_level:
        ldx #level_map
        ldaa #20
        staa rows_left
draw_row:
        ldaa #79
        staa cols_left
draw_col:
        ldaa 0,x
        cmpa #'p'
        bne draw_literal
        ldaa #' '
draw_literal:
        jsr outch
        inx
        dec cols_left
        bne draw_col
        ldaa #13
        jsr outch
        ldaa #10
        jsr outch
        dec rows_left
        bne draw_row
        ldx #status_text
        jsr print
        rts

restore_old:
        ldaa old_x
        staa target_x
        staa cursor_col
        ldaa old_y
        staa target_y
        staa cursor_row
        jsr target_tile
        cmpa #'p'
        bne restore_literal
        ldaa #' '
restore_literal:
        staa draw_char
        jsr cursor_to
        ldaa draw_char
        jmp outch
draw_player:
        ldaa player_y
        staa cursor_row
        ldaa player_x
        staa cursor_col
        jsr cursor_to
        ldaa #'g'
        jmp outch
print_at_prompt:
        ldaa #23
        staa cursor_row
        ldaa #1
        staa cursor_col
        jsr cursor_to
        jmp print
cursor_to:
        ldaa #27
        jsr outch
        ldaa #'['
        jsr outch
        ldaa cursor_row
        jsr decimal
        ldaa #';'
        jsr outch
        ldaa cursor_col
        jsr decimal
        ldaa #'H'
        jmp outch
decimal:
        clrb
decimal_tens:
        cmpa #10
        bcs decimal_ones
        suba #10
        incb
        bra decimal_tens
decimal_ones:
        staa digit
        tstb
        beq decimal_last
        tba
        adda #'0'
        jsr outch
decimal_last:
        ldaa digit
        adda #'0'
        jmp outch
print:
        ldaa 0,x
        beq print_done
        jsr outch
        inx
        bra print
print_done:
        rts

clear_text: .byte 27
        .ascii "[?25l"
        .byte 27
        .ascii "[2J"
        .byte 27
        .ascii "[H"
        .byte 0
status_text:
        .ascii "Easy Street   h/j/k/l or WASD move   SPACE jump   Q quit"
        .byte 0
win_text:
        .ascii "You found the treasure! Press Q to leave.             "
        .byte 0
exit_text:
        .byte 27
        .ascii "[23;1H"
        .byte 27
        .ascii "[?25h"
        .byte 13,10,0

saved_sp:     .word 0
player_x:     .byte 0
player_y:     .byte 0
old_x:        .byte 0
old_y:        .byte 0
target_x:     .byte 0
target_y:     .byte 0
direction:    .byte 0
jump_step:    .byte 0
won_level:    .byte 0
solid_flag:   .byte 0
cursor_col:   .byte 0
cursor_row:   .byte 0
digit:        .byte 0
draw_char:    .byte 0
rows_left:    .byte 0
cols_left:    .byte 0

row_pointers:
        .word level_map+0,level_map+79,level_map+158,level_map+237
        .word level_map+316,level_map+395,level_map+474,level_map+553
        .word level_map+632,level_map+711,level_map+790,level_map+869
        .word level_map+948,level_map+1027,level_map+1106,level_map+1185
        .word level_map+1264,level_map+1343,level_map+1422,level_map+1501
level_map:
        .include "easy_street.inc"
