; Draft VDEMO.CMD: first-light test for the 6845 video board.
; The serial ACIA remains FLEX's console. No video interrupts are used.
; DO NOT load on hardware until the updated processor and video GALs are
; installed. The mode latch resets with banked SRAM selected.
;
; Proposed video GAL map: strap the slot comparator to $4, then decode
; $E040/$E041 as 6845 address/data and $E042 as the write-only mode latch.
; Latch bit 0 selects VRAM when set, banked SRAM when clear.
; Bits 2-5 select font bank 1.

        .equ warms, 0xad03
        .equ crtc_index, 0xe040
        .equ crtc_data, 0xe041
        .equ video_mode, 0xe042
        .equ mode_bank, 0x04
        .equ mode_vram, 0x05
        .equ char_ram, 0xc000
        .equ attr_ram, 0xd000

        .org 0x0300
start:
        ; Keep SRAM mapped while setting the CRTC. Font 1 is IBM EGA 8x8.
        ldaa #mode_bank
        staa video_mode

        ; 2 MHz character clock / 128 chars = 15.625 kHz line frequency.
        ; (32 rows * 8 + 6) lines = 262 lines, about 59.64 Hz.
        ; 80 visible chars and 25 visible rows, 8 raster lines per char.
        ldaa #0
        ldab #127
        jsr crtc_write
        ldaa #1
        ldab #80
        jsr crtc_write
        ldaa #2
        ldab #96
        jsr crtc_write
        ldaa #3
        ldab #8
        jsr crtc_write
        ldaa #4
        ldab #31
        jsr crtc_write
        ldaa #5
        ldab #6
        jsr crtc_write
        ldaa #6
        ldab #25
        jsr crtc_write
        ldaa #7
        ldab #28
        jsr crtc_write
        ldaa #8
        ldab #0
        jsr crtc_write
        ldaa #9
        ldab #7
        jsr crtc_write
        ldaa #10
        ldab #0x20           ; Cursor disabled.
        jsr crtc_write
        ldaa #11
        ldab #7
        jsr crtc_write
        ldaa #12
        ldab #0
        jsr crtc_write
        ldaa #13
        ldab #0
        jsr crtc_write

        ; The CPU sees 2 KiB of characters at $C000 and attributes at
        ; $D000. Video page 0 is selected by mode bit 1 = 0.
        ldaa #mode_vram
        staa video_mode
        ldx #char_ram
        ldaa #' '
clear_chars:
        staa 0,x
        inx
        cpx #0xc800
        bne clear_chars
        ldx #attr_ram
        ldaa #0x1F           ; Bright white foreground, blue background.
clear_attrs:
        staa 0,x
        inx
        cpx #0xd800
        bne clear_attrs

        ; A literal line makes the character/font path easy to inspect.
        ldx #char_ram+162    ; Row 2, column 2 (zero based).
        ldaa #'C'
        jsr put_char
        ldaa #'6'
        jsr put_char
        ldaa #'8'
        jsr put_char
        ldaa #' '
        jsr put_char
        ldaa #'V'
        jsr put_char
        ldaa #'I'
        jsr put_char
        ldaa #'D'
        jsr put_char
        ldaa #'E'
        jsr put_char
        ldaa #'O'
        jsr put_char
        ldaa #' '
        jsr put_char
        ldaa #'D'
        jsr put_char
        ldaa #'E'
        jsr put_char
        ldaa #'M'
        jsr put_char
        ldaa #'O'
        jsr put_char

        ldx #char_ram+400
        ldaa #'#'
swatch_chars:
        staa 0,x
        inx
        cpx #char_ram+480
        bne swatch_chars

        ; Eight ten-character swatches on row 5. The byte in RAM has
        ; foreground B/G/R/I in bits 0-3, background B/G/R/I in bits 4-7.
        ldx #attr_ram+400
        ldaa #0x01           ; Blue
        jsr swatch
        ldaa #0x02           ; Green
        jsr swatch
        ldaa #0x04           ; Red
        jsr swatch
        ldaa #0x03           ; Cyan
        jsr swatch
        ldaa #0x05           ; Magenta
        jsr swatch
        ldaa #0x06           ; Yellow
        jsr swatch
        ldaa #0x07           ; White
        jsr swatch
        ldaa #0x0F           ; Bright white
        jsr swatch

        ; Restore the SRAM disk window before FLEX reads another sector.
        ldaa #mode_bank
        staa video_mode
        jmp warms

crtc_write:
        staa crtc_index
        stab crtc_data
        rts

put_char:
        staa 0,x
        inx
        rts

swatch:
        ldab #10
swatch_next:
        staa 0,x
        inx
        decb
        bne swatch_next
        rts
