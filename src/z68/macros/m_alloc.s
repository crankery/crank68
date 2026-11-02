
; ------
; allocate memory on the zero page
	.set	zp_alloc_ptr, 0x00
	.macro	alloc_zp name,size
	.equ	\name, zp_alloc_ptr
	.set	zp_alloc_ptr, zp_alloc_ptr + \size
	.endm

; ------
; allocate memory in the gp ram
	.set	ram_alloc_ptr, gp_page
	.macro	alloc name, size
	.equ	\name, ram_alloc_ptr
	.set	ram_alloc_ptr, ram_alloc_ptr + \size
	.endm
