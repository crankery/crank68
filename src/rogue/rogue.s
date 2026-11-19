; A small Rogue-like exploration game for C68 FLEX and an ANSI terminal.
; Each 60 by 20 floor has nine bounded, independently varied rooms.
        .equ outch, 0xad0f
        .equ outhex, 0xad3c
        .equ warms, 0xad03
        .equ getc, 0xbf00
        .equ fms, 0xb406
        .equ flex_ticks, 0xbff8
        .equ width, 60
        .equ map_cells, 1200

        .org 0x0300
start:
        sts flex_sp
        clr depth
        clr gold
        clr arrival_slot
        clr running
        ldaa #1
        staa inventory_item      ; the starter pocket lint
        jsr seed_rng
        jsr new_level
game_loop:
        jsr draw_map
        tst running
        beq read_command
        ldaa run_key
        bra have_command
read_command:
        jsr getc               ; raw input avoids echo on cursor controls
have_command:
        cmpa #'Q'
        bne not_upper_quit
        jmp quit
not_upper_quit:
        cmpa #'q'
        bne not_lower_quit
        jmp quit
not_lower_quit:
        cmpa #'i'
        bne not_inventory
        jmp show_inventory
not_inventory:
        cmpa #'?'
        bne not_help
        jmp show_help
not_help:
        cmpa #'H'
        bne not_run_left
        ldaa #'h'
        bra start_run
not_run_left:
        cmpa #'J'
        bne not_run_down
        ldaa #'j'
        bra start_run
not_run_down:
        cmpa #'K'
        bne not_run_up
        ldaa #'k'
        bra start_run
not_run_up:
        cmpa #'L'
        bne not_run_right
        ldaa #'l'
start_run:
        staa run_key
        ldaa #1
        staa running
        ldaa run_key
        jmp try_move
not_run_right:
        cmpa #'>'
        bne try_move
        ldx player_index
        jsr object_address
        ldaa 0,x
        cmpa #'%'
        bne game_loop
        ldaa depth
        cmpa #26
        beq game_loop
        ldaa stairs_room
        staa arrival_slot
        jsr new_level
        bra game_loop
try_move:
        staa key
        ldx player_index
        stx candidate
        ldaa key
        cmpa #'h'
        bne not_left
        tst player_x
        bne left_inside
        jmp blocked
left_inside:
        dec next_x
        dex
        bra check_move
not_left:
        cmpa #'l'
        bne not_right
        ldaa player_x
        cmpa #59
        bne right_inside
        jmp blocked
right_inside:
        inc next_x
        inx
        bra check_move
not_right:
        cmpa #'k'
        bne not_up
        tst player_y
        bne up_inside
        jmp blocked
up_inside:
        dec next_y
        ldaa candidate+1
        suba #width
        staa candidate+1
        ldaa candidate
        sbca #0
        staa candidate
        ldx candidate
        bra check_move
not_up:
        cmpa #'j'
        beq down_key
        jmp game_loop
down_key:
        ldaa player_y
        cmpa #19
        bne down_can_move
        jmp blocked
down_can_move:
        inc next_y
        ldaa candidate+1
        adda #width
        staa candidate+1
        ldaa candidate
        adca #0
        staa candidate
        ldx candidate
check_move:
        stx candidate
        ldx #terrain
        ldaa candidate+1
        adda #<terrain
        staa cell_ptr+1
        ldaa candidate
        adca #>terrain
        staa cell_ptr
        ldx cell_ptr
        ldaa 0,x
        staa terrain_tile
        cmpa #'.'
        beq walked
        cmpa #'#'
        beq walked
        cmpa #'+'
        beq walked
        bne blocked
walked:
        ldx candidate
        jsr actor_address
        ldaa 0,x
        beq no_actor
        cmpa #'K'
        beq blocked_by_kobold
        ldx #bat_block_message
        jsr post_message
        bra blocked
blocked_by_kobold:
        ldx #kobold_block_message
        jsr post_message
        bra blocked
