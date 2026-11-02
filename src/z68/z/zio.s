; FLEX file interface. story_fcb belongs to Z68, never the system command FCB.
; GETFIL supplies the working drive if none is specified. Default extension DAT.
story_open:
        ldx #story_fcb
        ldab #0
story_clear:
        clr 0,x
        inx
        decb
        bne story_clear
        ; First 256 bytes cleared above; clear the remaining 64.
        ldab #64
story_clear_tail:
        clr 0,x
        inx
        decb
        bne story_clear_tail
        clr story_opened
        clr temp1
        ldx #story_fcb
        jsr getfil
        bcs story_usage
        tst story_fcb+4
        beq story_usage
        tst story_fcb+12
        bne story_open_named
        ldaa #'D'
        staa story_fcb+12
        ldaa #'A'
        staa story_fcb+13
        ldaa #'T'
        staa story_fcb+14
story_open_named:
        ldaa #1
        staa story_fcb
        jsr fms
        bne story_open_failed
        ldaa #0xff
        staa story_fcb+59       ; binary bytes; disable space expansion
        inc story_opened
        clc
        rts
story_usage:
        ldx #usage_message
        jsr pstrng
        sec
        rts
story_open_failed:
        ldaa story_fcb+1
        staa io_error
        ldx #open_message
        jsr io_report
        sec
        rts

; Read A from an open story, carry set on a FLEX error. Preserve the error
; before closing; close errors must not hide the original read failure.
story_read_byte:
        ldx #story_fcb
        clr 0,x
        jsr fms
        beq story_read_ok
        ldaa story_fcb+1
        staa io_error
        sec
        rts
story_read_ok:
        clc
        rts
story_close:
        tst story_opened
        beq story_close_done
        clr story_opened
        ldx #story_fcb
        ldaa #4
        staa 0,x
        jsr fms
        beq story_close_done
        ldaa story_fcb+1
        staa io_error
        ldx #close_message
        jsr io_report
story_close_done:
        rts
io_report:
        jsr pstrng
        ldx #io_error
        jsr print_hex_byte
        jmp pcrlf
usage_message:
        .ascii "Usage: Z68 [drive.]STORY[.DAT]"
        .byte 4
open_message:
        .ascii "Z68: cannot open story; FLEX error $"
        .byte 4
close_message:
        .ascii "Z68: cannot close story; FLEX error $"
        .byte 4

; Read a physical file sector using FLEX (FCB drive, track/sector in 30/31).
; This preserves file ownership while avoiding assumptions about random maps.
story_read_sector:
        ldx #story_fcb
        ldaa #9
        staa 0,x
        jsr fms
        beq story_sector_ok
        ldaa story_fcb+1
        staa io_error
        sec
        rts
story_sector_ok:
        clc
        rts

; Validate and index the entire sequential file's linked sector chain.
; 521 entries cover the maximum V3 file (128 KiB); extra host padding must
; also fit the reserved index. No direct SRAM or driver calls are made here.
story_build_index:
        clr file_index_valid
        clr cache_valid
        ldx story_fcb+21
        stx file_sector_count
        ldaa file_sector_count
        cmpa #2
        bcs story_index_size_ok
        bhi story_index_bad
        ldab file_sector_count+1
        cmpb #9
        bhi story_index_bad
story_index_size_ok:
        ldaa file_sector_count
        oraa file_sector_count+1
        beq story_index_bad
        ldx story_fcb+17
        stx file_link
        ldx index_base
        stx file_index_pointer
        clr index_count
        clr index_count+1
story_index_loop:
        ldx file_link
        stx story_fcb+30
        jsr story_read_sector
        bcs story_index_bad
        inc index_count+1
        bne story_index_sequence
        inc index_count
story_index_sequence:
        ldaa story_fcb+66
        cmpa index_count
        bne story_index_bad
        ldaa story_fcb+67
        cmpa index_count+1
        bne story_index_bad
        ldx file_index_pointer
        ldaa file_link
        staa 0,x
        ldaa file_link+1
        staa 1,x
        inx
        inx
        stx file_index_pointer
        ldx story_fcb+64
        stx file_link
        ldaa index_count
        cmpa file_sector_count
        bne story_index_more
        ldaa index_count+1
        cmpa file_sector_count+1
        beq story_index_end
story_index_more:
        ldaa file_link
        oraa file_link+1
        bne story_index_loop
story_index_bad:
        sec
        rts
story_index_end:
        ldaa file_link
        oraa file_link+1
        bne story_index_bad
        inc file_index_valid
        clc
        rts
file_index_valid: .byte 0
file_sector_count: .word 0
file_link: .word 0
file_index_pointer: .word 0
