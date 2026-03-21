; c68.asm
;
; bios for crank68 computer
;
; memory map:
;   $0000-$bfff   ram
;   $c000-$dfff   banked memory    
;   $e000-$e0ff   i/o
;   $e100-$ffff   rom
;
; calling convention:
;
;   jsr bios_entry
;   fcb bios_cmd_xxx
;   ...inline args if needed...
;
; examples:
;
;   jsr bios_entry
;   fcb bios_cmd_putc
;   fcb 'a'
;
;   jsr bios_entry
;   fcb bios_cmd_puts
;   fcb 'h','e','l','l','o',13,10,0
;
; dispatcher behavior:
;   - briefly masks irq
;   - pulls caller return address
;   - reads command / inline args from caller stream
;   - computes corrected return address
;   - pushes corrected return address back
;   - restores prior irq mask state
;   - performs service
;   - rts back to caller after inline data
;
; notes:
;   - assumes nmi is unused
;   - assumes irq handlers are conventional and well-behaved
;   - many routines are placeholders

; ------------------------------------------------------------
; hardware definitions
; ------------------------------------------------------------

; M6800 vectors
v_irq   equ  $FFF8
v_swi   equ  $FFFA
v_nmi   equ  $FFFC
v_reset equ  $FFFE

ram_start       equ $0000
ram_end         equ $bfff
bank_start      equ $c000
bank_end        equ $dfff
io_start        equ $e000
io_end          equ $e0ff
bios_start      equ $e100
rom_end         equ $ffff

; slot 0
bank_reg  equ $e000

; slot 1
acia0_data      equ $e010
acia0_status    equ $e011
; pia0

; slot 2
acia0_cmd       equ $e020
acia0_ctrl      equ $e021
; pia1

acia_tdre_mask  equ $02
acia_rdrf_mask  equ $01

; ------------------------------------------------------------
; zero page / low ram workspace
; ------------------------------------------------------------

bios_ptr        equ $0000    ; 16-bit pointer into inline parameter stream
bios_tmp        equ $0002    ; 16-bit scratch
bios_saved_cc   equ $0004    ; saved cc on entry
bios_saved_a    equ $0005    ; scratch
bios_saved_b    equ $0006    ; scratch
bios_saved_x    equ $0007    ; 16-bit scratch

; ------------------------------------------------------------
; bios command numbers
; ------------------------------------------------------------

cmd_putc       equ $01
cmd_puts       equ $02
cmd_crlf       equ $03
cmd_getc       equ $04
cmd_ws         equ $05

; ------------------------------------------------------------
; start of 8K rom image
; this area of the rom is not present on the bus
; ------------------------------------------------------------

        org io_start

bios_id:
        string "Crank68 BIOS"
        string "Dave Hamilton 2026"
        string "v0.1"

; ------------------------------------------------------------
; cold reset entry
; ------------------------------------------------------------

        org bios_start

reset:
; stack goes at the end of ram
        lds #ram_end    

; clear condition codes
        clra
        tap

; initialize latch / bank register to known state
        staa bank_reg   

; initialize console / serial hardware
        jsr acia0_init

; simple banner using inline-dispatch interface
        jsr bios_main
        byte cmd_puts
        fcc "Hello world"
        fcb 13
        fcb 10
        fcb 0

; hand off to monitor / shell / idle loop
        jmp warmstart

; emulator will detect infinite loop and stop
halt:
        bra halt

; ------------------------------------------------------------
; bios dispatcher
; ------------------------------------------------------------

bios_main:
; preserve caller interrupt state
        tpa
        staa bios_saved_cc

; mask irq before stack surgery
        sei

; pull caller return address into bios_ptr
; on 6800, high byte is on top of stack for rts return
        pula
        pulb

; save pointer = address of first inline byte
        staa bios_ptr
        stab bios_ptr+1

; read command byte
        ldx bios_ptr
        ldaa 0,x
        inx
        stx bios_ptr            ; bios_ptr is the return address

; dispatch on command in a
        cmpa #cmd_putc
        beq bios_putc

        cmpa #cmd_puts
        beq bios_puts

        cmpa #cmd_crlf
        beq bios_crlf

        cmpa #cmd_getc
        beq bios_getc

        cmpa #cmd_ws
        bne bios_unknown
        jmp bios_ws

; unknown command: skip just the command byte
; and return after it
bios_unknown:
        ldx bios_ptr
        jmp bios_rts