no_actor:
        ldx candidate
        jsr object_address
        ldaa 0,x
        staa target_object
        cmpa #'*'
        bne no_gold
        inc gold
        clr 0,x
        ldx #gold_message
        jsr post_message
no_gold:
        ldx candidate
        stx player_index
        ldaa next_x
        staa player_x
        ldaa next_y
        staa player_y
        tst running
        beq movement_done
        tst target_object
        bne stop_run
        ldaa terrain_tile
        cmpa #'+'
        bne movement_done
stop_run:
        clr running
movement_done:
        jsr kobold_turn
        jmp game_loop
blocked:
        clr running
        ldaa player_x
        staa next_x
        ldaa player_y
        staa next_y
        jmp game_loop
quit:
        ldx #leave_text
        jsr print
        lds flex_sp
        jmp warms

; Inventory and help temporarily replace the map. Clearing only the drawing
; cache on return preserves explored cells and all game state.
show_inventory:
        ldx #inventory_heading
        jsr begin_page
        tst inventory_item
        beq inventory_empty
        ldx #lint_line
        bra inventory_line
inventory_empty:
        ldx #empty_line
inventory_line:
        jsr print
        ldx #page_footer
        jmp finish_page
show_help:
        ldx #help_page
        jsr begin_page
        ldx #page_footer
        jmp finish_page
begin_page:
        stx page_ptr
        ldx #clear_text
        jsr print
        ldx page_ptr
        jmp print
finish_page:
        jsr print
        jsr getc
        ldx #clear_text
        jsr print
        jsr invalidate_display
        jmp game_loop
invalidate_display:
        ldx #display
        stx display_ptr
        ldx #map_cells
        stx remaining
invalidate_next:
        ldx display_ptr
        ldaa #' '
        staa 0,x
        inx
        stx display_ptr
        ldx remaining
        dex
        stx remaining
        bne invalidate_next
        rts

; Load the immutable floor record from drive 1. On a load error, leave the
; dungeon cleanly rather than letting an incomplete map become playable.
new_level:
        inc depth
        jsr load_floor
        bcs floor_load_failed
        jsr reset_view
        jsr spawn_bat
        jsr spawn_kobold
        ldx #floor_message
        jsr post_message
        rts
floor_load_failed:
        ldx #load_error_text
        jsr print
        lds flex_sp
        jmp warms

load_floor:
        ldx #floor_fcb
        ldab #0
clear_fcb_first:
        clr 0,x
        inx
        decb
        bne clear_fcb_first
        ldab #64
clear_fcb_tail:
        clr 0,x
        inx
        decb
        bne clear_fcb_tail
        ldaa #1
        staa floor_fcb+3        ; data drive
        ldaa #'R'
        staa floor_fcb+4
        ldaa #'F'
        staa floor_fcb+5
        ldaa #'L'
        staa floor_fcb+6
        ldaa depth
        ldab #'0'
floor_tens:
        cmpa #10
        bcs floor_digits
        suba #10
        incb
        bra floor_tens
floor_digits:
        stab floor_fcb+7
        adda #'0'
        staa floor_fcb+8
        ldaa #'D'
        staa floor_fcb+12
        ldaa #'A'
        staa floor_fcb+13
        ldaa #'T'
        staa floor_fcb+14
        ldaa #1
        staa floor_fcb
        ldx #floor_fcb
        jsr fms
        beq load_continue_0
        jmp load_open_failed
load_continue_0:
        ldaa #0xff
        staa floor_fcb+59      ; raw binary data
        clr checksum
        jsr read_raw
        bcc load_continue_1
        jmp load_bad
load_continue_1:
        cmpa #'R'
        beq load_continue_2
        jmp load_bad
load_continue_2:
        jsr read_raw
        bcc load_continue_3
        jmp load_bad
load_continue_3:
        cmpa #'F'
        beq load_continue_4
        jmp load_bad
load_continue_4:
        jsr read_raw
        bcc load_continue_5
        jmp load_bad
load_continue_5:
        cmpa #'L'
        beq load_continue_6
        jmp load_bad
