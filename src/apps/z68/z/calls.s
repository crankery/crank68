; Routine return ABI, shared by rtrue/rfalse and ret/ret_popped handlers.
; vm_value is the return word. vm_frame_pointer=0 denotes initial execution.
; Frames occupy 12 bytes in the Z-stack arena, followed by callee locals:
;  0: caller frame (word), 2: caller local base (word), 4: caller local count,
;  5: caller eval base (word), 7: return PC (3 bytes), 10: result variable,
; 11: padding. Frame address is also the caller's saved stack pointer.
; call creates this header before publishing vm_frame_pointer.
calls_init:
        clr vm_frame_pointer
        clr vm_frame_pointer+1
        rts
vm_do_rtrue:
        clr vm_value
        ldaa #1
        staa vm_value+1
        jmp vm_return
vm_do_rfalse:
        clr vm_value
        clr vm_value+1
vm_return:
        ldx vm_frame_pointer
        bne return_frame
        jmp vm_do_quit
return_frame:
        ; Validate both ends before reading the private frame header.
        stx return_frame_pointer
        stx vars_pointer_word
        ldx vm_stack_base
        stx vars_low
        ldx cpu_stack_base
        stx vars_high
        jsr vars_check_word
        bcc return_first_ok
        rts
return_first_ok:
        ldaa return_frame_pointer
        ldab return_frame_pointer+1
        addb #10
        adca #0
        bcc return_no_wrap
        jmp vars_fault
return_no_wrap:
        staa vars_pointer_word
        stab vars_pointer_word+1
        jsr vars_check_word
        bcc return_header_ok
        rts
return_header_ok:
        ; The whole header must also precede the current evaluation stack.
        ldx vm_eval_base
        stx vars_high
        jsr vars_check_word
        bcc return_eval_ok
        rts
return_eval_ok:
        ldx return_frame_pointer
        ; The saved evaluation base must lie between arena start and frame.
        ldaa 5,x
        cmpa vm_stack_base
        bcs return_bad
        bhi return_saved_low_ok
        ldab 6,x
        cmpb vm_stack_base+1
        bcs return_bad
return_saved_low_ok:
        cmpa return_frame_pointer
        bhi return_bad
        bcs return_saved_high_ok
        ldab 6,x
        cmpb return_frame_pointer+1
        bhi return_bad
return_saved_high_ok:
        ldaa 4,x
        cmpa #15
        bhi return_bad
        ; A linked caller must be below this frame; zero is the root marker.
        ldaa 0,x
        ldab 1,x
        oraa 1,x
        beq return_link_ok
        ldaa 0,x
        cmpa vm_stack_base
        bcs return_bad
        bhi return_link_low_ok
        cmpb vm_stack_base+1
        bcs return_bad
return_link_low_ok:
        cmpa return_frame_pointer
        bcs return_link_ok
        bhi return_bad
        cmpb return_frame_pointer+1
        bcc return_bad
return_link_ok:
        ldaa 7,x
        cmpa #1
        bhi return_bad
        ; Restore the caller before applying its result destination. Any
        ; temporary callee stack entries disappear with the frame.
        staa vm_pc
        ldaa 8,x
        staa vm_pc+1
        ldaa 9,x
        staa vm_pc+2
        ldaa 10,x
        staa vm_store_variable
        ldaa 4,x
        staa vm_local_count
        ldaa 5,x
        staa vm_eval_base
        ldaa 6,x
        staa vm_eval_base+1
        ldaa 2,x
        staa vm_local_base
        ldaa 3,x
        staa vm_local_base+1
        ldx 0,x
        stx vm_frame_pointer
        ldx return_frame_pointer
        stx vm_stack_pointer
        jmp vm_store_result
return_bad:
        jmp vars_fault
vm_frame_pointer: .word 0
return_frame_pointer: .word 0

