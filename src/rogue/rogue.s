; A small Rogue-like exploration game for C68 FLEX and an ANSI terminal.
; Each 60 by 20 floor has nine bounded, independently varied rooms.
        .equ outch, 0xad0f
        .equ outhex, 0xad3c
        .equ warms, 0xad03
        .equ getc, 0xbf00
        .equ fms, 0xb406
        .equ width, 60
        .equ map_cells, 1200

        .org 0x0300
start:
        sts flex_sp
        clr depth
        clr gold
        clr arrival_slot
        jsr new_level
game_loop:
        jsr draw_map
        jsr getc               ; raw input avoids echo on cursor controls
        cmpa #'Q'
        bne not_upper_quit
        jmp quit
not_upper_quit:
        cmpa #'q'
        bne not_lower_quit
        jmp quit
not_lower_quit:
        cmpa #'>'
        bne try_move
        ldx player_index
        cpx stairs_index
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
        beq game_loop
        dec next_x
        dex
        bra check_move
not_left:
        cmpa #'l'
        bne not_right
        ldaa player_x
        cmpa #59
        beq game_loop
        inc next_x
        inx
        bra check_move
not_right:
        cmpa #'k'
        bne not_up
        tst player_y
        beq game_loop
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
        jmp game_loop
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
        ldx #map
        ldaa candidate+1
        adda #<map
        staa cell_ptr+1
        ldaa candidate
        adca #>map
        staa cell_ptr
        ldx cell_ptr
        ldaa 0,x
        cmpa #'.'
        beq walked
        cmpa #'#'
        beq walked
        cmpa #'+'
        beq walked
        cmpa #'%'
        beq walked
        cmpa #'<'
        beq walked
        cmpa #'*'
        bne blocked
        inc gold
        ldaa #'.'
        staa 0,x
walked:
        ldx candidate
        stx player_index
        ldaa next_x
        staa player_x
        ldaa next_y
        staa player_y
        jmp game_loop
blocked:
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

; Load the immutable floor record from drive 1. On a load error, leave the
; dungeon cleanly rather than letting an incomplete map become playable.
new_level:
        inc depth
        jsr load_floor
        bcs floor_load_failed
        jsr reset_view
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

reset_view:
        ldx #seen
        stx seen_ptr
        ldx #display
        stx display_ptr
        ldx #map_cells
        stx remaining
reset_view_loop:
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
        ldx #map
        stx cell_ptr
        ldx #seen
        stx seen_ptr
        ldx #display
        stx display_ptr
        clr row
draw_row:
        clr col
draw_col:
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
        ldx seen_ptr
        ldaa #1
        staa 0,x
old_seen:
        ldx seen_ptr
        tst 0,x
        beq draw_space
        ldx cell_ptr
        ldaa 0,x
        bra maybe_player
draw_space:
        ldaa #' '
maybe_player:
        staa tile
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
        ldx cell_ptr
        inx
        stx cell_ptr
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
        jmp print
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
version_text: .ascii "   v7"
        .byte 0
help_text: .ascii "h j k l move   > descend on %   Q quit"
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
seen:          .space map_cells,0
display:       .space map_cells,0
floor_fcb:     .space 320,0
app_end:
