; Seven Ladder boards for C68 FLEX and an ANSI/VT100 terminal.
; Terrain is generated from Pascal layouts with original-game corrections.
; Movement follows the probed original CP/M Ladder rules.
; SPDX-License-Identifier: GPL-3.0-only
; Crankery's original C68 additions are also MIT licensed; see LICENSE-MIT.
        .equ outch, 0xad0f
        .equ warms, 0xad03
        .equ getc, 0xbf00
        .equ poll, 0xbf2a
        .equ fms, 0xb406
        .equ flex_date, 0xac0e
        .equ command_drive, 0xa843

        .org 0x0300
start:
        sts saved_sp
        jsr highscore_init
        ldaa #1
        staa play_speed
        staa selected_level
        ldx #24000
        stx tick_delay
menu_entry:
        jsr start_screen
new_game:
        ldaa #5
        staa lives
        clr score
        clr score+1
        jsr restore_statues
        ldaa selected_level
        staa level_number
        clr game_over
        jsr start_level
game_loop:
        ldx tick_delay         ; approximate game tick; tune on hardware
tick_wait:
        dex
        bne tick_wait
        tst game_over
        bne input_poll
        jsr move_player
        tst death_flag
        bne game_restart
        jsr check_player_rocks
        tst death_flag
        bne game_restart
        jsr move_rocks
        tst death_flag
        beq input_poll
game_restart:
        jsr restart_after_death
        tst game_over
        beq input_poll
        lds saved_sp
        jmp menu_entry
input_poll:
        jsr poll
        bcc game_loop
        jsr getc
        jsr handle_key
        bra game_loop

start_level:
        clr direction
        clr jump_step
        clr won_level
        clr death_flag
        ldx #level_configs
        ldab level_number
        decb
level_config_next:
        tstb
        beq level_config_found
        inx
        inx
        inx
        inx
        inx
        inx
        inx
        inx
        inx
        inx
        decb
        bra level_config_next
level_config_found:
        stx active_config
        ldaa 0,x
        staa active_map
        ldaa 1,x
        staa active_map+1
        ldaa 2,x
        staa active_rows
        ldaa 3,x
        staa active_rows+1
        ldaa 4,x
        staa active_status
        ldaa 5,x
        staa active_status+1
        ldaa 8,x
        staa rock_limit
        ldaa 9,x
        staa bonus_points
        jsr init_rocks
        ldx #clear_text
        jsr print
        jsr draw_level
        jsr reset_player
        jsr draw_player
        jsr show_lives
        jsr show_score
        rts

reset_player:
        ldx active_config
        ldaa 6,x
        staa player_x
        ldaa 7,x
        staa player_y
        clr direction
        clr jump_step
        rts

handle_key:
        cmpa #'q'
        beq quit_to_menu
        cmpa #'Q'
        beq quit_to_menu
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
quit_to_menu:
        lds saved_sp
        jmp menu_entry
quit:
        ldx #exit_text
        jsr print
        lds saved_sp
        jmp warms

        .include "menu.inc"
        .include "highscore.inc"

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
        cmpa #'&'
        beq statue_collected
        cmpa #'^'
        beq fire_reset
        rts
level_done:
        jsr show_hooka
        jsr add_bonus
        ldaa level_number
        cmpa #7
        bcc final_treasure
        inc level_number
        jsr start_level
        rts
final_treasure:
        clr direction
        clr jump_step
        ldaa #1
        staa won_level
        ldx #win_text
        jsr print_at_prompt
        rts
statue_collected:
        ldx target_ptr
        ldaa #' '
        staa 0,x
        jmp add_bonus
fire_reset:
        ldaa #1
        staa death_flag
        rts

restart_after_death:
        clr death_flag
        jsr animate_death
        dec lives
        tst lives
        beq restart_game_over
        jsr home_cursor
        jsr draw_level
        jsr show_lives
        jsr show_score
restart_active:
        jsr init_rocks
        jsr reset_player
        jmp draw_player
