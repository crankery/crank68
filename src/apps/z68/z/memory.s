; V3 conventional-RAM layout. All ranges use an exclusive end.
;
; app_base -> app_end:       code, fixed data, FCB and header
; app_end -> dynamic_end:    writable story [0, static-memory-base)
; dynamic_end -> index_base: unallocated growth space
; index_base -> cache_base:  1042 bytes for the file-sector index
; cache_base -> vm_stack_base: 504 bytes for a two-slot read-only cache
; vm_stack_base -> cpu_stack_base: 2048 bytes for Z-stack/call frames
; cpu_stack_base -> ram_top+1: 512-byte 6800 stack (already active)
;
; Dynamic memory is resident; static reads use a lazy sector index and cache.
; Story addresses are not host pointers.
memory_load:
        clr dynamic_loaded
        ldaa story_header+14
        ldab story_header+15
        staa dynamic_size
        stab dynamic_size+1
        ; Full layout was budgeted before switching stacks. Reject too-large
        ; dynamic regions before writing any byte of story RAM.
        cmpa ram_budget
        bcs memory_fits
        bhi memory_no_fit
        cmpb ram_budget+1
        bls memory_fits
memory_no_fit:
        ldx #layout_error
        jsr pstrng
        sec
        rts
memory_fits:
        addb #<app_end
        adca #>app_end
        staa dynamic_end
        stab dynamic_end+1
        ldaa index_base
        ldab index_base+1
        subb dynamic_end+1
        sbca dynamic_end
        staa growth_bytes
        stab growth_bytes+1
        ldx #app_end
        stx load_pointer
        ; Header read already advanced the open binary story by 64 bytes.
        ; Copy those original bytes before continuing from that exact position.
        ldx #story_header
        stx source_pointer
        ldaa #64
        staa copy_count
memory_copy_header:
        ldx source_pointer
        ldaa 0,x
        inx
        stx source_pointer
        ldx load_pointer
        staa 0,x
        inx
        stx load_pointer
        dec copy_count
        bne memory_copy_header
        ldaa dynamic_size
        ldab dynamic_size+1
        subb #64
        sbca #0
        staa load_remaining
        stab load_remaining+1
memory_read_loop:
        ldaa load_remaining
        oraa load_remaining+1
        beq memory_loaded
        jsr story_read_byte
        bcs memory_read_failed
        ldx load_pointer
        staa 0,x
        inx
        stx load_pointer
        ; DEC does not update carry; perform the 16-bit decrement explicitly.
        ldaa load_remaining
        ldab load_remaining+1
        subb #1
        sbca #0
        staa load_remaining
        stab load_remaining+1
        bra memory_read_loop
memory_loaded:
        inc dynamic_loaded
        clc
        rts
memory_read_failed:
        ldx #load_error
        jsr io_report
        sec
        rts

memory_report:
        ldx #loaded_message
        jsr pstrng
        ldx #dynamic_size
        jsr print_hex_word
        ldx #dynamic_message_start
        jsr pstrng
        ldx #dynamic_start
        jsr print_hex_word
        ldaa #'-'
        jsr putc
        ldx #dynamic_end
        jsr print_hex_word
        ldx #index_message
        jsr pstrng
        ldx #index_base
        jsr print_hex_word
        ldx #cache_message
        jsr pstrng
        ldx #cache_base
        jsr print_hex_word
        ldx #vm_stack_message
        jsr pstrng
        ldx #vm_stack_base
        jsr print_hex_word
        ldx #cpu_stack_message
        jsr pstrng
        ldx #cpu_stack_base
        jsr print_hex_word
        ldx #growth_message
        jsr pstrng
        ldx #growth_bytes
        jsr print_hex_word
        ldx #milestone_message
        jsr pstrng
        jmp pcrlf

dynamic_start:   .word app_end
dynamic_size:    .word 0
dynamic_end:     .word 0
dynamic_loaded:  .byte 0
growth_bytes:    .word 0
index_base:     .word 0
index_count:    .word 0
cache_base:     .word 0
cache_valid:    .byte 0
vm_stack_base:  .word 0
vm_stack_pointer: .word 0
cpu_stack_base: .word 0
load_pointer:   .word 0
source_pointer: .word 0
load_remaining: .word 0
copy_count:     .byte 0
layout_error:
        .ascii "Z68: dynamic memory exceeds the RAM layout capacity."
        .byte 4
