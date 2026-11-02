; Variable ABI. Values are big-endian words in vm_value.
; var_read(A=variable) pops variable 0; var_write(A) pushes variable 0.
; var_peek(A) / var_replace(A) access variable 0 in place, for indirect ops.
; Success: carry clear, X/A/B clobbered. Failure: diagnostic, op_halted=1, C=1.
; Z-stack grows upward, independently of the 6800 stack. Calls set
; vm_local_base/count and vm_eval_base; locals precede the current eval base.
vars_init:
        ldx vm_stack_base
        stx vm_stack_pointer
        stx vm_eval_base
        clr vm_local_base
        clr vm_local_base+1
        clr vm_local_count
        rts
var_read:
        staa vars_variable
        tsta
        bne var_read_named
        jmp vars_pop
var_read_named:
        jsr vars_pointer
        bcs vars_read_done
        bra vars_read_pointer
var_peek:
        staa vars_variable
        tsta
        bne var_read_named
        jsr vars_top_pointer
        bcs vars_read_done
vars_read_pointer:
        ldx vars_pointer_word
        ldaa 0,x
        staa vm_value
        ldaa 1,x
        staa vm_value+1
        clc
vars_read_done:
        rts
var_write:
        staa vars_variable
        tsta
        bne var_write_named
        jmp vars_push
var_write_named:
        jsr vars_pointer
        bcs vars_write_done
        bra vars_write_pointer
var_replace:
        staa vars_variable
        tsta
        bne var_write_named
        jsr vars_top_pointer
        bcs vars_write_done
vars_write_pointer:
        ldx vars_pointer_word
        ldaa vm_value
        staa 0,x
        ldaa vm_value+1
        staa 1,x
        clc
vars_write_done:
        rts

; Validate a two-byte host pointer in [vars_low,vars_high), without CPX carry.
vars_check_word:
        ldaa vars_pointer_word
        cmpa vars_low
        bcs vars_bounds_bad
        bhi vars_check_end
        ldaa vars_pointer_word+1
        cmpa vars_low+1
        bcs vars_bounds_bad
vars_check_end:
        ldaa vars_pointer_word
        ldab vars_pointer_word+1
        addb #1
        adca #0
        bcs vars_bounds_bad
        cmpa vars_high
        bcs vars_bounds_ok
        bhi vars_bounds_bad
        cmpb vars_high+1
        bcc vars_bounds_bad
vars_bounds_ok:
        clc
        rts
vars_bounds_bad:
        jmp vars_fault

; Stack bounds are the active frame's eval base and the reserved arena end.
vars_stack_bounds:
        ldaa vm_eval_base
        cmpa vm_stack_base
        bcs vars_bounds_bad
        bhi vars_stack_base_ok
        ldaa vm_eval_base+1
        cmpa vm_stack_base+1
        bcs vars_bounds_bad
vars_stack_base_ok:
        ldaa vm_stack_pointer+1
        suba vm_eval_base+1
        anda #1
        bne vars_bounds_bad
        ldx vm_eval_base
        stx vars_low
        ldx cpu_stack_base
        stx vars_high
        clc
        rts
vars_top_pointer:
        jsr vars_stack_bounds
        bcs vars_top_done
        ldaa vm_stack_pointer
        ldab vm_stack_pointer+1
        subb #2
        sbca #0
        staa vars_pointer_word
        stab vars_pointer_word+1
        jsr vars_check_word
vars_top_done:
        rts
vars_pop:
        jsr vars_top_pointer
        bcs vars_pop_done
        jsr vars_read_pointer
        ldx vars_pointer_word
        stx vm_stack_pointer
        clc
vars_pop_done:
        rts
vars_push:
        jsr vars_stack_bounds
        bcs vars_push_done
        ldx vm_stack_pointer
        stx vars_pointer_word
        jsr vars_check_word
        bcs vars_push_done
        jsr vars_write_pointer
        ldx vars_pointer_word
        inx
        inx
        stx vm_stack_pointer
        clc
vars_push_done:
        rts

; Map a local/global selector to host RAM, validating the whole word first.
vars_pointer:
        ldaa vars_variable
        cmpa #16
        bcc vars_global
        tsta
        beq vars_pointer_bad
        cmpa vm_local_count
        bhi vars_pointer_bad
        ldab vm_local_count
        cmpb #15
        bhi vars_pointer_bad
        deca
        tab
        clra
        aslb
        rola
        addb vm_local_base+1
        adca vm_local_base
        bcs vars_pointer_bad
        staa vars_pointer_word
        stab vars_pointer_word+1
        ldx vm_stack_base
        stx vars_low
        ldx vm_eval_base
        stx vars_high
        jmp vars_check_word
vars_global:
        ; The entire 240-word globals table must lie in dynamic story RAM.
        ldaa story_header+12
        ldab story_header+13
        tsta
        bne vars_global_start_ok
        cmpb #64
        bcs vars_pointer_bad
vars_global_start_ok:
        addb #<480
        adca #>480
        bcs vars_pointer_bad
        cmpa dynamic_size
        bcs vars_global_size_ok
        bhi vars_pointer_bad
        cmpb dynamic_size+1
        bhi vars_pointer_bad
vars_global_size_ok:
        ldab vars_variable
        subb #16
        clra
        aslb
        rola
        addb story_header+13
        adca story_header+12
        addb #<app_end
        adca #>app_end
        staa vars_pointer_word
        stab vars_pointer_word+1
        ldx #app_end
        stx vars_low
        ldx dynamic_end
        stx vars_high
        jmp vars_check_word
