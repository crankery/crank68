; vasm buildable hack
; dave hamilton, 2026
; 
; this was originally generated from the copy of mikbug2.asm and the translate.py script in the tools directory
; gettig the variable address equates properly setup was a bit too much to bother trying to automate.
; 
; i claim no ownership of this file and if the rightful owners object to my posting it I will remove it.

; anyway, this builds on vasm6800_std, no vlink required
; it should be possible to move the main binary. i removed all the hard coded addresses (there were two of them)
; you might want to change baseorg, RAM_PTR and stack the io area (currently 0xE000-0xE0FF)
; for your M6800 machine :) haha
; - dave

; converted to an assembly file from a crappy pdf by 
; members of the motorola 6809 / 6309, 6800 assembly 
; language programming facebook group 
; by craig jones,ray bellis 
; 


; 
; 
; ram - locations devoted to variable information 
; 
; 

    .equ RAM_PTR, 0xBF00

.macro ALLOC name, size
    .equ \name, RAM_PTR
    .equ RAM_PTR, RAM_PTR + \size
.endm

    .equ nbrbpt, 8

; initialized from rom at start
    ALLOC iov, 2
    ALLOC bega, 2
    ALLOC enda, 2
    ALLOC nio, 2
    ALLOC sp, 2
    ALLOC swi1, 2
    ALLOC swi2, 2
    ALLOC brins, 8
    .equ branen, RAM_PTR

; initialized to zero at start
    ALLOC outsw, 1
    ALLOC trcadr, 2
    ALLOC trcins, 1
    ALLOC ntrace, 2

    ALLOC brkadr, nbrbpt*2
    ALLOC brkins, nbrbpt*2

    ALLOC cksm, 1
    .equ asave, cksm
    .equ temp, cksm

    ALLOC bytect, 1
    .equ mcont, bytect

    ALLOC xhi, 1
    ALLOC xlow, 1

    ALLOC ssave, 2
    .equ tw, ssave

    ALLOC brksin, 1
    ALLOC brktrc, 1

    .equ endin0, RAM_PTR
    ALLOC aciat, 1

    ; EXORTAPE RAM
    ALLOC fidh, 1
    ALLOC fidl, 1
    ALLOC startp, 1
    ALLOC stoppg, 1
    ALLOC totcnt, 1
    ALLOC patdel, 1
    ALLOC cl, 1
    ALLOC cll, 1
    ALLOC clll, 1

    ; tape temporaries
    ALLOC h, 1
    ALLOC l, 1
    ALLOC q, 1
    ALLOC r, 1
    ALLOC s, 1
    ALLOC v, 1

    .equ t1, cl

; stack is at 0x100

    .equ stackpage, 0xBF00
    .equ stack, stackpage + 0xff

; nam mikbug 
; ttl 2.0 with audio cassette 
; rev 0 
; copyright (c) 1977 by motorola inc. 
; 
; mikbug (tm) motorola 
; 
; austin, texas 
; microcomputer capital of the world! 
; 
; l load 
; m memory change 
; p print/punch dump 
; r display contents of target stack 
; cc b a x p s 
; s 1,set speed for 10 cps 
; 3,set speed for 30 cps 
; b print out all breakpoints 
; c continue execution from current location 
; n next instruction 
; t trace 'N' instructions 
; g go to location 'N' 
; d delete all breakpoints 
; u reset breakpoint with address 'N' 
; v set a breakpoint with address 'N' 
; e exortape cassette interface 
; 
            .equ swiop, 0x3f            ; swi op code

            .org 0xe000 ; slot 0

            .org 0xe010 ; slot 1
acias:      .space 0x01
aciad:      .space 0x01

            .org 0xe100
baseorg:    

; 
; i/o interrupt sequence 
; 
io:         ldx iov
            jmp 0,x
; 
; nmi sequence 
; 
powdwn:     ldx nio                     ; get nmi vector
            jmp 0,x
; 
; swi interrupt sequence 
; 
sfei:       ldx swi1
            jmp 0,x
; 
; jump table to routines performing mikbug fctn's 
; 
fctabl:
            .byte "B"                   ; "B" - print all breaks
            .word pntbrk
            .byte "C"                   ; "C" - continue
            .word cont
            .byte "D"                   ; "D" - delete all breaks
            .word delbrk
            .byte "G"                   ; "G" - go to entered address
            .word goto
            .byte "L"                   ; "L" - load
            .word load
            .byte "M"                   ; "M" - memory change
            .word change
            .byte "N"                   ; "N" - next (trace 1 instr)
            .word next
            .byte "P"                   ; "P" - punch
            .word punch
            .byte "R"                   ; "R" - print stack
            .word pstak1
            .byte "S"                   ; "S" - change speed for tty
            .word spd
            .byte "T"                   ; "T" - trace n instructions
            .word trace
            .byte "U"                   ; "U" - reset a breakpoint
            .word rstbrk
            .byte "E"                   ; "E" - exortape cassette interface
            .word exort
            .byte "V"                   ; "V" - set a breakpoint
            .word setbrk
fctben:
; 
; initialization/reset code 
; 
adrstr:
            .word stack                 ; init for "SP"
            .word swi15                 ; init for "SWI1"
            .word brkinh                ; init for "SWI2"
; 
            bra brg                     ; "BRA" inst is replaced by
            jmp brnogo                  ; cond bra inst in rout.
brg:        jmp brgo                    ; which determines if
; bra is go/nogo 
; 
; build address 
; 
baddr:      bsr byte                    ; read 2 frames
            staa xhi
            bsr byte
            staa xlow
            ldx xhi                     ; (x) address we built
            rts
; input byte (two frames) 
byte:       bsr inhex                   ; get hex char
byte2:      asla
            asla
            asla
            asla
            tab
            bsr inhex
            aba
            tab
            addb cksm
            stab cksm
            rts
outhl:      lsra                        ; out hex left bcd digit
            lsra
            lsra
            lsra
outhr:      anda #0xf                   ; out hex right bcd digit
            adda #0x30
            cmpa #0x39
            bls outch
            adda #0x7
; output one char 
outch:      jmp outch1
inch:       jmp inch1
; print data pointed at by x-reg 
pdata2:     bsr outch
            inx
pdata1:     ldaa 0,x
            cmpa #4
            bne pdata2
            rts                         ; stop on eot
; 
; input address 
; 
getadd:     bsr pcrlf                   ; print cr lf
            ldx #mcl4
            bsr pdata1                  ; ask for begaddr
            bsr baddr                   ; get beg addr
            stx bega
            bsr pcrlf                   ; print cr lf
            ldx #mcl5
            bsr pdata1                  ; ask for end addr
            bsr baddr                   ; get end address
            stx enda
            rts                         ; *
; print cr lf 
; 
pcrlf:      stx xhi                     ; save xr
            ldx #mcl1
            bsr pdata1                  ; print crlf
            ldx xhi
            rts

