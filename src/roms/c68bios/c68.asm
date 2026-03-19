; bios.asm
;
; simple framework BIOS for a homebrew 6800 system
;
; memory map:
;   $0000-$dfff   ram
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

ram_start       equ $0000
ram_end         equ $bfff
bank_start      equ $c000
bank_end        equ $dfff
io_start        equ $e000
io_end          equ $e0ff
rom_start       equ $e100
rom_end         equ $ffff

; slot 0
bank_latch_reg  equ $e000

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

rom_base        equ $e100

; ------------------------------------------------------------
; zero page / low ram workspace
; ------------------------------------------------------------

bios_ptr        equ $0000    ; 16-bit pointer into inline parameter stream
bios_tmp        equ $0002    ; 16-bit scratch
bios_saved_cc   equ $0004    ; saved cc on entry
bios_saved_a    equ $0005    ; scratch
bios_saved_b    equ $0006    ; scratch
bios_saved_x    equ $0007    ; 16-bit scratch

; optional user-visible vectors / jump table in ram
vec_conout      equ $0010
vec_conin       equ $0012
vec_puts        equ $0014
vec_crlf        equ $0016
vec_warmstart   equ $0018

; ------------------------------------------------------------
; bios command numbers
; ------------------------------------------------------------

cmd_putc       equ $01
cmd_puts       equ $02
cmd_crlf       equ $03
cmd_getc       equ $04
cmd_ws         equ $05

; ------------------------------------------------------------
; rom starts here
; ------------------------------------------------------------

; ------------------------------------------------------------
; rom identification / version
; ------------------------------------------------------------

 bios_id:
         fcb 'd','h','6','8','0','0'

 bios_version:
         fcb 0
         fcb 1

; ------------------------------------------------------------
; cold reset entry
; ------------------------------------------------------------

; align the rom to 8KB, overlapping I/O
; eat up the i/o page 
; using this as a build id area as it's not mapped into memory
        org io_start

; actual start of rom
        org rom_start

reset:
; try putting the stack at the end of ram
        lds #ram_end

; clear condition codes
        clra
        tap

; initialize latch / bank register to known state
        staa bank_latch_reg

; install optional ram vectors
        jsr init_vectors

; initialize console / serial hardware
        jsr acia0_init

; simple banner using inline-dispatch interface
        jsr bios_main
        byte cmd_puts
        byte 'h','e','l','l','o',' ','w','o','r','l','d',13,10,0

; hand off to monitor / shell / idle loop
        jsr warmstart

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
; on 6800, low byte is on top of stack for rts return
        pula
        pulb

; save pointer = address of first inline byte
        staa bios_ptr+1
        stab bios_ptr

; read command byte
        ldx bios_ptr
        ldaa 0,x
        inx
        stx bios_ptr

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
        jsr bios_rts
        rts

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
        stx bios_tmp

bios_puts_scan:
        ldaa 0,x
        inx
        beq lputs_scanned
        bra bios_puts_scan

; X now points just past terminating zero
; print from saved starting pointer

lputs_scanned:
        ldx bios_tmp
        jsr puts_x_impl
        rts

bios_crlf:
; inline format:
;   fcb bios_cmd_crlf
;   no args

        ldx bios_ptr
        jsr bios_rts
        jsr crlf_impl
        rts

bios_getc:
; inline format:
;   fcb bios_cmd_getc
;   no inline args
;
; return value in A

        ldx bios_ptr
        jsr bios_rts
        jsr conin_impl
        rts

bios_ws:
; inline format:
;   fcb bios_cmd_warmstart
;   no args

        ldx bios_ptr
        jsr bios_rts
        jmp warmstart

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

bios_rts:
; push corrected return address for rts
; rts expects low then high on stack after pops,
; so match normal 6800 convention here

; fill this in however you like if you want a helper
; implementation without a TFR instruction, since 6800
; does not have TFR.
;
; easiest is just:
;   stx bios_tmp
;   ldaa bios_tmp+1
;   ldab bios_tmp
;
        stx bios_tmp
        ldaa bios_tmp+1
        ldab bios_tmp
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
; initialization helpers
; ------------------------------------------------------------

init_vectors:
;         ldx #bios_rom_putc
;         stx vec_conout

;         ldx #bios_rom_getc
;         stx vec_conin

;         ldx #bios_rom_puts_x
;         stx vec_puts

;         ldx #bios_rom_crlf
;         stx vec_crlf

;         ldx #bios_rom_warmstart
;         stx vec_warmstart
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

        org $fff8
        fdb irq_handler
        fdb swi_handler
        fdb nmi_handler
        fdb reset