load_continue_6:
        jsr read_raw
        bcc load_continue_7
        jmp load_bad
load_continue_7:
        cmpa #'1'
        beq load_continue_8
        jmp load_bad
load_continue_8:
        jsr read_data
        bcc load_continue_9
        jmp load_bad
load_continue_9:
        cmpa depth
        beq load_continue_10
        jmp load_bad
load_continue_10:
        jsr read_data
        bcc load_continue_11
        jmp load_bad
load_continue_11:
        cmpa arrival_slot
        beq load_continue_12
        jmp load_bad
load_continue_12:
        jsr read_data
        bcc load_continue_13
        jmp load_bad
load_continue_13:
        cmpa #9
        bcs load_continue_14
        jmp load_bad
load_continue_14:
        cmpa arrival_slot
        bne load_continue_15
        jmp load_bad
load_continue_15:
        staa stairs_room
        ldx #rooms
        stx room_ptr
        ldaa #54
        staa count
load_rooms:
        jsr read_data
        bcc load_continue_16
        jmp load_bad
load_continue_16:
        ldx room_ptr
        staa 0,x
        inx
        stx room_ptr
        dec count
        bne load_rooms
        ldx #map
        stx cell_ptr
        ldx #map_cells
        stx remaining
load_map:
        jsr read_data
        bcc load_continue_17
        jmp load_bad
load_continue_17:
        ldx cell_ptr
        staa 0,x
        inx
        stx cell_ptr
        ldx remaining
        dex
        stx remaining
        bne load_map
        jsr read_raw
        bcc load_continue_18
        jmp load_bad
load_continue_18:
        cmpa checksum
        beq load_continue_19
        jmp load_bad
load_continue_19:
        ldaa #4
        staa floor_fcb
        ldx #floor_fcb
        jsr fms
        beq load_continue_20
        jmp load_open_failed
load_continue_20:
        ldaa arrival_slot
        jsr place_room_center
        ldx point_index
        stx up_index
        stx player_index
        ldaa col
        staa player_x
        staa next_x
        ldaa row
        staa player_y
        staa next_y
        ldaa stairs_room
        jsr place_room_center
        ldx point_index
        stx stairs_index
        jsr split_map
        clc
        rts
load_bad:
        ldaa #4
        staa floor_fcb
        ldx #floor_fcb
        jsr fms
load_open_failed:
        sec
        rts

read_raw:
        clr floor_fcb
        ldx #floor_fcb
        jsr fms
        beq read_raw_ok
        sec
        rts
read_raw_ok:
        clc
        rts
read_data:
        jsr read_raw
        bcs read_data_done
        staa load_byte
        eora checksum
        staa checksum
        ldaa load_byte
        clc
read_data_done:
        rts

; Convert the immutable floor record into independent terrain and object
; layers. Objects may change during play without altering the floor layout.
split_map:
        ldx #map
        stx source_ptr
        ldx #terrain
        stx terrain_ptr
        ldx #objects
        stx object_ptr
        ldx #map_cells
        stx remaining
split_map_next:
        ldx source_ptr
        ldaa 0,x
        inx
        stx source_ptr
        cmpa #'*'
        beq split_map_object
        cmpa #'%'
        beq split_map_object
        cmpa #'<'
        bne split_map_terrain
split_map_object:
        ldx object_ptr
        staa 0,x
        ldaa #'.'
        bra split_map_store
split_map_terrain:
        ldx object_ptr
        clr 0,x
split_map_store:
        ldx terrain_ptr
        staa 0,x
        inx
        stx terrain_ptr
        ldx object_ptr
        inx
        stx object_ptr
        ldx remaining
        dex
        stx remaining
        bne split_map_next
        rts

; Input X = map offset. Output X = address of its object cell.
object_address:
        stx object_index
        ldaa object_index+1
        adda #<objects
        staa object_index+1
        ldaa object_index
        adca #>objects
        staa object_index
        ldx object_index
        rts