; 
inhex:      bsr inch
inhex2:     suba #0x30
            bmi c1                      ; not hex
            cmpa #0x09
            ble in1hg
            cmpa #0x11
            bmi c1                      ; not hex
            cmpa #0x16
            bgt c1                      ; not hex
            suba #7
in1hg:      rts
; 
out2h:      ldaa 0,x                    ; output 2 hex char
out2ha:     bsr outhl                   ; out left hex char
            ldaa 0,x                    ; pick up byte again
            inx
            bra outhr                   ; output right hex char and rts
out4hs:     bsr out2h                   ; output 4 hex char + space
out2hs:     bsr out2h                   ; output 2 hex char + space
outs:       ldaa #0x20                  ; space
            bra outch                   ; (bsr & rts)
load:
            ldaa #021
            bsr outch                   ; output char
; 
; turn reader relay on 
; 
            ldaa aciat                  ; get acia control reg format
            oraa #0x40                  ; set rts to turn rdr relay on
            staa acias                  ; turn it on
; 
            inc outsw                   ; do not echo tape
; 
load3:      bsr inch
            bra load4
enter:      jmp ent1                    ; mikbug 1 entry point
load4:
            cmpa #'S'
            bne load3                   ; 1st char not (s)
            bsr inch                    ; read char
            cmpa #'9'
            beq c1
            cmpa #'1'
            bne load3                   ; 2nd char not (1)
            clr cksm                    ; zero checksum
            jsr byte                    ; read byte
            suba #2
            staa bytect                 ; byte count
; build address 
            jsr baddr
; store data 
load11:     jsr byte
            dec bytect
            beq load15                  ; zero byte count
            staa 0,x                    ; store data
            cmpa 0,x                    ; check data
            bne load19                  ; data not stored
            inx
            bra load11
; 
; does checksum check? 
; 
load15:     incb
            beq load3
load19:     ldaa #'?'                   ;  print question mark
            bsr outch1
c1:         jmp contrl
; 
; change memory (m aaaa dd nn) 
; 
change:     jsr baddr                   ; build address
            bsr outs                    ; output space
chang:      ldx xhi
            bsr out2hs                  ; print data old
            dex
cha1:       bsr inch1                   ; input char
            cmpa #0x0a
            beq lf                      ; check for line feed
            cmpa #0x5e
            beq ua                      ; check for ^
            jsr inhex2                  ; s bsr byte
            jsr byte2                   ; get new byte
            staa 0,x                    ; change memory
            cmpa 0,x
            bne load19                  ; no change
            bra cha1
lf:         inx                         ; inc addr
            bra ua1
ua:         ldaa #0x0a
            bsr outch1                  ; output lf
            dex                         ; dec addr
ua1:        stx xhi                     ; sav data addr
            ldx #mcl+1
            jsr pdata1                  ; print cr
            ldx #xhi
            jsr out4hs                  ; output data addr
            bra chang
; 
outch1:     pshb                        ; save breg
outc1:      ldab acias
            asrb
            asrb
            bcc outc1                   ; xmit not ready
            staa aciad                  ; output char
            pulb
            rts
; 
; input one char to areg 
inch1:      ldaa acias
            asra
            bcc inch1                   ; receiver not ready
            ldaa aciad                  ; input char
            anda #0x7f                  ; reset parity bit
            cmpa #0x7f
            beq inch1                   ; rubout"del
            tst outsw                   ; should input be echoed?
            beq outch1                  ; if so, output the char
            rts                         ; else,return to caller of inch1

; 
; constant initialization 
; s = pointer to rom bytes to be copied to ram 
; x = pointer to ram bytes to be initialized 
; 
start:                                  ; actual code start
            lds #adrstr                 ; start of constant data
            ldx #sp                     ; start of ram area
; 
inilp1:     pula                        ; get next constant byte
            staa 0,x                    ; init next ram byte
            inx                         ; update pointer
            cpx #branen                 ; end of constant ram area?
            bne inilp1                  ; no, continue initialization
; 
; initialization to 0 
; x holds index of 1st byte to be set to 0 
; 
inilp2:     clr 0,x                     ; clear next byte of ram
            inx                         ; update index
            cpx #endin0                 ; any more bytes to init?
            bne inilp2                  ; no, continue clearing
; 
; set cc so when we 'GO' to user pgm the 
; interupt mask is set 
; 
            ldaa #0xd0
            staa brktrc                 ; put in stack to be pulled jdh: not sure about this one
; 
; initialize acia 
; 
            ldaa #3                     ; master reset code
            staa acias                  ; reset acia
; 
inz:        ldaa #0b00010001            ; char len=8" no parity
; 2 stop bits 
; 
inz1:       staa aciat                  ; save for control loop acia in
; 
            staa acias                  ; inz acia
ent1:       lds sp
            jsr pcrlf
            bra contb                   ; skip to insure mikbug : compat.
inch2:      bra inch1                   ; mikbug 1.0 input 1 character
contb:      ldx #mcl2                   ; print header
            jsr pdata1                  ; print data string
            ldx #nmi                    ; init pdn
            stx nio
; 
; main command/control loop 
; 
contrl:
; 
; restore stack pointer register 
; 
            lds sp                      ; sp was initialized earlier
; 
            ldaa aciat                  ; get proper acia init bits
; for user's terminal 
            staa acias                  ; inz acia
; 
            clr outsw                   ; make sure input is echoed
; 
            ldx #mcloff                 ; terminal init string
            jsr pdata1                  ; print data string
; 
            bsr inch1                   ; read command character
            tab                         ; save character in b
            bra cnta                    ; skip over mikbug 1.0 vector
out2:       bra outch1                  ; mikbug 1.0 " output 1 char routine
cnta:       jsr outs                    ; print space after command
; 
; b register holds character input by user 
; use jump table to go to appropriate routine. 
; 
            ldx #fctabl                 ; x:= address of jump table
nxtchr:     cmpb 0,x                    ; does input char match?
            beq goodch                  ; yes, goto apropriate routine
            inx                         ; else, update index into table
            inx
            inx
            cpx #fctben                 ; end of table reached?
            bne nxtchr                  ; no, try next char
            bra contrl                  ; no match, reprompt user
; 
; 
goodch:     ldx 1,x                     ; get address from j.t.
            jmp 0,x                     ; goto appropriate routine
; 
; 
; nmi entry 
; 
nmi:        sts sp                      ; save stack
            jsr pcrlf
            ldaa #'B'                   ;  print b
            bsr out2
            jsr outs
            ldaa #2                     ; remove breakpoints
            bsr brksub
            bra pstak1
; 
; set speed for user tty 
; 
spd:        bsr inch2                   ; input char
            cmpa #'1'
            beq inz
            ldaa #0x15
            bra inz1                    ; set 2 stop bits
; 
; 
baddrj:     jmp baddr                   ; go build address
; 
; 
; reset all breakpoints 
; 
delbrk:     ldaa #1                     ; reset breaks flag
bsrbrk:     bsr brksub                  ; break handling subr.
            bra cntrl2                  ; return to command level
