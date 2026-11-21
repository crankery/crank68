; ------------------------------------------------------------
; BIOS for Crank68 computer
; ------------------------------------------------------------

    .global irq_handler
    .global swi_handler
    .global nmi_handler
    .global rst_handler
    .global flexboot

    .section ".bios","acr"

    .include "defs.s"

rst_handler:
    sei
    lds #ram_end
    ; A retained RAM signature distinguishes RESET/MON from a cold start.
    ldaa warm_flag
    cmpa #'C'
    bne cold_start
    ldaa warm_flag+1
    cmpa #'6'
    bne cold_start
    ldaa warm_flag+2
    cmpa #'8'
    bne cold_start
    ldaa warm_flag+3
    cmpa #'!'
    bne cold_start
    jmp monitor_start
cold_start:
    ; Give the operator about one second at 1 MHz to choose the monitor.
    clra
    staa bank_reg
    jsr acia0_init
    ldx #st_banner_msg
    jsr putns
    ldaa #'C'
    staa warm_flag
    ldaa #'6'
    staa warm_flag+1
    ldaa #'8'
    staa warm_flag+2
    ldaa #'!'
    staa warm_flag+3
    ldx #55000
startup_key_window:
    ldab acia0_reg
    bitb #acia_rdrf_mask
    bne startup_monitor
    dex
    bne startup_key_window
    jmp flexboot
startup_monitor:
    ldaa acia0_data         ; consume the key that selected the monitor
    jmp monitor             ; banner is already on the screen

monitor_start:
    sei
    ; stack goes at the end of ram
    lds #ram_end     

    ; start with bank zero; leave IRQ masked after the non-returning NMI.
    clra

    ; initialize bank register to known state
    staa bank_reg   

    ; initialize console / serial hardware
    jsr acia0_init

    ; output the bios banner
    ldx #s_crlf
    jsr puts
    ldx #st_banner_msg
    jsr putns

    jmp monitor

; ------------------------------------------------------------
; monitor entry
; ------------------------------------------------------------

monitor:
    ldx #s_crlf
    jsr puts

    ; prompt
    ldaa #':'
    jsr putc

    ; get a string from the console
    jsr gets

    ldx #s_crlf
    jsr puts

    jsr parse_command

    ; monitor loop
    bra monitor

parse_command:
        ldx     #bios_tmp

; skip leading spaces
.skip_spaces:
        ldaa    0,x
        bne     .nonempty
        rts
.nonempty:
        cmpa    #' '
        bne     .got_cmd
        inx
        bra     .skip_spaces

.got_cmd:
        ; help
        cmpa    #'?'
        beq     .cmd_help
        cmpa    #'H'
        beq     .cmd_help

        ; F alone boots FLEX; F800 is a hex address to examine.
        cmpa    #'F'
        bne     .address
        ldab    1,x
        beq     .cmd_boot

.address:
        ; An address alone examines one byte; a dot adds an inclusive end.
        jsr     parse_hex16_x
        bcs     .unknown
        stx     zp_input
        ldx     zp_value
        stx     zp_ptr
        ldx     zp_input
        jsr     skip_spaces
        ldaa    0,x
        beq     .cmd_show_single
        cmpa    #'.'
        bne     .unknown
        inx
        jsr     skip_spaces
        jsr     parse_hex16_x
        bcs     .unknown
        stx     zp_input
        ldx     zp_value
        stx     zp_end
        ldx     zp_input
        jsr     skip_spaces
        ldaa    0,x
        bne     .unknown
        ; Reject a backwards range rather than wrapping through memory.
        ldaa    zp_ptr
        cmpa    zp_end
        bhi     .unknown
        blo     .cmd_show_range
        ldaa    zp_ptr+1
        cmpa    zp_end+1
        bhi     .unknown
.cmd_show_range:
        ldaa    #1
        jmp     show_memory

.cmd_show_single:
        ldx     zp_ptr
        stx     zp_end
        clra
        jmp     show_memory

.unknown:
        ldx     #s_monitor_unknown
        jsr     puts
        rts

.cmd_help:
        ldx     #st_monitor_help
        jsr     putns
        rts

