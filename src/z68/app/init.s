; Budget code/data, interpreter reservations and CPU stack under FLEX MEMEND.
; Entered by JMP; choose have_memory or no_memory without using a private stack.
init:
        ldx memend
        ldaa memend
        cmpa #0x80
        bcs init_limit
        ldx #flex_ceiling
init_limit:
        stx ram_top
        ; MC6800 CPX leaves carry unchanged; compare unsigned words by bytes.
        ldaa ram_top
        cmpa #>(app_end+stack_bytes+workspace_bytes)
        bcs init_bad
        bhi init_fit
        ldab ram_top+1
        cmpb #<(app_end+stack_bytes+workspace_bytes)
        bcs init_bad
init_fit:
        ; Maximum dynamic bytes after code/data, interpreter reservations and CPU stack.
        ldaa ram_top
        ldab ram_top+1
        subb #<(app_end+stack_bytes+workspace_bytes-1)
        sbca #>(app_end+stack_bytes+workspace_bytes-1)
        staa ram_budget
        stab ram_budget+1
        ; Lay out the upper workspace downward from the CPU stack.
        ldaa ram_top
        ldab ram_top+1
        subb #<(stack_bytes-1)
        sbca #>(stack_bytes-1)
        staa cpu_stack_base
        stab cpu_stack_base+1
        subb #<vm_stack_bytes
        sbca #>vm_stack_bytes
        staa vm_stack_base
        stab vm_stack_base+1
        staa vm_stack_pointer
        stab vm_stack_pointer+1
        subb #<cache_bytes
        sbca #>cache_bytes
        staa cache_base
        stab cache_base+1
        subb #<index_bytes
        sbca #>index_bytes
        staa index_base
        stab index_base+1
        clr dynamic_loaded
        clr cache_valid
        clr index_count
        clr index_count+1
        jmp have_memory
init_bad:
        jmp no_memory
memory_error:
        .ascii "Z68: insufficient FLEX application RAM."
        .byte 4