; 
; reset 1 breakpoint 
; 
rstbrk:     bsr baddrj                  ; puts user entered address
; into xhi,xlo 
            clra                        ; reset 1 break flag
            bra bsrbrk                  ; go reset 1
; 
; print out all non-zero break addresses 
; 
pntbrk:     jsr pcrlf                   ; do cr"lf
            ldaa #2                     ; print break addresses flags
            bra bsrbrk                  ; go print
; 
; set one break 
; 
setbrk:     bsr baddrj                  ; get user entered address (xhi,xlo)
            ldaa #4                     ; set one break flag
            bsr brksub                  ; go set it
            bra pntbrk                  ; print all breakpoints
; 
; go to requested 
; 
goto:       bsr baddrj                  ; go get address from user
; xhi,xlow hold address 
            ldaa #0xff                  ; flag for putting in breaks
            bsr brksub                  ; go put in breaks
            tsx
            ldaa xhi                    ; save pch on stack
            staa 5,x
            ldaa xlow                   ; push pcl
            staa 6,x
            rti                         ; go to user prg
; 
; single instruction trace requested 
; 
next:       ldx #1                      ; # instructions to trace
trace2:     clr brktrc                  ; clear flag indicating trace
; is due to break 
trace3:     stx ntrace                  ; save # inst's to trace
; is due to break 
            ldx sp                      ; x : = stack pointer
            ldx 6,x                     ; x : = address of instr to be ex
            stx trcadr                  ; save in trace address store
            ldaa 0,x                    ; get instruction to be traced
            staa trcins                 ; save in trace instruction store
            jmp contrc                  ; go to continue trace part of
; 
; multiple instruction trace 
; 
trace:      bsr baddrj                  ; get # of instructions to trace
            bra trace2                  ; go trace'm
; 
; continue execution 
; 
cont:       inc brktrc                  ; trace 1 to restore swi's
            ldx #1                      ; one trace only
            bra trace3
; 
; 
; r command 
; 
; print stack contents 
; 
pstak1:     jsr pcrlf                   ; print cr lf
            ldx #mcl3                   ; print header
            jsr pdata1
pstak:      bsr print                   ; print stack
cntrl2:     jmp contrl                  ; return to command level
; 
; 
; brksub 
; 
; 
; this routine does a number of operations having 
; to do with breakpoints. 
; 
; the a register determines function performed: 
; 
; a = -1 => breaks are put into user's code 
; a = 0 => the breakpoint whose address is in 
; xhi, xlo is purged; 
; all breakpoints are temporarily removed 
; a = 1 => all breakpoints are purged 
; a = 2 => all breakpoints are printed out 
; all breakpoints are temporarily removed 
; a = 3 => all breakpoints are temporarily removed 
; a = 4 => the break address in xhi, xlo is 
; put into the first zero breakpoint 
; position; all breaks are temporarily removed 
; 
; 
; 
brksub:
            sts ssave                   ; save s so we can use
            staa asave                  ; a holds the function #
; 
            ldx #brkadr                 ; init x for loop through breaks
; 
; start of loop through break addresses 
; 
brklp:      ldaa asave                  ; get function #
            lds 0,x                     ; s:=next address in brrkpt list
            beq ln                      ; if 0, then not a valid break
; 
            tst brksin                  ; are breaks in user's code?
            beq nobrin                  ; branch, if not
; 
; breaks are in user's code 
; 
            tsta                        ; should breaks be in?
            bmi bkdone                  ; yes, return to caller
; 
; breaks are to be taken out of user's 
; code temporarily 
; 
brk2:       ldaa 2*nbrbpt,x             ; get instr. belong-
; ing in user code 
            psha                        ; put it there
; 
; other loop actions to be performed each time through 
; loop when break address not equal to 0. 
; 
bkcon1:     ldaa asave                  ; what function is to be done
            beq fndrpl                  ; see if breakpoint needs to
; be replaced 
            cmpa #1                     ; is break address to be reset?
            beq clrbrk                  ; yes, set brkadr to 0
; 
            cmpa #2                     ; is brk addr to be printed?
            beq prntbk                  ; yes, go print address
; 
; update loop index and loop if appropriate 
; 
bkcon2:     inx                         ; make x point to
            inx                         ; next break address
bkcon3:     cpx #brkins                 ; any more breaks?
            bne brklp                   ; yes,loop
; 
; wrap-up processing and exit 
; 
            clra                        ; a = breaks in flag
            tst asave                   ; is function = -1?
            bpl bkput                   ; no, so brksin = 0
            inca                        ; fctn = -1 => brksin:=1
bkput:      staa brksin                 ; store appropriate flag
; 
; restore s-reg and return to caller 
; 
bkdone:     lds ssave                   ; restore user s-reg
            rts                         ; return
; 
; 
; miscellaneous routines for brksub 
; 
; breakpoint address = 0 - if function = 4 then 
; put breakpoint address in current position 
; a holds the function #, x holds breakpoint index 
; 
ln:         cmpa #4                     ; is function = 4
            bne bkcon2                  ; if not, then continue loop
; 
            lds xhi                     ; get new break address
            sts 0,x                     ; put in current position
; 
            dec asave                   ; do not place address more
; than once-cont to 
; take out breakpoints 
            bra bkcon2                  ; continue loop
; 
; breaks are not in and address is non-zero. 
; if function = -1 then swi's are to be put in. 
; a holds function number, s holds address 
; 
nobrin:     tsta                        ; is function = -1
            bpl bkcon1                  ; no, continue
; 
            des                         ; make address point to 1 less
            pula                        ; get user instruction
            staa 2*nbrbpt,x             ; save
            ldaa #swiop                 ; get swi op code
            psha                        ; replace user instruction
            bra bkcon2                  ; continue loop
; 
; function=0 brk addr not = 0, user's instr 
; is in (not swi). 
; if address = xhi,xlo then set address = 0 
fndrpl:     ldaa 0,x                    ; get top byte of address
            cmpa xhi                    ; do top bytes compare
            bne bkcon2                  ; no,continue loop
            ldab 1,x                    ; get low byte of addr
            cmpb xlow                   ; same for low bytes
            bne bkcon2
; 
clrbrk:     clr 0,x                     ; clear out break
            clr 1,x                     ; address field
            bra bkcon2                  ; continue loop
; 
; 
ot2hs:      jmp out2hs
ot4hs:      jmp out4hs
; 
; 
; print out break address 
; function = 2, break address not = 0, x = address in 
; 
prntbk:     lds ssave
            bsr ot4hs                   ; output address and space
            bra bkcon3                  ; out4hs increments x,
; so bypas 2 inx's 
; 
; print contents of stack 
; 
print:      jsr pcrlf                   ; print cr lf
            ldx sp                      ; print out stack
            inx
            bsr ot2hs                   ; condition codes
            bsr ot2hs                   ; acc-b
            bsr ot2hs                   ; acc-a
            bsr ot4hs                   ; x-reg
            bsr ot4hs                   ; p-counter
            ldx #sp
            bsr ot4hs                   ; stack pointer
            rts