.cmd_boot:
        jmp flexboot

; Display zp_ptr through zp_end, inclusive, in rows of sixteen bytes.
; A is nonzero for a range, which also gets an ASCII column.
show_memory:
    staa zp_range
.line:
    ; print the address high
    ldaa zp_ptr
    jsr put_hex_byte

    ; print the address low
    ldaa zp_ptr+1
    jsr put_hex_byte

    ldaa #':'
    jsr putc

    ldaa #16
    staa zp_count
    clr zp_row_count
    ldx #zp_ascii_row
    stx zp_ascii_ptr
.next_byte:
    ldaa #' '
    jsr putc

    ldx zp_ptr
    ldaa 0, x
    psha
    jsr put_hex_byte
    pula

    ; Keep a printable copy. Read each memory location only once: device
    ; registers may change or have side effects on a second read.
    anda #0x7f
    cmpa #' '
    bcs .unprintable
    cmpa #0x7f
    bne .save_ascii
.unprintable:
    ldaa #'.'
.save_ascii:
    ldx zp_ascii_ptr
    staa 0,x
    inx
    stx zp_ascii_ptr
    inc zp_row_count

    ldx zp_ptr
    cpx zp_end
    beq .last
    inx
    stx zp_ptr
    dec zp_count
    bne .next_byte

    jsr print_row_end
    bra .line
.last:
    jsr print_row_end
    rts

; Print the optional ASCII column at a fixed position, then end the row.
print_row_end:
    ldaa zp_range
    beq .newline
    ldaa #16
    suba zp_row_count
    staa zp_count
    beq .divider
.pad:
    ldaa #' '
    jsr putc
    jsr putc
    jsr putc
    dec zp_count
    bne .pad
.divider:
    ldaa #' '
    jsr putc
    jsr putc
    ldaa #'|'
    jsr putc
    ldx #zp_ascii_row
    ldaa zp_row_count
    staa zp_count
.ascii_char:
    ldaa 0,x
    jsr putc
    inx
    dec zp_count
    bne .ascii_char
    ldaa #'|'
    jsr putc
.newline:
    ldx #s_crlf
    jsr puts
    rts

; X points to a hex address. Return X after 1-4 digits and the value in
; zp_value. Carry is set for an absent or overlong address.
parse_hex16_x:
    clr zp_value
    clr zp_value+1
    clr zp_digits
.digit:
    ldaa 0,x
    jsr hex_nibble
    bcs .end
    staa zp_nibble
    ldaa zp_digits
    cmpa #4
    beq .parse_bad
    inc zp_digits
    asl zp_value+1
    rol zp_value
    asl zp_value+1
    rol zp_value
    asl zp_value+1
    rol zp_value
    asl zp_value+1
    rol zp_value
    ldaa zp_value+1
    oraa zp_nibble
    staa zp_value+1
    inx
    bra .digit
.end:
    ldaa zp_digits
    beq .parse_bad
    clc
    rts
.parse_bad:
    sec
    rts

; Convert ASCII hex in A to a nibble; carry set if it is not hex.
hex_nibble:
    cmpa #'0'
    bcs .nibble_bad
    cmpa #'9'
    bhi .letter
    suba #'0'
    clc
    rts
.letter:
    cmpa #'A'
    bcs .nibble_bad
    cmpa #'F'
    bhi .nibble_bad
    suba #'A'-10
    clc
    rts
.nibble_bad:
    sec
    rts

skip_spaces:
    ldaa 0,x
    cmpa #' '
    bne .spaces_done
    inx
    bra skip_spaces
.spaces_done:
    rts

; acia0_init
; reset the acia
; load the config switches and write them to the config register
acia0_init:
    ; reset acia
    ldaa #0b11
    staa acia0_reg

    ; read the configuration switches
    ldaa config_switches

    ; write them out verbatim for now
    ; suggested setting is 0x15 (no interrupts, 8N1, /16 clock divider)
    staa acia0_reg
    rts

; putc
; send a single byte to the console
; entry: A = character to send
; affects B
; does not affect X
putc:
        staa acia0_data

        ; wait for byte to send
        .0:
                ldab acia0_reg
                andb #acia_tdre_mask
                beq .0
        rts