restart_game_over:
        jsr show_lives
        ldaa #1
        staa game_over
        jsr highscore_finish
        ldx #game_over_text
        jsr print_at_prompt
        ldab #6
game_over_pause:
        jsr death_pause
        decb
        bne game_over_pause
        rts

; The Pascal death sequence twists Lad through eleven glyphs before restart.
; At the throttled 1 MHz CPU rate, each delay is about 150 ms.
animate_death:
        ldx #death_glyphs
        stx death_ptr
death_glyph_loop:
        ldx death_ptr
        ldaa 0,x
        beq death_glyph_done
        staa death_char
        ldaa player_x
        staa cursor_col
        ldaa player_y
        staa cursor_row
        jsr cursor_to
        ldaa death_char
        jsr outch
        jsr death_pause
        ldx death_ptr
        inx
        stx death_ptr
        bra death_glyph_loop
death_glyph_done:
        rts
death_pause:
        ldx #20000
death_pause_loop:
        dex
        bne death_pause_loop
        rts

; The original treasure tally flashes "Hooka!" while paying bonus points.
; This port awards the bonus at once, so show one short flash before advancing.
show_hooka:
        ldx #hooka_text
        jsr print_at_prompt
        jsr death_pause
        ldx #hooka_clear_text
        jmp print_at_prompt

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
        ldx active_rows
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
        stx target_ptr
        ldaa 0,x
        rts

        .include "rocks.inc"

draw_level:
        ldx active_map
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
        ldx active_status
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
home_cursor:
        ldaa #27
        jsr outch
        ldaa #'['
        jsr outch
        ldaa #'H'
        jmp outch
show_lives:
        ldaa #21
        staa cursor_row
        ldaa #64
        staa cursor_col
        jsr cursor_to
        ldx #lives_text
        jsr print
        ldaa lives
        adda #'0'
        jmp outch
add_bonus:
        ldaa score+1
        adda bonus_points
        staa score+1
        ldaa score
        adca #0
        staa score
        jmp show_score
show_score:
        ldaa #21
        staa cursor_row
        ldaa #30
        staa cursor_col
        jsr cursor_to
        ldx #score_text
        jsr print
        ldx score
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
        jmp score_digit
score_digit:
        stx score_divisor
        clr digit
score_digit_loop:
        ldaa score_work+1
        suba score_divisor+1
        staa score_low_tmp
        ldaa score_work
        sbca score_divisor
        bcs score_digit_print
        staa score_work
        ldaa score_low_tmp
        staa score_work+1
        inc digit
        bra score_digit_loop
score_digit_print:
        ldaa digit
        adda #'0'
        jmp outch

; Restore collected statues when a new game starts. Life restarts keep them
; removed, along with the score already earned.
restore_statues:
        ldx #statue_addresses
        stx restore_cursor
        ldaa #28
        staa restore_count
restore_statue_next:
        ldx restore_cursor
        ldaa 0,x
        staa target_ptr
        ldaa 1,x
        staa target_ptr+1
        inx
        inx
        stx restore_cursor
        ldx target_ptr
        ldaa #'&'
        staa 0,x
        dec restore_count
        bne restore_statue_next
        rts
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
easy_status_text:
        .ascii "Easy Street   "
        .byte 0
long_status_text:
        .ascii "Long Island   "
        .byte 0
ghost_status_text:
        .ascii "Ghost Town   "
        .byte 0
tunnel_status_text:
        .ascii "Tunnel Vision   "
        .byte 0
point_status_text:
        .ascii "Point of No Return   "
        .byte 0
bug_status_text:
        .ascii "Bug City   "
        .byte 0
gang_status_text:
        .ascii "GangLand   "
        .byte 0
win_text:
        .ascii "You found the treasure! Press Q for menu.              "
        .byte 0
hooka_text:
        .ascii "Hooka!"
        .byte 0
hooka_clear_text:
        .ascii "      "
        .byte 0
game_over_text:
        .ascii "Game over. Returning to menu...                        "
        .byte 0