; Input X = map offset. Output X = address of its actor cell.
actor_address:
        stx actor_index
        ldaa actor_index+1
        adda #<actors
        staa actor_index+1
        ldaa actor_index
        adca #>actors
        staa actor_index
        ldx actor_index
        rts

; FLEX increments C68TICKS while polling serial input. A nonzero seed is
; required because the LFSR's zero state cannot advance.
seed_rng:
        ldaa flex_ticks
        staa rng_state
        ldaa flex_ticks+1
        staa rng_state+1
        oraa rng_state
        bne seed_rng_done
        ldaa #0x68
        staa rng_state
        ldaa #0x01
        staa rng_state+1
seed_rng_done:
        rts

; 16-bit maximal-length Galois LFSR, right shift with tap mask $B400.
; Returns the low byte in A; deterministic tests can set rng_state directly.
rng_next:
        lsr rng_state
        ror rng_state+1
        bcc rng_next_done
        ldaa rng_state
        eora #0xb4
        staa rng_state
rng_next_done:
        ldaa rng_state+1
        rts

; Put one stationary bat in the first room that contains neither stair.
; The cell right of the room centre is always interior and unoccupied.
spawn_bat:
        clr bat_room
find_bat_room:
        ldaa bat_room
        cmpa arrival_slot
        beq skip_bat_room
        cmpa stairs_room
        bne place_bat
skip_bat_room:
        inc bat_room
        bra find_bat_room
place_bat:
        jsr room_address
        ldaa 4,x
        inca
        staa col
        ldaa 5,x
        staa row
        jsr cell_address
        ldx point_index
        stx bat_index
        jsr actor_address
        ldaa #'B'
        staa 0,x
        rts

; Keep one kobold in a different room from the player, stairs, and bat.
; It patrols that room until the player enters, then approaches one cell at
; a time. The room bounds keep doors and corridors clear before combat exists.
spawn_kobold:
        ldaa bat_room
        inca
        staa kobold_room
find_kobold_room:
        ldaa kobold_room
        cmpa arrival_slot
        beq skip_kobold_room
        cmpa stairs_room
        bne place_kobold
skip_kobold_room:
        inc kobold_room
        bra find_kobold_room
place_kobold:
        jsr room_address
        ldaa 4,x
        inca
        staa kobold_x
        staa col
        ldaa 5,x
        staa kobold_y
        staa row
        jsr cell_address
        ldx point_index
        stx kobold_index
        jsr actor_address
        ldaa #'K'
        staa 0,x
        jsr rng_next
        anda #1
        staa patrol_right
        rts

; Called once after each successful player step, including each run step.
kobold_turn:
        ldaa kobold_room
        jsr room_address
        ldaa 0,x
        inca
        staa k_left
        ldaa 1,x
        deca
        staa k_right
        ldaa 2,x
        inca
        staa k_top
        ldaa 3,x
        deca
        staa k_bottom
        ldaa kobold_x
        staa next_k_x
        ldaa kobold_y
        staa next_k_y
        ldaa player_x
        cmpa k_left
        bcs kobold_patrol
        cmpa k_right
        bhi kobold_patrol
        ldaa player_y
        cmpa k_top
        bcs kobold_patrol
        cmpa k_bottom
        bhi kobold_patrol
        ldaa player_x
        cmpa kobold_x
        bcs kobold_chase_left
        bhi kobold_chase_right
        ldaa player_y
        cmpa kobold_y
        bcs kobold_chase_up
        bhi kobold_chase_down
        rts
kobold_chase_left:
        dec next_k_x
        bra kobold_try_step
kobold_chase_right:
        inc next_k_x
        bra kobold_try_step
kobold_chase_up:
        dec next_k_y
        bra kobold_try_step
kobold_chase_down:
        inc next_k_y
        bra kobold_try_step
kobold_patrol:
        tst patrol_right
        beq kobold_patrol_left
        ldaa kobold_x
        cmpa k_right
        bne kobold_patrol_right
        clr patrol_right
        bra kobold_patrol_left
kobold_patrol_right:
        inc next_k_x
        bra kobold_try_step
