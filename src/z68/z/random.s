; V1-3 random-number service. Input signed range in A:B (high:low).
;   >0: return 1..range, using rejection sampling (no modulo bias).
;   <0: seed a predictable sequence from the exact signed operand; return 0.
;    0: reseed normal mode from FLEX date + C68 input-poll timing; return 0.
; Return A:B and rnd_result, carry clear. X is preserved; A/B/flags clobbered.
; This is a service for the future opcode wrapper; variable stores are not yet
; implemented, so op_random remains a trap until it can store the result.
;
; C68TICKS at $BFF8 is a wrapping input-poll counter, NOT a wall clock.
; No RTC or timer hardware is read. Identical entropy can still reproduce runs.
        .equ flex_poll_ticks, 0xbff8
        .equ flex_date, 0xac0e
rnd:
        staa rnd_range
        stab rnd_range+1
        tsta
        bmi rnd_predictable
        oraa rnd_range+1
        beq rnd_reseed
        ldaa rnd_state
        oraa rnd_state+1
        oraa rnd_state+2
        oraa rnd_state+3
        bne rnd_have_state
        jsr rnd_init
rnd_have_state:
        ; threshold = (65536 mod range) = unsigned(-range) mod range.
        clra
        suba rnd_range+1
        staa rnd_dividend+1
        ldaa #0
        sbca rnd_range
        staa rnd_dividend
        jsr rnd_mod
        staa rnd_threshold
        stab rnd_threshold+1
rnd_draw:
        jsr rnd_next
        staa rnd_dividend
        stab rnd_dividend+1
        cmpa rnd_threshold
        bcs rnd_draw
        bhi rnd_accept
        cmpb rnd_threshold+1
        bcs rnd_draw
rnd_accept:
        jsr rnd_mod
        addb #1
        adca #0
        staa rnd_result
        stab rnd_result+1
        clc
        rts
rnd_predictable:
        ldaa rnd_range
        eora #0x6d
        staa rnd_state
        ldab rnd_range+1
        eorb #0x2b
        stab rnd_state+1
        ldaa rnd_range
        eora #0x79
        staa rnd_state+2
        ldab rnd_range+1
        eorb #0xf5
        stab rnd_state+3
        ldaa #1
        staa rnd_mode
        jsr rnd_warm
        bra rnd_zero
rnd_reseed:
        jsr rnd_init
rnd_zero:
        clra
        clrb
        staa rnd_result
        stab rnd_result+1
        clc
        rts

; Call at startup/restart or random 0. Mix new entropy with the previous state
; and a nonce so consecutive reseeds do not simply restart one day's sequence.
rnd_init:
        inc rnd_nonce+1
        bne rnd_nonce_ready
        inc rnd_nonce
rnd_nonce_ready:
        ldaa flex_poll_ticks
        eora flex_date+2
        eora rnd_state
        staa rnd_state
        ldaa flex_poll_ticks+1
        eora flex_date+1
        eora rnd_state+1
        staa rnd_state+1
        ldaa flex_date
        eora rnd_nonce
        eora rnd_state+2
        staa rnd_state+2
        ldaa rnd_nonce+1
        eora rnd_state+3
        eora #0xa5
        staa rnd_state+3
        clr rnd_mode
        jmp rnd_warm
rnd_warm:
        ldaa #8
        staa rnd_warm_count
rnd_warm_loop:
        jsr rnd_next
        dec rnd_warm_count
        bne rnd_warm_loop
        rts

; xorshift32, shifts (13,17,5); nonzero state has period 2^32-1.
; Return the high 16 bits. A four-byte zero state is repaired defensively.
rnd_next:
        ldaa rnd_state
        oraa rnd_state+1
        oraa rnd_state+2
        oraa rnd_state+3
        bne rnd_next_nonzero
        ldaa #0xa5
        staa rnd_state+3
rnd_next_nonzero:
        jsr rnd_copy
        ldab #13
rnd_shift_left_13:
        asl rnd_work+3
        rol rnd_work+2
        rol rnd_work+1
        rol rnd_work
        decb
        bne rnd_shift_left_13
        jsr rnd_xor
        jsr rnd_copy
        ldab #17
rnd_shift_right_17:
        lsr rnd_work
        ror rnd_work+1
        ror rnd_work+2
        ror rnd_work+3
        decb
        bne rnd_shift_right_17
        jsr rnd_xor
        jsr rnd_copy
        ldab #5
rnd_shift_left_5:
        asl rnd_work+3
        rol rnd_work+2
        rol rnd_work+1
        rol rnd_work
        decb
        bne rnd_shift_left_5
        jsr rnd_xor
        ldaa rnd_state
        ldab rnd_state+1
        rts
rnd_copy:
        ldaa rnd_state
        staa rnd_work
        ldaa rnd_state+1
        staa rnd_work+1
        ldaa rnd_state+2
        staa rnd_work+2
        ldaa rnd_state+3
        staa rnd_work+3
        rts
rnd_xor:
        ldaa rnd_state
        eora rnd_work
        staa rnd_state
        ldaa rnd_state+1
        eora rnd_work+1
        staa rnd_state+1
        ldaa rnd_state+2
        eora rnd_work+2
        staa rnd_state+2
        ldaa rnd_state+3
        eora rnd_work+3
        staa rnd_state+3
        rts

; Unsigned 16-bit remainder: rnd_dividend % rnd_range (range is positive).
; Fixed 16 iterations, including large ranges; no repeated-subtraction loop.
rnd_mod:
        clr rnd_remainder
        clr rnd_remainder+1
        ldab #16
rnd_mod_loop:
        asl rnd_dividend+1
        rol rnd_dividend
        rol rnd_remainder+1
        rol rnd_remainder
        ldaa rnd_remainder
        cmpa rnd_range
        bcs rnd_mod_next
        bhi rnd_mod_subtract
        ldaa rnd_remainder+1
        cmpa rnd_range+1
        bcs rnd_mod_next
rnd_mod_subtract:
        ldaa rnd_remainder+1
        suba rnd_range+1
        staa rnd_remainder+1
        ldaa rnd_remainder
        sbca rnd_range
        staa rnd_remainder
rnd_mod_next:
        decb
        bne rnd_mod_loop
        ldaa rnd_remainder
        ldab rnd_remainder+1
        rts
rnd_state: .byte 0,0,0,0
rnd_work: .byte 0,0,0,0
rnd_nonce: .word 0
rnd_range: .word 0
rnd_threshold: .word 0
rnd_dividend: .word 0
rnd_remainder: .word 0
rnd_result: .word 0
rnd_mode: .byte 0
rnd_warm_count: .byte 0