; punch dump 
; punch from beginning address (bega) thru ending 
; address (enda) 
; 

mtape1:     .byte 0xd,0xa,0,0,0,0,"S","1",4  ; punch format

punch:

            jsr getadd                  ; get address
            ldaa #0x12                  ; turn tty punch on
            jsr outch                   ; out char
; 
; punch leader - 25 nulls 
; 
            ldab #25                    ; b holds # nulls to punch
pnull:      clra                        ; a=0 (null char)
            jsr outch                   ; go output null
            decb                        ; decrement counter
            bne pnull                   ; if not done, then loop
; 
            ldx bega
            stx tw                      ; temp beginning address
pun11:      ldaa enda+1
            suba tw+1
            ldab enda
            sbcb tw
            bne pun22
            cmpa #16
            bcs pun23
pun22:      ldaa #15
pun23:      adda #4
            staa mcont                  ; frame count this record
            suba #3
            staa temp                   ; byte count this record
; punch c/r,l/f,nulls,s,1 
            ldx #mtape1
            jsr pdata1
            clrb                        ; zero checksum
; punch frame count 
            ldx #mcont
            bsr punt2                   ; punch 2 hex char
; punch address 
            ldx #tw
            bsr punt2
            bsr punt2
; punch data 
            ldx tw
pun32:      bsr punt2                   ; punch one byte (2 frames)
            dec temp                    ; dec byte count
            bne pun32
            stx tw
            comb
            pshb
            tsx
            bsr punt2                   ; punch checksum
            pulb                        ; restore stack
            ldx tw
            dex
            cpx enda
            bne pun11
            jsr pcrlf
            ldx #meof
            jsr pdata1                  ; output eof
            bra ctrl                    ; branch to contrl

; punch 2 hex char, update checksum 
punt2:      addb 0,x                    ; update checksum
            jmp out2h                   ; output two hex chars and rts
; 
; swi-1 software interrupt level 1 processing 
; 
swi15:
            sts sp                      ; save user's sp
; 
            ldaa #3
            jsr brksub                  ; go take out all the breaks
; 
; decrement p-counter 
; 
            tsx                         ; x:=stack pointer - 1
            tst 6,x                     ; if lower byte = 0 => borrow
            bne swi151                  ; branch if borrow not req'd
            dec 5,x                     ; decrement upper byte
swi151:     dec 6,x                     ; decrement lower byte
; 
; test for address trace or break 
; 
            ldx 5,x                     ; x:=p counter
            cpx trcadr                  ; is swi for trace?
            beq trcinh                  ; yes, go to trace int handler
; 
            ldaa 0,x                    ; get instruction causing swi
            cmpa #swiop                 ; was it replaced by call to break
            bne brkinh                  ; yes, so must be a break
; 
; user swi-transfer through level 2 swi 
; 
            tsx                         ; x:=stack pointer
            inc 6,x                     ; update low byte of p-counter
            bne incnov                  ; branch if no carry
            inc 5,x                     ; update high byte if necessary
incnov:     ldx swi2                    ; x:=pointer to level 2 swi handler
            jmp 0,x                     ; go to level 2 handler
; 
; 
; 
; 
; break interrupt handler 
; 
brkinh:
            jsr print                   ; stop and show regs to user
ctrl:       jmp contrl                  ; return to control loop
; 
; trace interrupt handler 
; p-counter has been decremented to point at swi 
; trcins holds op code replaced by swi 
; x hold address where trace swi is 
; 
trcinh:     ldaa trcins                 ; get op code of traced instr
            staa 0,x                    ; restore to user's code
; 
            tst brktrc                  ; is processing to be
; immediately continued? 
            beq nbktrc                  ; branch if not
; 
; processing is to 'CONTINUE' 
; 
            clr brktrc                  ; reset continue flag
            ldaa #0xff                  ; flag to set breaks in code
            jsr brksub                  ; put breaks in
            clr trcadr                  ; no more trace, so clear address
            clr trcadr+1
            rti                         ; continue
; 
; trace is due to n or t trace commands 
; 
nbktrc:     jsr print                   ; print stack
            ldx ntrace                  ; get # instructions to trace
            dex                         ; decrement count
            stx ntrace                  ; and restore
            beq ctrl                    ; branch if all traces done
; 
; trace not done - trace next instruction 
; 
contrc:     ldaa trcins                 ; get current instruction
            staa brins                  ; save in case it's a branch
            bsr opcbyt                  ; go get # bytes"type
            tsta                        ; check for branch
            bpl ckobra                  ; check for other than branch
; 
; relative branch type instruction 
; determine where to put swi 
; s- holds pointer to user stack after swi 
            pula                        ; get condition code
            des                         ; update stack pointer after pull
            oraa #0b00010000            ; make int's inhibited
            tap                         ; restore user's c. code reg
            jmp brins                   ; go see how relative branch
; fares 
; 
; branch was nogo - put swi at next instruction 
; 
brnogo:     ldaa #2                     ; a = # bytes after current instr
            bra ckobra                  ; go put swi appropriately
; 
; branch was go, put swi at address being 
; jumped to 
; 
brgo:       ldx trcadr                  ; x : = trace address
            ldaa 1,x                    ; get branch offset
            inx                         ; offset is relative to
            inx                         ; instr following branch
            bmi brgodc                  ; branch if offset negative
brg1:       bsr incx_                   ; increment x by amount in
; a reg 
brg2:       stx trcadr                  ; save address of next
; instr to stop on 
            ldaa 0,x                    ; get instruction to be replaced
            staa trcins                 ; save
            ldaa #swiop                 ; get swi op code
            staa 0,x                    ; replace instr with swi
            lds sp                      ; get original stack pointer
            rti                         ; trace another instr
; 
; x needs to be decremented (offset negative) 
; 
brgodc:     dex                         ; decrement address
            inca                        ; increment counter
            bne brgodc                  ; if counter not 0, branch
            bra brg2                    ; if done, go return to user prog
; 
; subroutine to increment x by contents of a 
; 
incx_:      tsta                        ; is a = 0?
            beq incxr                   ; if so, inc done
inxlp:      inx                         ; else increment x
            deca                        ; decrement count
            bne inxlp                   ; if count not yet 0, loop
incxr:      rts                         ; return from this subroutine
; 
; instruction to be traced is not a branch 
; 
ckobra:     ldx trcadr                  ; x : = trace address
            ldab 0,x                    ; get instr to be traced
            cmpb #0x6e                  ; is it a jump, indexed?
            beq jmpidx                  ; yes, go simulate jump idxed
            cmpb #0x7e                  ; jump, extended?
            beq jmpext
            cmpb #0xad                  ; jsr, indexed?
            beq jmpidx                  ; (jump idxed is same as
; transfer of control) 
            cmpb #0xbd                  ; jsr, extended?
            beq jmpext
            cmpb #0x3b                  ; rti?
            beq rtisim
            cmpb #0x39                  ; rts?
            beq rtssim
            cmpb #0x8d                  ; bsr?
            beq brgo                    ; (branch processing)