kobold_patrol_left:
        ldaa kobold_x
        cmpa k_left
        bne kobold_step_left
        ldaa #1
        staa patrol_right
        inc next_k_x
        bra kobold_try_step
kobold_step_left:
        dec next_k_x
kobold_try_step:
        ldaa next_k_x
        staa col
        ldaa next_k_y
        staa row
        jsr cell_address
        ldx point_index
        cpx player_index
        beq kobold_turn_done
        jsr actor_address
        tst 0,x
        bne kobold_turn_done
        ldx kobold_index
        jsr actor_address
        clr 0,x
        ldx point_index
        stx kobold_index
        jsr actor_address
        ldaa #'K'
        staa 0,x
        ldaa next_k_x
        staa kobold_x
        ldaa next_k_y
        staa kobold_y
kobold_turn_done:
        rts

; Four recent message pointers, newest first. Messages fit the 18-column
; sidebar and stay visible until newer messages push them out.
post_message:
        stx message_new
        ldx messages+4
        stx messages+6
        ldx messages+2
        stx messages+4
        ldx messages
        stx messages+2
        ldx message_new
        stx messages
        rts

reset_view:
        ldx #actors
        stx actor_ptr
        ldx #seen
        stx seen_ptr
        ldx #display
        stx display_ptr
        ldx #map_cells
        stx remaining
reset_view_loop:
        ldx actor_ptr
        clr 0,x
        inx
        stx actor_ptr
        ldx seen_ptr
        clr 0,x
        inx
        stx seen_ptr
        ldx display_ptr
        ldaa #' '
        staa 0,x
        inx
        stx display_ptr
        ldx remaining
        dex
        stx remaining
        bne reset_view_loop
        ldx #clear_text
        jmp print

; A room record is left, right, top, bottom, centre x, centre y.
; Input A = room number, output X = address of its six-byte record.
room_address:
        ldx #rooms
        tsta
        beq room_address_done
room_address_next:
        inx
        inx
        inx
        inx
        inx
        inx
        deca
        bne room_address_next
room_address_done:
        rts

place_room_center:
        jsr room_address
        ldaa 4,x
        staa col
        ldaa 5,x
        staa row
        jmp cell_address

; Input row/col. Return the map offset in point_index, and map address in X.
cell_address:
        ldx #row_offsets
        ldaa row
        beq cell_row_ready
cell_row_next:
        inx
        inx
        deca
        bne cell_row_next
cell_row_ready:
        ldaa 1,x
        adda col
        staa point_index+1
        ldaa 0,x
        adca #0
        staa point_index
        ldaa point_index+1
        adda #<map
        staa cell_ptr+1
        ldaa point_index
        adca #>map
        staa cell_ptr
        ldx cell_ptr
        rts

; Identify which generated room contains @, including its boundary doors.
find_room:
        clr room_active
        ldx #rooms
        ldab #9
find_next_room:
        ldaa player_x
        cmpa 0,x
        bcs find_skip_room
        cmpa 1,x
        bhi find_skip_room
        ldaa player_y
        cmpa 2,x
        bcs find_skip_room
        cmpa 3,x
        bhi find_skip_room
        ldaa 0,x
        staa room_left
        ldaa 1,x
        staa room_right
        ldaa 2,x
        staa room_top
        ldaa 3,x
        staa room_bottom
        inc room_active
        rts
find_skip_room:
        inx
        inx
        inx
        inx
        inx
        inx
        decb
        bne find_next_room
        rts

; Compare against the terminal image and send only changed cells. Entering a
; room reveals all of it; corridors reveal a 3x3 neighborhood around @.
draw_map:
        jsr find_room
        ldx #actors
        stx actor_ptr
        ldx #terrain
        stx terrain_ptr
        ldx #objects
        stx object_ptr
        ldx #seen
        stx seen_ptr
        ldx #display
        stx display_ptr
        clr row
draw_row:
        clr col