death_glyphs:
        .ascii "pbdqpbdq--_"
        .byte 0
lives_text:
        .ascii "Lads: "
        .byte 0
score_text:
        .ascii "Score: "
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
game_over:    .byte 0
death_flag:   .byte 0
lives:        .byte 0
score:        .word 0
bonus_points: .byte 0
score_work:   .word 0
score_divisor: .word 0
score_low_tmp: .byte 0
restore_count: .byte 0
restore_cursor: .word 0
target_ptr:   .word 0
level_number: .byte 0
selected_level: .byte 1
rock_limit:   .byte 0
active_map:   .word 0
active_rows:  .word 0
active_status: .word 0
active_config: .word 0
play_speed:   .byte 1
tick_delay:   .word 24000
menu_action:  .byte 0
menu_idle_state: .byte 0
menu_idle_count: .word 0
death_ptr:    .word 0
death_char:   .byte 0
solid_flag:   .byte 0
cursor_col:   .byte 0
cursor_row:   .byte 0
digit:        .byte 0
draw_char:    .byte 0
rows_left:    .byte 0
cols_left:    .byte 0

rock_count:   .byte 0
rock_slot:    .byte 0
rock_skip:    .byte 0
rock_ptr:     .word 0
rock_x:       .byte 0
rock_y:       .byte 0
rock_state:   .byte 0
rng_old0:     .byte 0
rng_old1:     .byte 0
rng_old2:     .byte 0
rng0:         .byte 0x11
rng1:         .byte 0x22
rng2:         .byte 0x33
rock_slots:   .byte 0,0,0,0,0,0,0,0,0,0,0,0
              .byte 0,0,0,0,0,0,0,0,0,0,0,0

; Map pointer, row pointer table, status text, player X/Y, rock limit, bonus.
level_configs:
        .word level_map,row_pointers,easy_status_text
        .byte 6,19,5,35
        .word long_island_map,long_island_rows,long_status_text
        .byte 18,19,8,45
        .word ghost_town_map,ghost_town_rows,ghost_status_text
        .byte 6,3,5,35
        .word tunnel_vision_map,tunnel_vision_rows,tunnel_status_text
        .byte 77,17,5,36
        .word point_of_no_return_map,point_of_no_return_rows,point_status_text
        .byte 74,4,7,35
        .word bug_city_map,bug_city_rows,bug_status_text
        .byte 34,9,6,37
        .word gangland_map,gangland_rows,gang_status_text
        .byte 7,3,6,32

statue_addresses:
        .word level_map+(8*79+16)
        .word long_island_map+(1*79+67),long_island_map+(6*79+25)
        .word ghost_town_map+(5*79+41),ghost_town_map+(9*79+62)
        .word ghost_town_map+(11*79+13)
        .word tunnel_vision_map+(4*79+37),tunnel_vision_map+(4*79+38)
        .word tunnel_vision_map+(9*79+27),tunnel_vision_map+(12*79+58)
        .word point_of_no_return_map+(4*79+9),point_of_no_return_map+(11*79+18)
        .word point_of_no_return_map+(12*79+46),point_of_no_return_map+(15*79+30)
        .word point_of_no_return_map+(15*79+52)
        .word bug_city_map+(8*79+45),bug_city_map+(10*79+22)
        .word bug_city_map+(11*79+22),bug_city_map+(12*79+7)
        .word bug_city_map+(14*79+51),bug_city_map+(15*79+44)
        .word gangland_map+(2*79+49),gangland_map+(5*79+60)
        .word gangland_map+(7*79+23),gangland_map+(7*79+24)
        .word gangland_map+(7*79+29),gangland_map+(16*79+53)
        .word gangland_map+(18*79+27)

row_pointers:
        .word level_map+0,level_map+79,level_map+158,level_map+237
        .word level_map+316,level_map+395,level_map+474,level_map+553
        .word level_map+632,level_map+711,level_map+790,level_map+869
        .word level_map+948,level_map+1027,level_map+1106,level_map+1185
        .word level_map+1264,level_map+1343,level_map+1422,level_map+1501