; 
; not a branch, jump. rti, rts 
; a register holds # bytes in instruction 
; 
            bra brg1                    ; put in new swi and
; trace next instruction 
; 
; jump, jsr indexed simulation 
; 
jmpidx:     ldaa 1,x                    ; a : = address offset
            tsx
            ldx 3,x                     ; get targets x reg
            bra brg1                    ; update x, trace next instr
; 
; jump, jsr extended 
; 
jmpext:     ldx 1,x                     ; get address to be jumped to
            bra brg2                    ; go trace next instr.
; 
; rti encountered 
; 
rtisim:     tsx
            ldx 12,x                    ; get p-counter from stack
            bra brg2                    ; go trace next instr.
; 
; rts encountered 
; 
rtssim:     tsx
            ldx 7,x                     ; get return p-reg from stack
            bra brg2                    ; go trace next instr
; 
; 
; opbcyt 
; 
; this routine determines the # of bytes in an instruction 
; given its op code. 
; 
; input: a holds the op code 
; 
; output: x holds the index of table element 
; b not restored 
; a holds # bytes in instruction 
; except for branches in which case is negative 
; 
; 
; 
opcbyt:
            tab                         ; b:= op code
            lsra
            lsra
            lsra                        ; put 4 upper bits of op code in
            lsra                        ; lower 4 bits of a
; 
            ldx #opbttb                 ; x:= address of table
            bsr incx_                   ; increment x to point to correct
; 
            ldaa 0,x                    ; get table entry
            bne opbtrt                  ; if not 0 then no further
; processing needed 
; 
; if top 4 bits = 8 or c, then there are two classes 
; of instructions: 2 byte instructions and 
; ce, 8c and 8e which are 3 byte instructions 
; 
            ldaa #2                     ; # bytes in most of 8# instructions
            cmpb #0x8c                  ; 3 byte instruction?
            beq opbt3                   ; yes, update a
            cmpb #0xce                  ; 3 byte instr?
            beq opbt3                   ; yes, update a
            cmpb #0x8e                  ; 3 byte instruction?
            bne opbtrt                  ; no, return
; 
opbt3:      inca                        ; # bytes in instruction:=3
; 
opbtrt:     rts                         ; return to caller
; 
; op code to number of bytes conversion table 
; 
; # bytes top 4 bits of opcode 
; ------- -------------------- 
; 
opbttb:
            .byte 1                     ; 0
            .byte 1                     ; 1
            .byte 2+0b10000000          ; 2 ( minus=> branches )
            .byte 1                     ; 3
            .byte 1                     ; 4
            .byte 1                     ; 5
            .byte 2                     ; 6
            .byte 3                     ; 7
            .byte 0                     ; 8 # bytes=2 except 8c,8e
            .byte 2                     ; 9
            .byte 2                     ; a
            .byte 3                     ; b
            .byte 0                     ; c # bytes = 2 except ce
            .byte 2                     ; d
            .byte 2                     ; e
            .byte 3                     ; f
; 
; constant data 
; 
meof:       .byte "S9030000FC"
            .byte 4
mcloff:     .byte 0x13                  ; reader off
mcl:        .byte 0xa,0xd,0x14,0,0,0,0,"*",4  ; lf,cr,punch
mcl1:       .byte 0xd,0xa,0,0,0,0,4     ; cr lf
mcl2:       .byte "MIKBUG 2.0"
            .byte 4
mcl3:       .byte "CC B A X P S"
            .byte 4
mcl4:       .byte "BEG ADDR ?"
            .byte 4
mcl5:       .byte "END ADDR ?"
            .byte 4
