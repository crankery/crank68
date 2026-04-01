; ------------------------------------------------------------
; BIOS for Crank68 computer
; ------------------------------------------------------------

    .global irq_handler
    .global swi_handler
    .global nmi_handler
    .global rst_handler

    .section ".bios","acr"

    .include "defs.s"

rst_handler:
    ; stack goes at the end of ram
    lds #ram_end     

    ; clear condition codes
    clra
    tap

    ; initialize bank register to known state
    staa bank_reg   

    ; initialize console / serial hardware
    jsr acia0_init

    ; output the bios banner
    ldx #st_banner_msg
    jsr putns

; fall through to monitor

; ------------------------------------------------------------
; monitor entry
; ------------------------------------------------------------

monitor:
    ldx s_crlf
    jsr puts

    ; prompt
    ldaa #':'
    jsr putc

    ; get a string from the console
    jsr gets

    ldx #s_crlf
    jsr puts

    ; print it out
    ;lda #'?'
    ;jsr putc
    ;ldx #bios_tmp
    ;jsr puts
    ;jsr put_crlf

    jsr parse_command

    ; pretend we're displaying memory somewhere
    ; x should hold the address to display
    ;ldx #0xe100
    ; a contains the count to output
    ;ldaa #16 
    ;jsr show_memory
    
    ; monitor loop
    bra monitor

parse_command:
        ldx     #bios_tmp

; skip leading spaces
.skip_spaces:
        ldaa    0,x
        beq     .done
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

        ; show memory
        cmpa    #'S'
        beq     .cmd_show

        ; unknown command
        ldx     #s_monitor_unknown
        jsr     puts
        rts

.cmd_help:
        ldx     #st_monitor_help
        jsr     putns
        rts

.cmd_show:
        inx                     ; move past 'S'
        jsr     parse_hex16_x   ; returns X = parsed value
        ldx #0xe100
        ldaa    #16
        jsr     show_memory

.done:
        rts

; print out the memory at a location in memory
; this one will print the header
; address is in x, count is in a
show_memory:
    stx zp_ptr
    staa zp_count

    ; print the address high
    ldaa zp_ptr
    jsr put_hex_byte

    ; print the address low
    ldaa zp_ptr+1
    jsr put_hex_byte

    ldaa #':'
    jsr putc

.0:
    ldaa #' '
    jsr putc

    ldx zp_ptr
    ldaa 0, x
    inx
    stx zp_ptr
    jsr put_hex_byte
    
    dec zp_count
    bne .0

    ldx #s_crlf
    jsr puts
    rts

parse_hex16_x:
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
    rti