; puts
; output the null terminated string pointed to by the x-register
; affects a
; putc affects b
; x points to teminating byte of string on return
puts:
    ldaa 0,x    
    beq .0      ; \0 = end of string
    jsr putc
    inx    
    bra puts
.0:
    rts


; print a table of strings
; x points to the count of strings
; a/c/x are modified
putns:
    ldaa 0, x
.1:
    psha        ; stash the count remaining
    inx         ; go to the start of this string
    jsr puts    ; print it out
    stx zp_ptr  ; save x
    ldx #s_crlf  ; grab the \r\n string
    jsr puts    ; print it out
    ldx zp_ptr  ; restore x (to the null value at the end of the string)
    pula        ; restore the count to a
    deca
    bne .1      ; print out the next string 
    rts

; output A in 2 digit hex format
put_hex_byte:
    psha
    lsra
    lsra
    lsra
    lsra
    jsr put_hex_digit
    pula
    jsr put_hex_digit
    rts

; output low nybble of A in hex format
put_hex_digit:
    anda #0xf
    cmpa #0x9
    bhi .1
    ; 0-9
    adda #'0'
    jsr putc
    rts
.1:
    ; A-F
    adda #'A'-10
    jsr putc
    rts

; getc
; receive single byte from console
; return received character in A
; affects a,b
; does not affect x
getc:
    ; check to see if can send a character
    ldab acia0_reg
    andb #acia_rdrf_mask

    ; loop if the data ready flag isn't set
    beq getc

    ; read the character from the console
    ldaa acia0_data
    rts

; gets
; get a string from the console
; string returned at bios_tmp

    .equ gets_count, bios_tmp + 0xff;

gets:
    ldx #bios_tmp

    ; 255 characters left
    ldaa #0xff
    staa gets_count
.0:
    ; get a character into a
    jsr getc

    ; cr?
    cmpa #'\r'
    beq .2

    ; linefeed?
    cmpa #'\n'
    beq .2

    ; backsace?
    cmpa #'\b'
    beq .3

    ; delete?
    cmpa #0x7f
    beq .3

    ; skip other control characters (< 0x20)
    cmpa #' '
    blt .0

    ; add character to buffer
    ; if 'a' <= A <= 'z', convert to uppercase
    cmpa #'a'
    bcs .1
    cmpa #'z'
    bhi .1

    ; ASCII: 'a' - 'A' = 0x20
    suba #0x20

.1: ; store upper case character in the buffer
    staa 0, x
    inx

    ; decrement the number of characters remaining in the buffer
    dec gets_count
    ; end the string here if it's reached zero
    beq .2

    ; echo the character back to the terminal
    jsr putc
    
    ; get the next character
    bra .0
 
.2: ; terminate the string
    ldaa #0
    staa 0, x

    rts
  
.3: ; backspace
    ; see if we have zero characters so far
    ldab #0xff
    cmpb gets_count

    ; just ignore it if so
    beq .0

    ; we have one less character
    dex
    ; we have one more character left
    inc gets_count

    ; output "\b \b" to rubout the last character typed
    ldaa #'\b'
    jsr putc
    ldaa #' '
    jsr putc
    ldaa #'\b'
    jsr putc
    bra .0



; ------------------------------------------------------------
; interrupt handlers
; ------------------------------------------------------------

irq_handler:
    rti

swi_handler:
    rti

nmi_handler:
    ; NMI abandons the interrupted program, including FLEX's RAM workspace.
    jmp monitor_start

; Keep this entry at the former MIKBUG $FFC0 address. No monitor RAM or
; stack is needed: the boot sector takes ownership after the jump to $0100.
    .section ".boot","acr"
flexboot:
    sei
    ldaa #3
    staa acia0_reg
    ldaa #0x11
    staa acia0_reg
    clr bank_reg+2              ; $E002: select SRAM page zero
    lds #0x01ff
    ldx #0xc100
flexcopy:
    dex
    ldaa 0,x
    psha
    cpx #0xc000
    bne flexcopy
    jmp 0x0100