; 
; 
; maximal software implementation of the 
; ritter-zettner standards 
; 
; copyright (c) 1977 motorola inc. and t. f. ritter 
; 
; commands for exortape 
; c l d s : 
; c - check tape 
; l - load from tape to memory 
; d - dump from memory to tape 
; s - set baud rate 
; 
; speed : 
; enter 04 08 12 16 20 
; 
; file id : 
; enter four hex characters 
; 
; startstop pages: 
; enter starting page, two hex characters 
; enter stoppage, two hex characters 
; 
; 
; 
; file specifications 
; alc := undefined bit; automatic level control 
; post := undefined bit; missing pulse protect 
; start sequence := 89afh 
; crc := cyclic redundency check bit; x16+x15+x2+x0 
; headerecord := (32 alc) (start sequence) (08h) 
; (16 file id) (8 # of good pages) (8 post) 
; trailerecord := (16 alc) (start sequence) 
; (20h) (8 # of bad pages) (8 post) 
; dumpagerecord := (16 alc) (start sequence) (10h) 
; (8 page #) (2048 data) (16 crc) (8 post) 
; charecord := (32 alc) (start sequence) (40h) 
; (8 length) (1-256 chars) (16 crc) (8 post) 
; otherecord := neither header nor trailer record 
; subfile := (headerecord) (0-n otherecords) 
; file := (1-n subfiles) (trailerecord) 
; 
; 
; data specifications 
; synchronous data; no start or stop bits 
; msb sent first (correct order on scope) 
; voice messages may be present between files 
; 
; 
; audio modulation specifications 
; double-frequency return-to-bias modulation 
; logic one = five element pattern: 0 1 0 1 0 
; logic zero = five element pattern 0 1 0 0 0 
; local el cheapo (realistic ctr-34) does 1200 baud 
; (data rate equals 1650 baud 2-stop async) 
; 0 erros in 2.6 million bits recovered 
; from memorex mrx2 
; 
; 
; audio hardware specifications 
; output from pia b2 through 11:1 voltage divider 
; (4.7k, 470) into mike jack 
; input from spkr jack, through dc-restoring 
; circuit and schmidtt trigger 
; (mc14583 preferred) into pia b0 
; recovered pulse phase matters, so use switch to 
; select phase -- both available from mc14583 
; 
;baud rates: 400 800 1200 1600 2000 
;equiv async: 550 1100 1650 2200 2750 
;element (usec): 500 250 167 125 100 
;totcnt: 35 1b 12 0d 0b 
;patdel: 50 26 18 11 0d 
; 
;system storage 
            .equ ttycon, 0x8008         ; acia control
            .equ tty, 0x8009            ; tty acia
            .equ tp, 0x8004             ; tape port
            .equ tacon, 0x8005          ; tape control
            .equ esc, 0x1b              ; escape char
; 
; 
; 
; 
; 
            .equ eot, 4
; 
; 
; messages 
; 
; 
msg1:       .byte "EXORTAPE 4.3"
            .byte eot
msg2:       .byte "C L D S: "
            .byte eot
msg3:       .byte "FILE ID: "
            .byte eot
msg4:       .byte "STARTSTOP PAGES: "
            .byte eot
msg5:       .byte "SPEED: "
            .byte eot
; 
; print line with a preceeding cr/lf 
; x point to string, string must 
; terminate with a $4 character. 
; 
pdata:      jsr pcrlf
pdat1p:     jmp pdata1
; 
; tins provides tape "IN'S" for mikbug keyboard 
; control of tape system 
; 
; 
; enter here 
; 
; 
exort:      bsr exor                    ; call tape routine via a bsr
            jmp ent1                    ; return to exec
; 
; 
; 
; 
; 
; tin's error routine 
; 
err:        ldaa #'?'                   ;  print '?'
            jsr outch
; fall into tins 
; 
; 
; 
exor:
tins:       ldx #0x1b26                 ; standard speed
            stx totcnt
soft:
tinss:      ldx #msg1                   ; send pgm title
ti1:        bsr pdata
ti2a:       ldx #msg5                   ; send speed question
            bsr pdata
            jsr byte                    ; input 2 hex characters
            cmpa #0x20                  ; 2000 baud?
            bne tin1
            ldx #0x0b0d
            bra tin5
tin1:       cmpa #0x16                  ; 1600 baud?
            bne tin2
            ldx #0x0d11
            bra tin5
tin2:       cmpa #0x12                  ; 1200 baud?
            bne tin3
            ldx #0x1218
            bra tin5
tin3:       cmpa #0x04                  ; 0400 baud?
            bne tin4
            ldx #0x3550
            bra tin5
tin4:       cmpa #0x08
            bne err                     ; not a valid speed
            ldx #0x1b26                 ; 800 baud is normal






tin5:       stx totcnt
tin8:       ldx #msg2                   ; send mode question
ti2:        bsr pdata                   ; c=check" l=load
            jsr inch                    ; d=dump" s= speed
            cmpa #'S'
            beq ti2a
; 
; 
tin6:       staa t1                     ; store mode char
            ldx #msg3                   ; send file id prompt
ti4:        bsr pdata
            jsr baddr                   ; get file id
            stx fidh
            jsr pcrlf
            ldaa t1
            cmpa #'D'                   ;  dump mode?
            bne tin7
            ldx #msg4                   ; send start"stop prompt
            bsr pdat1p
            jsr baddr
            stx startp
            jsr pcrlf
            jmp master
tin7:       cmpa #'C'                   ;  check mode?
            beq check
            cmpa #'L'                   ;  check for load
            beq load2
            jmp err
; 
; fall into load 
loadv:      bra load2
check:      ldaa #0x01                  ; insert check command
            bra c12
load2:      ldaa #0xe7                  ; insert load command
c12:        staa cl                     ; (store b indexed)
            clr cll                     ; nop"zero displacement
            ldaa #0x39                  ; insert rts
            staa clll
; fall into getload 
; 
; getload searches for the desired file, 
; then loads it into ram 
; 
; ram: q, r, s, h, l (scratch) 
; totcnt, fidh, fidl (perm) 
; 
getloa:     jsr lsetup                  ; set up pia
            bsr getfil                  ; search for correct file
            beq get4                    ; out iff escaped
get2:       bsr startv                  ; get the next record-type
            beq get4                    ; out if escape
            cmpb #0x20                  ; trailerecord?
            beq get1
            cmpb #0x10                  ; dumpagerecord?
            bne get2
            bsr dumpr                   ; bring it in!
            beq get4                    ; out iff escape
            bra get2
get1:       tst v                       ; check page count
            beq get4
            bmi get3
            ldaa #'-'                   ;  '-'  for missing page(s)
            bra get5
get3:       ldaa #'+'                   ;  '+'  for extra page(s)
get5:       jsr outch                   ; print it!
get4:       rts                         ; return
; 
; dumpr brings in a dumpage record 
; 
; ram: h, l (scratch) 
; regs: acca, accb (scratch); ix (perm) 
; exit: falls into crck 
; 
dumpr:      bsr ldv                     ; get page number
            stab h                      ; )
            clr l                       ; ) load ix!
            ldx h                       ; )
dum1:       bsr ldv
            beq g2                      ; out iff escape
            jsr cl                      ; check, or load
            inx                         ; storage ptr
            inc l                       ; byte count
            bne dum1
            dec v                       ; page count
; fall into crck 
; 
; crck shecks the crc and print a char 
; 
; ram: q, r, s, totcnt (from loadbyte) 
; regs: acca (scratch, accb (from loadbyte) 
; 
crck:       bsr ldv                     ; ) input crc chars
            bsr ldv                     ; )
            ldaa r                      ; check crc registers
            oraa s
            bne crck1
            ldaa #'G'                   ;  print g for good crc
            bra crck2
crck1:      ldaa #'B'                   ;  print b for bad crc
crck2:      jmp ttyo1                   ; print it!
ldv:        jmp loadbv                  ; get a tape byte in accb
startv:     bra startf
; 
; getfile looks for: 
; 1) a start sequence 
; 2) a headerecord type 
; 3) a file id match with fidh, fidl 
; and returns when found, or escaped 
; 
; regs: acca, accb (scratch only) 
; 
g1:         ldaa #'X'                   ;  indicate wrong file found
            bsr crck2                   ; send char to tty
getfil:     bsr startf
            beq g2                      ; out iff escape
            cmpb #0x08                  ; headerecord-type?
            bne getfil                  ; branch if not
            bsr ldv                     ; get byte in accb
            cmpb fidh                   ; good file id(h)?
            bne g1
            bsr ldv
            cmpb fidl                   ; good file id(l)?
            bne g1
            ldaa #'H'                   ;  indicate header found
            bsr crck2
            bsr ldv
            stab v                      ; store page count
g2:         rts
; 
; startfind looks for the 16-bit start sequence 89af 
; returns with the next byte, the record type, 
; in q and accb. 
; 
; ram: q, r, s, totcnt (perm), h (scratch) 
; regs: acca, accb (scratch only) 
; exit: falls into loadbyte, which 
; falls into loadbit, which 
; falls into crc 
; escape: esc in command port gets out 
; (test done in crc) 
; 
startf:     clr h                       ; accumulates 16 bits
            clr q
sta1:       asl q                       ; shift the 16-bit register
            rol h
            bsr loadb1
            beq g2                      ; out iff escaped
            ldaa h
            ldab q
            cmpa #0x89                  ; start sequence
            bne sta1
            cmpb #0xaf
            bne sta1
sta2:       clr r                       ; clear the crc register
            clr s
; fall into loadbyte to return a byte 
; 
; loadbyte recovers of data in q and accb, and does crc 
; 
; ram: q, r, s, totcnt (perm) 
; regs: acca, accb (scratch only) 
; exit: falls into loadbit, which 
; falls into crc 
; 
loadby:     ldab #0x02                  ; set stop
            stab q
load1:      bsr loadb1
            beq g2                      ; out iff escape
            asl q                       ; stop into carry?
            bcc load1                   ; branch if no
; fall into loadbit for last bit 
; 
; loadbit recovers one bit of data in q and accb, 
; and does crc in r and s 
; 
; ram: q, r, s, totcnt (perm) 
; regs: acca, accb (scratch only) 
; exit: branches or falls into crc routine 
; data bit goes into q lsb 
; 
loadb1:     clrb
loadb6:     decb
            beq loadb5
            bsr tain1v                  ; get tape data in carry
            bcs loadb6                  ; wait for low
