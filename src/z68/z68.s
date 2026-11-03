; Z68 -- V3 story interpreter, loaded as a FLEX command.
; Everything owned by this command is below min(FLEX MEMEND, $7FFF).
; The 512-byte hardware stack is reserved at the top of that range.
; No bank latch or direct hardware access is used.
        .equ app_base, 0x0300
        .equ flex_ceiling, 0x7fff
        .equ stack_bytes, 512
        .equ vm_stack_bytes, 2048
        .equ cache_bytes, 504       ; two FLEX payload sectors, managed as an LRU cache
        .equ index_bytes, 1042      ; ceil(128 KiB / 252) track/sector pairs
        .equ workspace_bytes, vm_stack_bytes+cache_bytes+index_bytes
        .equ fms, 0xb406
        .equ warms, 0xad03
        .equ getfil, 0xad2d
        .equ pstrng, 0xad1e
        .equ pcrlf, 0xad24
        .equ outhex, 0xad3c
        .equ outch, 0xad0f
        .equ temp1, 0xac0d
        .equ memend, 0xac2b

        .org app_base
start:
        sts flex_sp
        jmp init
no_memory:
        ldx #memory_error
        jsr pstrng
        jmp warms
have_memory:
        lds ram_top
app_stack_ready:
        jsr rnd_init
        jsr story_open
        bcs finish
        jsr text_parse
        bcs close_story
        jsr header_read
        bcs close_story
        jsr header_report
        jsr memory_load
        bcs close_story
        jsr memory_report
        tst vm_requested
        beq inspect_text
        jsr vm_run
        jsr terminal_end
        bra close_story
inspect_text:
        jsr text_run
close_story:
        jsr story_close
finish:
        lds flex_sp
        jmp warms

        .include "hw_io.s"
        .include "init.s"
        .include "zio.s"
        .include "header.s"
        .include "memory.s"
        .include "text.s"
        .include "ops.s"
        .include "random.s"
        .include "decode.s"
        .include "execute.s"
        .include "vars.s"
        .include "calls.s"
        .include "math.s"
        .include "branch.s"
        .include "arrays.s"
        .include "objects.s"
        .include "props.s"
        .include "output.s"
        .include "input.s"
        .include "verify.s"
        .include "status.s"
        .include "dict.s"
        .include "wrap.s"

; Local writable storage is included in the binary so its full extent can be
; verified when packaging it.
flex_sp:        .word 0
ram_top:        .word 0
ram_budget:     .word 0
io_error:       .byte 0
header_count:   .byte 0
header_pointer: .word 0
serial_count:   .byte 0
serial_pointer: .word 0
story_opened:   .byte 0
story_header:   .space 64,0
story_fcb:      .space 320,0
app_end:
