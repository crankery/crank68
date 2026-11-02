; Decode, resolve operands left to right, then dispatch.
; Input is an explicit milestone boundary; unsupported operations still trap.
vm_run:
        ldaa app_end+1
        anda #0x9f
        oraa #0x10
        staa app_end+1
        jsr vars_init
        jsr calls_init
        clr vm_input_requested
        clr vm_finished
        clr op_halted
        clr vm_pc
        ldx story_header+6
        stx vm_pc+1
        ldx #30000
        stx vm_budget
vm_run_loop:
        jsr vm_decode
        bcs vm_run_error
        jsr vm_resolve
        bcs vm_run_done
        jsr op_dispatch
        bcs vm_run_done
        ldaa vm_budget
        ldab vm_budget+1
        subb #1
        sbca #0
        staa vm_budget
        stab vm_budget+1
        oraa vm_budget+1
        bne vm_run_loop
        ldx #vm_budget_message
        jsr pstrng
        bra vm_run_halt
vm_run_error:
        ldx #vm_decode_message
        jsr pstrng
vm_run_halt:
        ldaa #1
        staa op_halted
vm_run_done:
        sec
        rts
vm_do_nop:
        clc
        rts
vm_do_new_line:
        jsr pcrlf
        clc
        rts
vm_do_print:
        ldaa vm_pc
        staa mem_address
        ldx vm_pc+1
        stx mem_address+1
        jsr text_print
        bcs vm_run_error
        ldaa text_cursor
        staa vm_pc
        ldx text_cursor+1
        stx vm_pc+1
        clc
        rts
vm_do_quit:
        ldaa #1
        staa vm_finished
        sec
        rts
vm_finished: .byte 0
vm_budget: .word 0
vm_budget_message:
        .ascii "Z68: execution step limit reached."
        .byte 4
vm_decode_message:
        .ascii "Z68: invalid/truncated instruction or inaccessible story byte."
        .byte 4