load_error:
        .ascii "Z68: cannot load dynamic memory; FLEX error $"
        .byte 4
loaded_message:
        .ascii "Loaded writable story bytes: $"
        .byte 4
dynamic_message_start:
        .ascii "Dynamic RAM [start,end): $"
        .byte 4
index_message:
        .ascii "Sector index reservation (1042 bytes) at $"
        .byte 4
cache_message:
        .ascii "Story cache reservation (504 bytes) at $"
        .byte 4
vm_stack_message:
        .ascii "Z-stack/frame reservation (2048 bytes) at $"
        .byte 4
cpu_stack_message:
        .ascii "6800 stack reservation (512 bytes) at $"
        .byte 4
growth_message:
        .ascii "Free growth bytes: $"
        .byte 4
milestone_message:
        .ascii "Story memory loaded; RUN enables the limited execution core."
        .byte 4

; Story byte reader. mem_address is an unsigned 17-bit story byte address.
; Return A, carry clear; carry set on bounds/disk errors. X/B are clobbered.
; Reads of writable story bytes always use their RAM copy. Other reads use
; one 252-byte cache slot, filled through FLEX and a lazily built file index.
memory_read_byte:
        ldaa mem_address
        cmpa #1
        bls memory_address_ok
memory_read_error:
        sec
        rts
memory_address_ok:
        ; Respect declared story length when present (V3 units are two bytes).
        ldaa story_header+26
        ldab story_header+27
        staa mem_limit+1
        stab mem_limit+2
        oraa mem_limit+2
        beq memory_check_dynamic
        clr mem_limit
        asl mem_limit+2
        rol mem_limit+1
        rol mem_limit
        ldaa mem_address
        cmpa mem_limit
        bcs memory_check_dynamic
        bhi memory_read_error
        ldaa mem_address+1
        cmpa mem_limit+1
        bcs memory_check_dynamic
        bhi memory_read_error
        ldaa mem_address+2
        cmpa mem_limit+2
        bcc memory_read_error
memory_check_dynamic:
        tst mem_address
        bne memory_static
        ldaa mem_address+1
        cmpa dynamic_size
        bcs memory_dynamic
        bhi memory_static
        ldaa mem_address+2
        cmpa dynamic_size+1
        bcc memory_static
memory_dynamic:
        ldaa mem_address+1
        ldab mem_address+2
        addb #<app_end
        adca #>app_end
        staa mem_pointer
        stab mem_pointer+1
        ldx mem_pointer
        ldaa 0,x
        clc
        rts
memory_static:
        tst file_index_valid
        bne memory_have_index
        jsr story_build_index
        bcc memory_have_index
        rts
memory_have_index:
        tst cache_valid
        beq memory_probe_second
        ldx #cache_start
        jsr memory_cache_probe
        bcs memory_probe_second
        clr cache_recent
        ldx cache_base
        stx cache_current
        jmp memory_cache_hit
memory_probe_second:
        tst cache_second_valid
        beq memory_cache_miss
        ldx #cache_second_start
        jsr memory_cache_probe
        bcs memory_cache_miss
        ldaa #1
        staa cache_recent
        jsr memory_second_pointer
        jmp memory_cache_hit
memory_cache_miss:
        jsr memory_divide_address
memory_divided:
        ldaa mem_sector
        cmpa index_count
        bcs memory_sector_valid
        bhi memory_index_error
        ldaa mem_sector+1
        cmpa index_count+1
        bcs memory_sector_valid
memory_index_error:
        sec
        rts
memory_sector_valid:
        ldaa mem_div+2
        staa cache_offset
        ldaa mem_sector
        ldab mem_sector+1
        aslb
        rola
        addb index_base+1
        adca index_base
        staa mem_pointer
        stab mem_pointer+1
        ldx mem_pointer
        ldaa 0,x
        ldab 1,x
        staa story_fcb+30
        stab story_fcb+31
        jsr memory_choose_cache
        jsr story_read_sector
        bcs memory_index_error
        ; Cache the sector payload, never its link/sequence header.
        ldx #story_fcb+68
        stx source_pointer
        ldx cache_current
        stx mem_pointer
        ldaa #252
        staa copy_count