; ------------------------------------------------------------
; command handlers
; each one must leave X pointing to the first byte
; AFTER its inline arguments before calling
; bios_rts
; ------------------------------------------------------------

bios_putc:
; inline format:
;   fcb bios_cmd_putc
;   fcb char

        ldx bios_ptr
        ldaa 0,x
        inx
; fix return address and restore irq state
        jsr bios_rts

; output character in A
        jsr conout_impl
        rts

bios_puts:
; inline format:
;   fcb bios_cmd_puts
;   fcb 'h','e','l','l','o',0
;
; on entry bios_ptr points to first char

        ldx bios_ptr        
        stx bios_tmp            ; save start of string to bios_tmp

bios_puts_scan:
        ldaa 0,x
        beq lputs_scanned
        inx
        bra bios_puts_scan

; X now points to the terminating zero
; print from saved starting pointer

lputs_scanned:
        inx                     ; one byte past the null, aka: the return address
        stx bios_ptr            ; fix the stack for return
        ldx bios_tmp            ; we stored this earlier, it's pointing to the start of the string
        jsr puts_x_impl

        jmp bios_rts_ptr

bios_crlf:
; inline format:
;   fcb bios_cmd_crlf
;   no args

        jsr crlf_impl

        jmp bios_rts_ptr

bios_getc:
; inline format:
;   fcb bios_cmd_getc
;   no inline args
;
; return value in A

        ldx bios_ptr
        jsr conin_impl

        jmp bios_rts_ptr

bios_ws:
; inline format:
;   fcb bios_cmd_warmstart
;   no args

        jsr warmstart

        jmp bios_rts_ptr

; ------------------------------------------------------------
; helper: fix caller return address and restore irq mask state
;
; entry:
;   X = address to resume at after rts
;   bios_saved_cc contains caller's original cc
;
; exit:
;   corrected return address pushed for rts
;   irq mask restored to original state
; ------------------------------------------------------------

bios_rts_ptr:
; return address stored in bios_ptr
        ldx bios_ptr

bios_rts:
; fix return address
        stx bios_tmp
        ldaa bios_tmp
        ldab bios_tmp+1
        pshb
        psha

; restore original interrupt mask state
; simplest safe method: inspect saved cc and either
; leave irq masked or unmask it
        ldaa bios_saved_cc
        anda #$10            ; isolate I bit
        bne bios_sei

bios_cli:
        cli
        rts

bios_sei:
        sei
        rts

; ------------------------------------------------------------
; warm start / monitor entry
; ------------------------------------------------------------

warmstart:
; placeholder
; replace this with monitor entry, shell, scheduler, etc.
warmstart_loop:
        bra warmstart_loop

; ------------------------------------------------------------
; console / acia support
; ------------------------------------------------------------

acia0_init:
; placeholder
;
; fill in for your actual acia and clock
; example tasks:
;   - master reset
;   - set divider
;   - set 8n1
;   - enable tx/rx
        rts

conout_impl:
; entry: A = character to send

conout_wait:
; placeholder status poll
; if you want fake-emulator output via $e000 instead,
; you could simply:
;   staa latch_reg
;   rts
;
        ldab acia0_status
        andb #acia_tdre_mask
        beq conout_wait

        staa acia0_data
        rts

conin_impl:
; return received character in A
conin_wait:
        ldab acia0_status
        andb #acia_rdrf_mask
        beq conin_wait
        ldaa acia0_data
        rts

puts_x_impl:
; entry: X points to null-terminated string
puts_x_loop:
        ldaa 0,x
        beq puts_x_done
        jsr conout_impl
        inx
        bra puts_x_loop

puts_x_done:
        rts

crlf_impl:
        ldaa #13
        jsr conout_impl
        ldaa #10
        jsr conout_impl
        rts

; ------------------------------------------------------------
; interrupt handlers
; ------------------------------------------------------------

irq_handler:
; placeholder irq service
        rti

swi_handler:
; placeholder software interrupt service
        rti

nmi_handler:
; nmi unused for now
        rti

; ------------------------------------------------------------
; vectors
; 6800 fixed vectors:
;   $fff8 irq
;   $fffa swi
;   $fffc nmi
;   $fffe reset
; ------------------------------------------------------------

        org v_irq
        fdb irq_handler

        org v_swi
        fdb swi_handler
        
        org v_nmi
        fdb nmi_handler

        org v_reset
        fdb reset