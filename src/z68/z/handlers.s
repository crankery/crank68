; Hand-written opcode bodies. This file is NOT regenerated.
; Replace one stub at a time; preserve the dispatch contract in ops.s.
; 0OP handlers: replace each jump as semantics are implemented.
op_rtrue:
        ldx #op_name_rtrue
        jmp op_unimplemented
op_rfalse:
        ldx #op_name_rfalse
        jmp op_unimplemented
op_print:
        jmp vm_do_print
op_print_ret:
        ldx #op_name_print_ret
        jmp op_unimplemented
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
        ldx #op_name_ret_popped
        jmp op_unimplemented
op_pop:
        ldx #op_name_pop
        jmp op_unimplemented
op_quit:
        jmp vm_do_quit
op_new_line:
        jmp vm_do_new_line
op_show_status:
        ldx #op_name_show_status
        jmp op_unimplemented
op_verify:
        ldx #op_name_verify
        jmp op_unimplemented

; 1OP handlers: replace each jump as semantics are implemented.
op_jz:
        ldx #op_name_jz
        jmp op_unimplemented
op_get_sibling:
        ldx #op_name_get_sibling
        jmp op_unimplemented
op_get_child:
        ldx #op_name_get_child
        jmp op_unimplemented
op_get_parent:
        ldx #op_name_get_parent
        jmp op_unimplemented
op_get_prop_len:
        ldx #op_name_get_prop_len
        jmp op_unimplemented
op_inc:
        ldx #op_name_inc
        jmp op_unimplemented
op_dec:
        ldx #op_name_dec
        jmp op_unimplemented
op_print_addr:
        ldx #op_name_print_addr
        jmp op_unimplemented
op_remove_obj:
        ldx #op_name_remove_obj
        jmp op_unimplemented
op_print_obj:
        ldx #op_name_print_obj
        jmp op_unimplemented
op_ret:
        ldx #op_name_ret
        jmp op_unimplemented
op_jump:
        ldx #op_name_jump
        jmp op_unimplemented
op_print_paddr:
        ldx #op_name_print_paddr
        jmp op_unimplemented
op_load:
        ldx #op_name_load
        jmp op_unimplemented
op_not:
        ldx #op_name_not
        jmp op_unimplemented

; 2OP handlers: replace each jump as semantics are implemented.
op_je:
        ldx #op_name_je
        jmp op_unimplemented
op_jl:
        ldx #op_name_jl
        jmp op_unimplemented
op_jg:
        ldx #op_name_jg
        jmp op_unimplemented
op_dec_chk:
        ldx #op_name_dec_chk
        jmp op_unimplemented
op_inc_chk:
        ldx #op_name_inc_chk
        jmp op_unimplemented
op_jin:
        ldx #op_name_jin
        jmp op_unimplemented
op_test:
        ldx #op_name_test
        jmp op_unimplemented
op_or:
        ldx #op_name_or
        jmp op_unimplemented
op_and:
        ldx #op_name_and
        jmp op_unimplemented
op_test_attr:
        ldx #op_name_test_attr
        jmp op_unimplemented
op_set_attr:
        ldx #op_name_set_attr
        jmp op_unimplemented
op_clear_attr:
        ldx #op_name_clear_attr
        jmp op_unimplemented
op_store:
        ldx #op_name_store
        jmp op_unimplemented
op_insert_obj:
        ldx #op_name_insert_obj
        jmp op_unimplemented
op_loadw:
        ldx #op_name_loadw
        jmp op_unimplemented
op_loadb:
        ldx #op_name_loadb
        jmp op_unimplemented
op_get_prop:
        ldx #op_name_get_prop
        jmp op_unimplemented
op_get_prop_addr:
        ldx #op_name_get_prop_addr
        jmp op_unimplemented
op_get_next_prop:
        ldx #op_name_get_next_prop
        jmp op_unimplemented
op_add:
        ldx #op_name_add
        jmp op_unimplemented
op_sub:
        ldx #op_name_sub
        jmp op_unimplemented
op_mul:
        ldx #op_name_mul
        jmp op_unimplemented
op_div:
        ldx #op_name_div
        jmp op_unimplemented
op_mod:
        ldx #op_name_mod
        jmp op_unimplemented

; VAR handlers: replace each jump as semantics are implemented.
op_call:
        ldx #op_name_call
        jmp op_unimplemented
op_storew:
        ldx #op_name_storew
        jmp op_unimplemented
op_storeb:
        ldx #op_name_storeb
        jmp op_unimplemented
op_put_prop:
        ldx #op_name_put_prop
        jmp op_unimplemented
op_sread:
        ldx #op_name_sread
        jmp op_unimplemented
op_print_char:
        ldx #op_name_print_char
        jmp op_unimplemented
op_print_num:
        ldx #op_name_print_num
        jmp op_unimplemented
op_random:
        ldx #op_name_random
        jmp op_unimplemented
op_push:
        ldx #op_name_push
        jmp op_unimplemented
op_pull:
        ldx #op_name_pull
        jmp op_unimplemented
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