draw_col:
        clr visible_cell
        tst room_active
        beq corridor_visible
        ldaa row
        cmpa room_top
        bcs old_seen
        cmpa room_bottom
        bhi old_seen
        ldaa col
        cmpa room_left
        bcs old_seen
        cmpa room_right
        bhi old_seen
        bra reveal_cell
corridor_visible:
        ldaa row
        suba player_y
        bpl row_positive
        nega
row_positive:
        cmpa #2
        bcc old_seen
        ldaa col
        suba player_x
        bpl col_positive
        nega
col_positive:
        cmpa #2
        bcc old_seen
reveal_cell:
        inc visible_cell
        ldx seen_ptr
        ldaa #1
        staa 0,x
old_seen:
        ldx seen_ptr
        tst 0,x
        beq draw_space
        ldx terrain_ptr
        ldaa 0,x
        staa tile
        ldx object_ptr
        ldaa 0,x
        beq maybe_actor
        staa tile
maybe_actor:
        tst visible_cell
        beq maybe_player
        ldx actor_ptr
        ldaa 0,x
        beq maybe_player
        staa tile
        bra maybe_player
draw_space:
        ldaa #' '
        staa tile
maybe_player:
        ldaa row
        cmpa player_y
        bne draw_tile
        ldaa col
        cmpa player_x
        bne draw_tile
        ldaa #'@'
        staa tile
draw_tile:
        ldaa tile
        ldx display_ptr
        cmpa 0,x
        beq tile_unchanged
        staa 0,x
        jsr cursor_to_tile
        ldaa tile
        jsr outch
tile_unchanged:
        ldx terrain_ptr
        inx
        stx terrain_ptr
        ldx object_ptr
        inx
        stx object_ptr
        ldx actor_ptr
        inx
        stx actor_ptr
        ldx seen_ptr
        inx
        stx seen_ptr
        ldx display_ptr
        inx
        stx display_ptr
        inc col
        ldaa col
        cmpa #width
        beq row_finished
        jmp draw_col
row_finished:
        inc row
        ldaa row
        cmpa #20
        beq draw_done
        jmp draw_row
draw_done:
        ldaa #21
        staa cursor_row
        ldaa #1
        staa cursor_col
        jsr cursor_to
        ldx #status_text
        jsr print
        ldx #depth
        jsr outhex
        ldx #gold_text
        jsr print
        ldx #gold
        jsr outhex
        ldx #version_text
        jsr print
        ldaa #22
        staa cursor_row
        ldaa #1
        staa cursor_col
        jsr cursor_to
        ldx #help_text
        jsr print
        jmp draw_messages
draw_messages:
        ldaa #1
        staa cursor_row
        ldaa #62
        staa cursor_col
        jsr cursor_to
        ldx #message_heading
        jsr print
        ldaa #3
        staa message_row
        ldx #messages
        stx message_ptr
        ldaa #4
        staa count
draw_message_next:
        ldaa message_row
        staa cursor_row
        ldaa #62
        staa cursor_col
        jsr cursor_to
        ldx #message_blank
        jsr print
        ldaa message_row
        staa cursor_row
        jsr cursor_to
        ldx message_ptr
        ldx 0,x
        cpx #0
        beq draw_message_empty
        jsr print
draw_message_empty:
        ldx message_ptr
        inx
        inx
        stx message_ptr
        inc message_row
        dec count
        bne draw_message_next
        rts
cursor_to_tile:
        ldaa row
        inca
        staa cursor_row
        ldaa col
        inca
        staa cursor_col
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
        .ascii "[?25l"          ; hide cursor while playing
        .byte 27
        .ascii "[2J"
        .byte 27
        .ascii "[H"
        .byte 0
status_text: .ascii "Depth $"
        .byte 0
gold_text: .ascii "   Gold $"
        .byte 0
version_text: .ascii "   v14"
        .byte 0
help_text: .ascii "h j k l move  H J K L run  > descend  i inventory  ? help  Q quit"
        .byte 0
inventory_heading: .ascii "Inventory"
        .byte 13,10,13,10,0
lint_line: .ascii "a) pocket lint"
        .byte 13,10,0