memory_cache_copy:
        ldx source_pointer
        ldaa 0,x
        inx
        stx source_pointer
        ldx mem_pointer
        staa 0,x
        inx
        stx mem_pointer
        dec copy_count
        bne memory_cache_copy
        ldx #cache_start
        tst cache_recent
        beq memory_cache_tag
        ldx #cache_second_start
memory_cache_tag:
        ldaa mem_address+2
        suba cache_offset
        staa 2,x
        ldaa mem_address+1
        sbca #0
        staa 1,x
        ldaa mem_address
        sbca #0
        staa 0,x
        tst cache_recent
        bne memory_cache_second_ready
        inc cache_valid
        bra memory_cache_hit
memory_cache_second_ready:
        inc cache_second_valid
memory_cache_hit:
        ldaa #0
        ldab cache_offset
        addb cache_current+1
        adca cache_current
        staa mem_pointer
        stab mem_pointer+1
        ldx mem_pointer
        ldaa 0,x
        clc
        rts

; Return C=0 and cache_offset if the address is inside the tag pointed to by X.
memory_cache_probe:
        ldaa mem_address+2
        suba 2,x
        staa cache_offset
        ldaa mem_address+1
        sbca 1,x
        bne memory_cache_probe_bad
        ldaa mem_address
        sbca 0,x
        bne memory_cache_probe_bad
        ldaa cache_offset
        cmpa #252
        bcc memory_cache_probe_bad
        clc
        rts
memory_cache_probe_bad:
        sec
        rts
memory_second_pointer:
        ldaa cache_base
        ldab cache_base+1
        addb #252
        adca #0
        staa cache_current
        stab cache_current+1
        rts
; Two slots: fill invalid slots first, then replace the less recently used one.
; Invalidate only the selected slot before disk I/O; a failed fill keeps the
; other slot usable. cache_recent identifies the selected/MRU slot (0 or 1).
memory_choose_cache:
        tst cache_valid
        beq memory_choose_first
        tst cache_second_valid
        beq memory_choose_second
        tst cache_recent
        beq memory_choose_second
memory_choose_first:
        clr cache_recent
        clr cache_valid
        ldx cache_base
        stx cache_current
        rts
memory_choose_second:
        ldaa #1
        staa cache_recent
        clr cache_second_valid
        jmp memory_second_pointer

; Divide a 17-bit byte address by 252 in exactly 17 bit steps. Quotient is in
; mem_sector, remainder in mem_div+2; input mem_address stays unchanged.
memory_divide_address:
        ldaa mem_address
        staa mem_shift
        ldx mem_address+1
        stx mem_shift+1
        ldab #7
memory_align_dividend:
        asl mem_shift+2
        rol mem_shift+1
        rol mem_shift
        decb
        bne memory_align_dividend
        clr mem_sector
        clr mem_sector+1
        clr mem_div
        clr mem_div+1
        clr mem_div+2
        ldaa #17
        staa mem_divide_bits
memory_divide_bits_loop:
        asl mem_sector+1
        rol mem_sector
        asl mem_shift+2
        rol mem_shift+1
        rol mem_shift
        rol mem_div+2
        rol mem_div+1
        tst mem_div+1
        bne memory_divide_subtract
        ldaa mem_div+2
        cmpa #252
        bcs memory_divide_next
memory_divide_subtract:
        ldaa mem_div+2
        suba #252
        staa mem_div+2
        ldaa mem_div+1
        sbca #0
        staa mem_div+1
        inc mem_sector+1
memory_divide_next:
        dec mem_divide_bits
        bne memory_divide_bits_loop
        clc
        rts

; Increment the full story address. The reader rejects overflow past V3 space.
memory_next:
        inc mem_address+2
        bne memory_next_done
        inc mem_address+1
        bne memory_next_done
        inc mem_address
memory_next_done:
        rts
mem_address: .byte 0,0,0
mem_limit: .byte 0,0,0
mem_pointer: .word 0
mem_div: .byte 0,0,0
mem_sector: .word 0
cache_start: .byte 0,0,0
cache_offset: .byte 0
cache_second_valid: .byte 0
cache_second_start: .space 3,0
cache_recent: .byte 0
cache_current: .word 0
mem_shift: .space 3,0
mem_divide_bits: .byte 0