loadb2:     decb
            beq loadb5
            bsr tain1v                  ; wait for high
            bcc loadb2                  ; ) (front of sync el)
            ldab totcnt                 ; 3.5 els delay
loadb3:     decb
            beq loadb5
            bsr tain1v                  ; ) wait for low
            bcs loadb3                  ; ) (end of sync el)
loadb4:     decb
            beq loadb5                  ; done yet?
            bsr tain1v
            bcc loadb4
            inc q                       ; store a '1'  bit
loadb5:     ldaa q                      ; get data for crc
; fall into crc1 
; 
; crc enters a bit into crc registers r and s 
; uses crc polynomial: x16 + x15 + x2 + x0 
; 
; entry: acca holds new bit 
; ram: r, s (perm) 
; regs: acca, accb (scratch) 
; exit: accb = q, z = 1 iff esc 
; 
crc1:       rora                        ; lsb into carry
            rora                        ; carry into msb
crc2:       anda #0x80                  ; mask msb (data bit)
            eora r                      ; enter data bit
            ldab s
            aslb                        ; shift 16 bits left
            rola
            bcc crc3                    ; if b16 high. . .
            eora #0x80                  ; enter crc polynomial
            eorb #0x05
crc3:       staa r
            stab s
            ldab q
            jsr ttyin1                  ; check for escape
            anda #0x7f                  ; mask parity
            cmpa #esc
            rts
tain1v:     jmp tain1
; 
; byteout sends byte in acca to tape 
; 
; ram: r, s (changed in crc) 
; regs: acca, accb (destroyed) 
; exit: acca = 0, accb undefined 
; 
; acca = data byte (shifted) 
; accb = recording pattern (one bit) 
; 
byteou:     psha                        ; save the data byte
            bsr crc2                    ; ) do the crc first
            pula                        ; recover the data byte
            sec                         ; set stop
            rola                        ; data bit into carry
            bra by2
by1:        pula                        ; recover from done test
            psha                        ; save shifting byte
            bsr crc2
            pula                        ; recover shifting byte
            asla                        ; data bit into carry
by2:        ldab #0x0a                  ; recording pattern
by3:        jsr taou1                   ; send accb to tape
            pshb                        ; save pattern
            ldab patdel                 ; element delay
by4:        decb
            bne by4                     ; branch if element not done
            pulb                        ; recover pattern
            rolb                        ; next element (data from carry)
            bcc by3                     ; branch if pattern not done
            psha                        ; save data byte before test
            asla                        ; test acca
            bne by1                     ; branch if byte not done
by5:        ins                         ; restore stack
            rts
; 
; preamble sends out alc bits, and the start sequence, 
; then inits the crc registers 
; 
; ram: r, s (changed) 
; regs: acca, accb (destroyed) 
; exit: acca = 0, accb undefined 
; 
preamb:     bsr bytov1                  ; alc bits
            bsr bytov1
            ldaa #0x89                  ; start sequence (h)
            bsr bytov1
            ldaa #0xaf                  ; start sequence (l)
            bsr bytov1
            clr r                       ; ) clear the crc registers
            clr s                       ; )
            rts
; 
; headerecord sends alc bits, the start sequence, 
; headrecord-type, file id, and the number of 
; pages to be dumped 
; 
; ram: fidh, fidl (unmodified) 
; r, s (changed) 
; regs: acca, accb (destroyed) 
; exit: acca = 0, accb undefined 
; 
header:     bsr bytov1                  ; alc bits
            bsr bytov1
            bsr preamb                  ; start a record
            ldaa #0x08                  ; headertype
            bsr bytov1
            ldaa fidh                   ; file id(h)
            bsr bytov1
            ldaa fidl                   ; file id(l)
            bsr bytov1
            ldaa stoppg                 ; stopage
            suba startp                 ; startpage
            inca
            bsr bytov1                  ; send # pages
bytov1:     jmp byteov                  ; extra bits
; 
; trailerecord sends a trailerecord to tape 
; 
; ram: r, s (perm) 
; regs: acca, abbc (destroyed) 
; 
trailr:     bsr preamb                  ; start a record
            ldaa #0x20                  ; trailerecord type
            bsr bytov1
            bra bytov1                  ; extra bits
; 
; dumpagerecord sends the start sequence, dumpage-type, 
; page number, 2048 bits data, and the crc characters 
; 
; ram: h, r, s (perm); l (scratch) 
; regs: acca, accb (destroyed), new ix 
; exit: acca = 0 
; 
dumpag:     bsr preamb                  ; start a record
            ldaa #0x10                  ; dumpage type
            bsr bytov1
            ldaa h                      ; send page number
            bsr bytov1
            clr l                       ; do entire page
            ldx h                       ; point at the data
dump1:      ldaa 0,x
            bsr bytov1                  ; send data
            inx
            inc l                       ; byte ctr
            bne dump1
            bsr sencrc
            ldaa #'D'                   ;  print d for each page dumped
            bsr ttyo1
            clra
            bra bytov1                  ; extra bits
; 
; sencrc sends the crc registers to tape 
; 
; 
; ram: r, s (freed after this); l (scratch) 
; regs: acca, accb (destroyed) 
; 
sencrc:     ldaa s
            staa l                      ; temporary crc(l) storage
            ldaa r
            bsr bytov1                  ; send crc(h)
            ldaa l
            bra bytov1                  ; send crc(l)
; 
; masterdump sends a complete file to tape: 
; headerecore, dumpagerecords (1-256), trailerecord 
; 
; ram: startp, stoppg (unmodified) 
; h, l (temp) 
; regs: new everything 
; 
master:     bsr dsetup                  ; setup dump port
            bsr header                  ; send headerecord
            ldaa startp                 ; get startpage
            staa h                      ; present page
            dec h
mast1:      inc h
            bsr dumpag
            ldaa tty
            anda #0x7f
            cmpa #esc
            beq mast3
            ldab stoppg                 ; get stopage
            cmpb h                      ; present page
            bne mast1                   ; branch if not done
mast3:      bsr trailr                  ; send trailerecord
mast2:      rts
setup:      clr tacon                   ; into data direction reg.
            ldaa #0x04                  ; b2 an output, rest inputs
            staa tp                     ; (only b0 used for input)
            staa tacon                  ; back to data register
            rts
; 
; vectors- in other versions of this tape 
; interface these vectors will be implemented 
; in ram to allow the user access to 
; the tape system. 
; 
tain1:      jmp tain2                   ; tape in port vector
taou1:      jmp taou2                   ; tape out port vector
loadbv:     jmp loadby                  ; tape byte in vector
byteov:     jmp byteou                  ; tape byte out vector
ttyin1:     jmp ttyin2                  ; control in port vector
ttyo1:      jmp ttyo2                   ; control out port vector
lsetup:     jmp setup                   ; tape out pia init
dsetup:     jmp setup                   ; tape in pai init
; 
; 
tain2:      ldaa tp                     ; acca from tape
            rora                        ; data bit in carry
            rts