level_map:
        .include "easy_street.inc"
long_island_rows:
        .word long_island_map+0,long_island_map+79,long_island_map+158,long_island_map+237
        .word long_island_map+316,long_island_map+395,long_island_map+474,long_island_map+553
        .word long_island_map+632,long_island_map+711,long_island_map+790,long_island_map+869
        .word long_island_map+948,long_island_map+1027,long_island_map+1106,long_island_map+1185
        .word long_island_map+1264,long_island_map+1343,long_island_map+1422,long_island_map+1501
long_island_map:
        .include "long_island.inc"
ghost_town_rows:
        .word ghost_town_map+0,ghost_town_map+79,ghost_town_map+158,ghost_town_map+237
        .word ghost_town_map+316,ghost_town_map+395,ghost_town_map+474,ghost_town_map+553
        .word ghost_town_map+632,ghost_town_map+711,ghost_town_map+790,ghost_town_map+869
        .word ghost_town_map+948,ghost_town_map+1027,ghost_town_map+1106,ghost_town_map+1185
        .word ghost_town_map+1264,ghost_town_map+1343,ghost_town_map+1422,ghost_town_map+1501
ghost_town_map:
        .include "ghost_town.inc"
tunnel_vision_rows:
        .word tunnel_vision_map+0,tunnel_vision_map+79,tunnel_vision_map+158,tunnel_vision_map+237
        .word tunnel_vision_map+316,tunnel_vision_map+395,tunnel_vision_map+474,tunnel_vision_map+553
        .word tunnel_vision_map+632,tunnel_vision_map+711,tunnel_vision_map+790,tunnel_vision_map+869
        .word tunnel_vision_map+948,tunnel_vision_map+1027,tunnel_vision_map+1106,tunnel_vision_map+1185
        .word tunnel_vision_map+1264,tunnel_vision_map+1343,tunnel_vision_map+1422,tunnel_vision_map+1501
tunnel_vision_map:
        .include "tunnel_vision.inc"
point_of_no_return_rows:
        .word point_of_no_return_map+0,point_of_no_return_map+79,point_of_no_return_map+158,point_of_no_return_map+237
        .word point_of_no_return_map+316,point_of_no_return_map+395,point_of_no_return_map+474,point_of_no_return_map+553
        .word point_of_no_return_map+632,point_of_no_return_map+711,point_of_no_return_map+790,point_of_no_return_map+869
        .word point_of_no_return_map+948,point_of_no_return_map+1027,point_of_no_return_map+1106,point_of_no_return_map+1185
        .word point_of_no_return_map+1264,point_of_no_return_map+1343,point_of_no_return_map+1422,point_of_no_return_map+1501
point_of_no_return_map:
        .include "point_of_no_return.inc"
bug_city_rows:
        .word bug_city_map+0,bug_city_map+79,bug_city_map+158,bug_city_map+237
        .word bug_city_map+316,bug_city_map+395,bug_city_map+474,bug_city_map+553
        .word bug_city_map+632,bug_city_map+711,bug_city_map+790,bug_city_map+869
        .word bug_city_map+948,bug_city_map+1027,bug_city_map+1106,bug_city_map+1185
        .word bug_city_map+1264,bug_city_map+1343,bug_city_map+1422,bug_city_map+1501
bug_city_map:
        .include "bug_city.inc"
gangland_rows:
        .word gangland_map+0,gangland_map+79,gangland_map+158,gangland_map+237
        .word gangland_map+316,gangland_map+395,gangland_map+474,gangland_map+553
        .word gangland_map+632,gangland_map+711,gangland_map+790,gangland_map+869
        .word gangland_map+948,gangland_map+1027,gangland_map+1106,gangland_map+1185
        .word gangland_map+1264,gangland_map+1343,gangland_map+1422,gangland_map+1501
gangland_map:
        .include "gangland.inc"
