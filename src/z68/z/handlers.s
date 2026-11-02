; Hand-written opcode bodies. This file is NOT regenerated.
; Replace one stub at a time; preserve the dispatch contract in ops.s.
; 0OP handlers: replace each jump as semantics are implemented.
op_rtrue:
        jmp vm_do_rtrue
op_rfalse:
        jmp vm_do_rfalse
op_print:
        jmp vm_do_print
op_print_ret:
        jmp vm_do_print_ret
op_nop:
        jmp vm_do_nop
op_save:
        ldx #op_name_save
        jmp op_unimplemented
op_restore:
        ldx #op_name_restore
        jmp op_unimplemented
op_restart:
        ldx #op_name_restart
        jmp op_unimplemented
op_ret_popped:
        jmp vm_do_ret_popped
op_pop:
        jmp vm_do_pop
op_quit:
        jmp vm_do_quit
op_new_line:
        jmp vm_do_new_line
op_show_status:
        ldx #op_name_show_status
        jmp op_unimplemented
op_verify:
        jmp vm_do_verify

; 1OP handlers: replace each jump as semantics are implemented.
op_jz:
        jmp vm_do_jz
op_get_sibling:
        jmp vm_do_get_sibling
op_get_child:
        jmp vm_do_get_child
op_get_parent:
        jmp vm_do_get_parent
op_get_prop_len:
        jmp vm_do_get_prop_len
op_inc:
        jmp vm_do_inc
op_dec:
        jmp vm_do_dec
op_print_addr:
        jmp vm_do_print_addr
op_remove_obj:
        jmp vm_do_remove_obj
op_print_obj:
        jmp vm_do_print_obj
op_ret:
        jmp vm_do_ret
op_jump:
        jmp vm_do_jump
op_print_paddr:
        jmp vm_do_print_paddr
op_load:
        jmp vm_do_load
op_not:
        jmp vm_do_not

; 2OP handlers: replace each jump as semantics are implemented.
op_je:
        jmp vm_do_je
op_jl:
        jmp vm_do_jl
op_jg:
        jmp vm_do_jg
op_dec_chk:
        jmp vm_do_dec_chk
op_inc_chk:
        jmp vm_do_inc_chk
op_jin:
        jmp vm_do_jin
op_test:
        jmp vm_do_test
op_or:
        jmp vm_do_or
op_and:
        jmp vm_do_and
op_test_attr:
        jmp vm_do_test_attr
op_set_attr:
        jmp vm_do_set_attr
op_clear_attr:
        jmp vm_do_clear_attr
op_store:
        jmp vm_do_store
op_insert_obj:
        jmp vm_do_insert_obj
op_loadw:
        jmp vm_do_loadw
op_loadb:
        jmp vm_do_loadb
op_get_prop:
        jmp vm_do_get_prop
op_get_prop_addr:
        jmp vm_do_get_prop_addr
op_get_next_prop:
        jmp vm_do_get_next_prop
op_add:
        jmp vm_do_add
op_sub:
        jmp vm_do_sub
op_mul:
        jmp vm_do_mul
op_div:
        jmp vm_do_div
op_mod:
        jmp vm_do_mod

; VAR handlers: replace each jump as semantics are implemented.
op_call:
        jmp vm_do_call
op_storew:
        jmp vm_do_storew
op_storeb:
        jmp vm_do_storeb
op_put_prop:
        jmp vm_do_put_prop
op_sread:
        jmp vm_do_sread
op_print_char:
        jmp vm_do_print_char
op_print_num:
        jmp vm_do_print_num
op_random:
        jmp vm_do_random
op_push:
        jmp vm_do_push
op_pull:
        jmp vm_do_pull
op_split_window:
        ldx #op_name_split_window
        jmp op_unimplemented
op_set_window:
        ldx #op_name_set_window
        jmp op_unimplemented
op_output_stream:
        ldx #op_name_output_stream
        jmp op_unimplemented
op_input_stream:
        ldx #op_name_input_stream
        jmp op_unimplemented
op_sound_effect:
        ldx #op_name_sound_effect
        jmp op_unimplemented