; V3 call routine [up to three arguments] -> result.
vm_do_call:
        ldaa vm_operand_count
        beq call_bad
        cmpa #4
        bhi call_bad
        ldaa vm_resolved
        oraa vm_resolved+1
        bne call_nonzero
        clr vm_value
        clr vm_value+1
        jmp vm_store_result
call_bad:
        jmp vars_fault
call_nonzero:
        ; Packed addresses expand into a full 17-bit byte PC.
        clr call_pc
        ldx vm_resolved
        stx call_pc+1
        asl call_pc+2
        rol call_pc+1
        rol call_pc
        ldaa call_pc
        staa mem_address
        ldx call_pc+1
        stx mem_address+1
        jsr memory_read_byte
        bcc 1f
        jmp call_io_bad
1:
        cmpa #15
        bhi call_bad
        staa call_local_count
        jsr vars_stack_bounds
        bcc 1f
        rts
1:
        ldx vm_stack_pointer
        stx call_frame
        stx vars_pointer_word
        jsr vars_check_word
        bcc 1f
        rts
1:
        ldaa call_local_count
        asla
        adda #12
        tab
        clra
        addb call_frame+1
        adca call_frame
        bcs call_bad
        staa call_end
        stab call_end+1
        subb #2
        sbca #0
        staa vars_pointer_word
        stab vars_pointer_word+1
        jsr vars_check_word
        bcc 1f
        rts
1:
        ldx call_frame
        ldaa vm_frame_pointer
        staa 0,x
        ldaa vm_frame_pointer+1
        staa 1,x
        ldaa vm_local_base
        staa 2,x
        ldaa vm_local_base+1
        staa 3,x
        ldaa vm_local_count
        staa 4,x
        ldaa vm_eval_base
        staa 5,x
        ldaa vm_eval_base+1
        staa 6,x
        ldaa vm_pc
        staa 7,x
        ldaa vm_pc+1
        staa 8,x
        ldaa vm_pc+2
        staa 9,x
        ldaa vm_store_variable
        staa 10,x
        clr 11,x
        ldab #12
call_locals_base:
        inx
        decb
        bne call_locals_base
        stx call_local_pointer
        stx vm_local_base
        ldaa call_pc
        staa vm_pc
        ldx call_pc+1
        stx vm_pc+1
        jsr vm_fetch
        bcc 1f
        jmp call_io_bad
1:
        clr call_index
call_local_loop:
        ldaa call_index
        cmpa call_local_count
        beq call_publish
        jsr vm_fetch
        bcc 1f
        jmp call_io_bad
1:
        staa call_default
        jsr vm_fetch
        bcc 1f
        jmp call_io_bad
1:
        staa call_default+1
        ; Argument i overrides default local i, but its default is still read.
        ldaa call_index
        inca
        cmpa vm_operand_count
        bcc call_use_default
        asla
        tab
        ldx #vm_resolved
call_arg_seek:
        inx
        decb
        bne call_arg_seek
        ldx 0,x
        stx call_default
call_use_default:
        ldx call_local_pointer
        ldaa call_default
        staa 0,x
        ldaa call_default+1
        staa 1,x
        inx
        inx
        stx call_local_pointer
        inc call_index
        bra call_local_loop
call_publish:
        ldx call_frame
        stx vm_frame_pointer
        ldaa call_local_count
        staa vm_local_count
        ldx call_end
        stx vm_eval_base
        stx vm_stack_pointer
        clc
call_done:
        rts
call_io_bad:
        jmp vm_run_error
vm_do_ret:
        jsr vars_one_operand
        bcc 1f
        rts
1:
        ldx vm_resolved
        stx vm_value
        jmp vm_return
vm_do_ret_popped:
        jsr vars_pop
        bcc 1f
        rts
1:
        jmp vm_return
call_pc: .space 3,0
call_frame: .word 0
call_end: .word 0
call_local_pointer: .word 0
call_default: .word 0
call_local_count: .byte 0
call_index: .byte 0
