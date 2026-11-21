; VERA display exercise for C68 FLEX. Run VERA at the FLEX prompt.
; Keyboard input comes from the keyboard AVR at $E080.
; The VERA adapter decodes A0-A4 and occupies a full 32-byte I/O window.
; Change only vera_base if the three board switches select another window.
        .equ vera_base, 0xe040
        .equ v_addr_l, vera_base+0
        .equ v_addr_m, vera_base+1
        .equ v_addr_h, vera_base+2
        .equ v_data0,  vera_base+3
        .equ v_ctrl,   vera_base+5
        .equ v_ien,    vera_base+6
        .equ v_video,  vera_base+9
        .equ v_hscale, vera_base+10
        .equ v_vscale, vera_base+11
        .equ v_l0_config, vera_base+13
        .equ v_l0_map,    vera_base+14
        .equ v_l0_tile,   vera_base+15
        .equ v_l0_vscroll_l, vera_base+18
        .equ v_l0_vscroll_h, vera_base+19
        .equ warms,      0xad03
        .equ pstrng,     0xad1e

        .org 0x0300
start:
        sts flex_sp
        jsr vera_init
        jsr keyboard_init
        ldx #hello
        jsr show_string
        ldx #serial_notice
        jsr pstrng
poll_input:
        jsr keyboard_getc
        cmpa #3                 ; Ctrl-C returns to FLEX.
        beq done
        staa input_char
        jsr term_putc
        ldaa input_char
        cmpa #13                ; keyboard Return sends CR alone
        bne poll_input
        ldaa #10
        jsr term_putc
        bra poll_input
done:
        lds flex_sp
        jmp warms

; Public entry points for a future MIKBUG/FLEX console glue layer:
; vera_init destroys A/B/X; term_putc takes a byte in A, destroys A/B/X.
vera_init:
        clr v_ctrl              ; ADDRSEL=0, DCSEL=0
        clr v_ien
        clr v_video             ; hide uninitialized map/font
        clr v_addr_l
        ldaa #0x80              ; font: VRAM $08000-$087FF
        staa v_addr_m
        ldaa #0x10              ; increment DATA0 address by one
        staa v_addr_h
        ldx #font
font_loop:
        ldaa 0,x
        staa v_data0
        inx
        cpx #font_end
        bne font_loop
        clr top_row
        clr cursor_row
        clr cursor_col
        ldaa #32
        staa clear_row_index
clear_map_loop:
        dec clear_row_index
        ldaa clear_row_index
        jsr clear_row
        tst clear_row_index
        bne clear_map_loop
        clr v_l0_map           ; map at VRAM $00000
        ldaa #0x40
        staa v_l0_tile         ; font at VRAM $08000, 8x8 tiles
        ldaa #0x20
        staa v_l0_config       ; 128x32 tile map, 1bpp text
        clr v_l0_vscroll_l
        clr v_l0_vscroll_h
        ldaa #0x80
        staa v_hscale          ; 80 columns at 8 pixels each
        ldaa #0x40
        staa v_vscale          ; double-height 8-pixel glyphs: 30 rows
        ldaa #0x11
        staa v_video           ; layer 0, VGA output
        rts

; A = physical map row (0..31). Only the visible 80 columns need clearing.
clear_row:
        clr v_addr_l
        staa v_addr_m
        ldaa #0x10
        staa v_addr_h
        ldab #80
clear_cells:
        ldaa #' '
        staa v_data0
        ldaa #0x0f            ; black background, white foreground
        staa v_data0
        decb
        bne clear_cells
        rts

; Put printable ASCII and the essential teletype controls on the screen.
term_putc:
        cmpa #13
        beq carriage_return
        cmpa #10
        beq line_feed
        cmpa #8
        beq backspace
        cmpa #127
        beq backspace
        cmpa #9
        beq tab_spaces
        cmpa #32
        blo put_done
        cmpa #127
        bhs put_done
        staa character
        ldaa cursor_col
        asla
        staa v_addr_l
        ldaa cursor_row
        adda top_row
        anda #31
        staa v_addr_m
        ldaa #0x10
        staa v_addr_h
        ldaa character
        staa v_data0
        ldaa #0x0f
        staa v_data0
        inc cursor_col
        ldaa cursor_col
        cmpa #80
        bne put_done
        clr cursor_col
        bra advance_row
carriage_return:
        clr cursor_col
put_done:
        rts
line_feed:
        clr cursor_col
advance_row:
        ldaa cursor_row
        cmpa #29
        beq scroll
        inc cursor_row
        rts
scroll:
        inc top_row
        ldaa top_row
        anda #31
        staa top_row
        asla
        asla
        asla
        staa v_l0_vscroll_l
        ldaa top_row
        adda #29
        anda #31
        jsr clear_row
        rts
backspace:
        tst cursor_col
        beq put_done
        dec cursor_col
        rts
tab_spaces:
        ldaa #' '
        jsr term_putc
        ldaa cursor_col
        anda #7
        bne tab_spaces
        rts

show_string:
        stx string_ptr
show_next:
        ldx string_ptr
        ldaa 0,x
        beq show_done
        inx
        stx string_ptr
        jsr term_putc
        bra show_next
show_done:
        rts

hello:  .ascii "C68 VERA terminal - matrix keyboard, Ctrl-C exits"
        .byte 13,10,13,10,0
serial_notice:
        .ascii "VERA display active; use matrix keyboard, Ctrl-C exits."
        .byte 4
flex_sp: .word 0
string_ptr: .word 0
character: .byte 0
input_char: .byte 0
top_row: .byte 0
cursor_row: .byte 0
cursor_col: .byte 0
clear_row_index: .byte 0
font:
        .incbin "font.bin"
font_end:

        .include "keyboard.s"