vars_pointer_bad:
        jmp vars_fault

; Resolve raw operands strictly left to right. Raw values/types remain intact.
; Reading variable 0 here pops once, even for an indirect target operand.
vm_resolve:
        clr vars_operand_index
        ldaa vm_operand_count
        cmpa #4
        bls vars_valid_1
        jmp vars_fault
vars_valid_1:
vm_resolve_loop:
        ldaa vars_operand_index
        cmpa vm_operand_count
        beq vm_resolve_done
        ldab vars_operand_index
        ldx #vm_operand_types
vm_resolve_type_seek:
        tstb
        beq vm_resolve_type
        inx
        decb
        bra vm_resolve_type_seek
vm_resolve_type:
        ldaa 0,x
        staa vars_operand_type
        cmpa #2
        bls vars_valid_2
        jmp vars_fault
vars_valid_2:
        ldx #vm_operands
        ldab vars_operand_index
        aslb
vm_resolve_raw_seek:
        tstb
        beq vm_resolve_raw
        inx
        decb
        bra vm_resolve_raw_seek
vm_resolve_raw:
        ldaa 0,x
        staa vm_value
        ldaa 1,x
        staa vm_value+1
        ldaa vars_operand_type
        cmpa #2
        bne vm_resolve_save
        tst vm_value
        beq vars_valid_3
        jmp vars_fault
vars_valid_3:
        ldaa vm_value+1
        jsr var_read
        bcs vm_resolve_error
vm_resolve_save:
        ldx #vm_resolved
        ldab vars_operand_index
        aslb
vm_resolve_result_seek:
        tstb
        beq vm_resolve_result
        inx
        decb
        bra vm_resolve_result_seek
vm_resolve_result:
        ldaa vm_value
        staa 0,x
        ldaa vm_value+1
        staa 1,x
        inc vars_operand_index
        bra vm_resolve_loop
vm_resolve_done:
        clc
        rts
vm_resolve_error:
        rts
vm_store_result:
        ldaa vm_store_variable
        jmp var_write

; Handler helpers and operations. Checked branches remain in the branch class.
vars_one_operand:
        ldaa vm_operand_count
        cmpa #1
        beq vars_valid_4
        jmp vars_fault
vars_valid_4:
        clc
        rts
vars_target_operand:
        tst vm_resolved
        beq vars_valid_5
        jmp vars_fault
vars_valid_5:
        ldaa vm_resolved+1
        staa vars_target
        clc
        rts
vm_do_load:
        jsr vars_one_operand
        bcc 1f
        rts
1:
        jsr vars_target_operand
        bcc 1f
        rts
1:
        jsr var_peek
        bcc 1f
        rts
1:
        jmp vm_store_result
vm_do_store:
        ldaa vm_operand_count
        cmpa #2
        beq vars_valid_6
        jmp vars_fault
vars_valid_6:
        jsr vars_target_operand
        bcc 1f
        rts
1:
        ldx vm_resolved+2
        stx vm_value
        ldaa vars_target
        jmp var_replace
vm_do_inc:
        jsr vars_one_operand
        bcc 1f
        rts
1:
vars_inc_value:
        jsr vars_target_operand
        bcc 1f
        rts
1:
        jsr var_peek
        bcc 1f
        rts
1:
        ldaa vm_value
        ldab vm_value+1
        addb #1
        adca #0
        bra vars_update
vm_do_dec:
        jsr vars_one_operand
        bcc 1f
        rts
1:
vars_dec_value:
        jsr vars_target_operand
        bcc 1f
        rts
1:
        jsr var_peek
        bcc 1f
        rts
1:
        ldaa vm_value
        ldab vm_value+1
        subb #1
        sbca #0
vars_update:
        staa vm_value
        stab vm_value+1
        ldaa vars_target
        jmp var_replace
vm_do_push:
        jsr vars_one_operand
        bcc 1f
        rts
1:
        ldx vm_resolved
        stx vm_value
        clra
        jmp var_write
vm_do_pull:
        jsr vars_one_operand
        bcc 1f
        rts
1:
        jsr vars_target_operand
        bcc 1f
        rts
1:
        jsr vars_pop
        bcc 1f
        rts
1:
        ldaa vars_target
        jmp var_replace
vm_do_pop:
        tst vm_operand_count
        beq vars_valid_7
        jmp vars_fault
vars_valid_7:
        jmp vars_pop
vm_do_random:
        jsr vars_one_operand
        bcc 1f
        rts
1:
        ldaa vm_resolved
        ldab vm_resolved+1
        jsr rnd
        staa vm_value
        stab vm_value+1
        jmp vm_store_result
vars_op_done:
        rts
vars_fault:
        ldaa #1
        staa op_halted
        ldx #vars_error_message
        jsr pstrng
        jsr pcrlf
        sec
        rts
vm_value: .word 0
vars_variable: .byte 0
vm_resolved: .space 8,0
vm_eval_base: .word 0
vm_local_base: .word 0
vm_local_count: .byte 0
vars_pointer_word: .word 0
vars_low: .word 0
vars_high: .word 0
vars_operand_index: .byte 0
vars_operand_type: .byte 0
vars_target: .byte 0
vars_error_message:
        .ascii "Z68: invalid variable, operand count or Z-stack bounds."
        .byte 4