ttyin2:     ldaa tty                    ; acca from acia
            rts
ttyo2:      staa tty                    ; send acca to acia
            rts
taou2:      stab tp                     ; accb to tape
            rts
; 
; copyright (c) 1977 motorola inc - austin texas 
; 
; 
; 
; 
; unsigned multiply ----- 
; 
; this routine multiplies the unsigned number in the 
; a register with the unsigned number in the b 
; register and puts the answers in the concatenated 
; a:b where a is the msb. the routine is 
; re-entrant and position independent as well 
; as being romable. the x register is destroyed 
; by the routine. 
; 
; during execution the stack contains: 
; 0,x = loop counter 
; 1,x = multiplier (b reg on entry) 
; 
; the algorithm used may not appear the fastest 
; on paper because it always requires 8 passes 
; the the loop but because of the fact all 
; calculations can be done in the registers it 
; is faster except for when the multiplicand 
; is very small (<10). the method is a shift and 
; add technique that begings with the ms bit 
; and works down to the ls bit. 
; 
; execution time: (29 + zeroes19 + ones26) cycles 
; where zeroes and ones are the 0'S AND 1's in 
; the a-reg on call. 
; 
; average execution time: 209 cycles 
; 
; 
; 
mul_:       pshb
            ldab #8                     ; put counter on stack
            pshb
            tsx                         ; set x to point to stack
            clrb                        ; clear place to start answer
ml1:        aslb                        ; shift ans 1 left and into a
            rola                        ; shift whats left of the multiplier
            bcc ml2                     ; branch if no add needed
            addb 1,x                    ; add multiplier at this position
            adca #0                     ; add carry to a if any
ml2:        dec 0,x                     ; done?
            bne ml1                     ; nope
            ins                         ; yes,clean up the stack
            ins
            rts
; 
; 
; 
; signed multiply ----- 
; 
; this routine multiplies the two signed numbers in 
; the a and b registers and puts the signed 
; 16 bit answer in the concatenated a:b where 
; the a register is the msb. this routine destroys 
; the caller's x-register. 
; 
; during execution the stack contains: 
; 0,x = flag 
; 
; the routine is pure,re-entrant and position independent. 
; 
; the method use evaluates each argument and if it 
; is negative it is 2's complemented and the flag is 
; incremented. if after evaluating both arguments the 
; flag is even (0 or 2) then the answer will be positive, 
; else,the answer will need to be 2's complemented. 
; unsigned multiple routine is used to multiply the 
; corrected registers 
; 
; average executions times: 
; a-reg b-reg 
; + + 268 average 
; + - 283 average 
; - + 283 average 
; - - 286 average 
; 
; 
; 
; 
smul:       des                         ; carve out a place on the stack f...
            tsx                         ; get pointer to that place
            clr 0,x                     ; clear flag
            tsta                        ; check multiplier
            bpl sml1                    ; positive, no comp. needed
            nega                        ; 2's comp. argument
            inc 0,x                     ; incr flag
sml1:       tstb                        ; test other arg
            bpl sml2                    ; no comp needed
            negb
            inc 0,x                     ; incr flag
sml2:       bsr mul_                    ; go do unsigned multiply
            tsx                         ; get back ptr to flag
            ror 0,x                     ; see if flag is even or odd
            bcc sml3                    ; even answer is okay 'cause its f...
            nega                        ; dbl precision 2's comp
            negb
            sbca #0
sml3:       ins                         ; cleanup stack
            rts                         ; return to caller
; 
; 
; 
; postive divide ----- 
; 
; this routine divides the 16 bit positive dividend 
; in the a:b registers (a is the msb) by an 8 
; bit positive divisor pointed to by the x-register. 
; the quotient is in b on exit and the remainder 
; is in the a-register. the x-register is 
; destroyed. 
; if division by zero was attempted or the 
; quotient will not fit in 8 bits the overflow 
; bit is set on exit. also v is set if either 
; the dividend or the divisor is negative on call. 
; otherwise v is cleared. 
; 
; 
; the routing is pure,re-entrant and position independent. 
; 
; during execution the stack contains 
; 0,x = loop counter 
; 1,x = divisor 
; 2,x = dividend msb (only used for temp store) 
; 
; the method used is non restoring divide where the 
; dividend and divisor and known to be positive. this 
; method proved fastest since it can be carried out 
; essentially in the accumulators. the algorithm tries 
; to get the remainder as near zero as possible 
; and sometimes adds the divisor and sometimes 
; subtracts it depending on which side of zero the 
; partial remainder resides at any time. for more 
; info read: 'AN ALGORITHM FOR NON RESTORING DIVISION' 
; s. sanyal ; 'COMPUTER DESIGN' / may 1997. 
; 
; execution time average (no overflows): 289 cycles 
; this time is relatively independent of the 
; calling values. 
; 
; 
; 
; 
div:        psha                        ; save dividend msb a second
            ldaa 0,x                    ; fetch the divisor
            bmi divov2                  ; negative divisor is a no-no
            psha                        ; push it
            ldaa #8                     ; push loop ctr
            psha
            tsx                         ; point x to stack
            ldaa 2,x                    ; restore original dividend msb
            cmpa 1,x                    ; will quotient overflow? (als d!
            bcc divovf                  ; yes,go set v and exit
dloop:      aslb                        ; shift dividend-answer left
            rola
            bcc dl2                     ; is dividend ms bit set?
            adda 1,x                    ; yes,add divisor to msb
            bra dl3
dl2:        suba 1,x                    ; no,sub divisor from msb
            incb                        ; set bit in result
dl3:        dec 0,x                     ; done?
            bne dloop                   ; no
            sec                         ; shift a 1 in ls bit of quotient
            rolb                        ; case thats okay, correct latter
            tsta                        ; is remainder negative?
            bpl dl4                     ; no,everything's okay
            decb                        ; reset quotient ls bit
            adda 1,x                    ; add divisor to get + remainder
            clv                         ; insure v is cleared
dl4:        ins                         ; clean up the stack
            ins
            ins
            rts                         ; return
; 
divovf:     ins                         ; clean up stack
            ins
divov2:     ins
            sev                         ; set the overflow flag
            rts

; mits used B rather than A
outchmits:  tba
outcmits:   ldab acias
            asrb
            asrb
            bcc outcmits                   ; xmit not ready
            tab
            stab aciad                  ; output char
            rts

; apparently MITS 680b mikbug returned the character in B for some reason
; trying out switching this to not affect A.
inchmits:   ldab acias
            asrb
            bcc inchmits                ; receiver not ready
            ldab aciad                  ; input char
            andb #0x7f                  ; reset parity bit
            cmpb #0x7f
            beq inchmits                ; rubout"del
            rts                         ; else,return to caller

; 
; interrupt vectors 
; 
            .org 0xFFF8

            .word io
            .word sfei
            .word powdwn
            .word start
