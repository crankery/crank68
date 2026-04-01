; ------------------------------------------------------------       
; M6800 vectors
; ------------------------------------------------------------       

    .global v_irq
    .global v_swi
    .global v_nmi
    .global v_rst

    .section ".vectors","adr"

    .include "defs.s"
    
v_irq:
    .word irq_handler
v_swi:
    .word swi_handler
v_nmi:
    .word nmi_handler
v_rst:
    .word rst_handler

