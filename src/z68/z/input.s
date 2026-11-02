; First-input milestone. No line is consumed or buffers modified yet.
; Distinct from quit and an opcode trap, so tests cannot mistake this for play.
vm_do_sread:
        ldaa #1
        staa vm_input_requested
        ldx #input_boundary_message
        jsr pcrlf
        jsr pstrng
        jsr pcrlf
        sec
        rts
vm_input_requested: .byte 0
input_boundary_message:
        .ascii "Z68: first input request reached; line input is not implemented."
        .byte 4