empty_line: .ascii "Your pack is empty."
        .byte 13,10,0
help_page: .ascii "ROGUE Help"
        .byte 13,10,13,10
        .ascii "h  left     j  down     k  up     l  right"
        .byte 13,10
        .ascii "H J K L  run in that direction"
        .byte 13,10
        .ascii ">  descend while standing on %"
        .byte 13,10
        .ascii "i  inventory     ?  help     Q  quit"
        .byte 13,10,13,10
        .ascii "@  you          *  gold       %  downstairs"
        .byte 13,10
        .ascii "<  upstairs     B  stationary bat     K  kobold"
        .byte 13,10,13,10
        .ascii "Runs stop at walls, monsters, doors, stairs, and gold."
        .byte 13,10
        .ascii "Gold is collected automatically. Monsters block movement."
        .byte 13,10
        .ascii "Combat and item use are still to come."
        .byte 13,10,0
page_footer: .byte 13,10
        .ascii "Press any key to return."
        .byte 0
message_heading: .ascii "Messages"
        .byte 0
message_blank: .ascii "                  "
        .byte 0
floor_message: .ascii "Entered a floor."
        .byte 0
gold_message: .ascii "Picked up gold."
        .byte 0
bat_block_message: .ascii "A bat blocks you."
        .byte 0
kobold_block_message: .ascii "Kobold blocks you."
        .byte 0
leave_text: .byte 13,10
        .ascii "Leaving the dungeon."
        .byte 13,10,27
        .ascii "[?25h"          ; restore cursor for FLEX
        .byte 0
load_error_text: .byte 13,10,27
        .ascii "[?25hROGUE: cannot load floor file."
        .byte 13,10,0

row_offsets:
        .word 0,60,120,180,240,300,360,420,480,540
        .word 600,660,720,780,840,900,960,1020,1080,1140

flex_sp:       .word 0
room_ptr:      .word 0
cell_ptr:      .word 0
source_ptr:    .word 0
terrain_ptr:   .word 0
object_ptr:    .word 0
object_index:  .word 0
actor_ptr:     .word 0
actor_index:   .word 0
bat_index:     .word 0
bat_room:      .byte 0
kobold_index:  .word 0
kobold_room:   .byte 0
kobold_x:      .byte 0
kobold_y:      .byte 0
next_k_x:      .byte 0
next_k_y:      .byte 0
patrol_right:  .byte 0
rng_state:     .word 0
k_left:        .byte 0
k_right:       .byte 0
k_top:         .byte 0
k_bottom:      .byte 0
visible_cell:  .byte 0
message_new:   .word 0
message_ptr:   .word 0
messages:      .word 0,0,0,0
message_row:   .byte 0
page_ptr:      .word 0
inventory_item:.byte 0
running:       .byte 0
run_key:       .byte 0
terrain_tile:  .byte 0
target_object: .byte 0
seen_ptr:      .word 0
display_ptr:   .word 0
remaining:     .word 0
player_index:  .word 0
candidate:     .word 0
stairs_index:  .word 0
up_index:      .word 0
point_index:   .word 0
player_x:      .byte 0
player_y:      .byte 0
next_x:        .byte 0
next_y:        .byte 0
arrival_slot:  .byte 0
stairs_room:   .byte 0
count:         .byte 0
depth:         .byte 0
gold:          .byte 0
row:           .byte 0
col:           .byte 0
key:           .byte 0
tile:          .byte 0
cursor_row:    .byte 0
cursor_col:    .byte 0
digit:         .byte 0
checksum:      .byte 0
load_byte:     .byte 0
room_active:   .byte 0
room_left:     .byte 0
room_right:    .byte 0
room_top:      .byte 0
room_bottom:   .byte 0
rooms:         .space 54,0
map:           .space map_cells,0
terrain:       .space map_cells,0
objects:       .space map_cells,0
actors:        .space map_cells,0
seen:          .space map_cells,0
display:       .space map_cells,0
floor_fcb:     .space 320,0
app_end:
