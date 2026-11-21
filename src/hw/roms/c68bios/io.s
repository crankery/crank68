; ------------------------------------------------------------
; memory mapped io
; ------------------------------------------------------------       

    .include "defs.s"

; memory map:
;   $0000-$bfff   ram
;   $c000-$dfff   banked memory    
;   $e000-$e0ff   i/o
;   $e100-$ffff   rom
 
    .section .io, "aw", @nobits

    .global slot0
    .global slot1
    .global slot2
    .global slot3
    .global slot4
    .global slot5
    .global slot6
    .global slot7
    .global slot8
    .global slot9
    .global slotA
    .global slotB
    .global slotC
    .global slotD
    .global slotE
    .global slotF

    ; slot 0
    .global bank_reg
    .global config_switches
    
    ; slot 1
    .global acia0_reg   ; main console
    .global acia0_data
    .global acia1_reg   ; optional second serial port
    .global acia1_data
    .global acia2_reg   ; optional third serial port
    .global acia2_data
    .global acia3_reg   ; optional fourth serial port
    .global acia3_data

slot0:
    ; registers and switches
bank_reg:
    .space 1
config_switches:
    .space 1

    .space 14

slot1:
    ; ACIAs
acia0_reg:
    .space 1
acia0_data:
    .space 1
acia1_reg:
    .space 1
acia1_data:
    .space 1
acia2_reg:
    .space 1
acia2_data:
    .space 1
acia3_reg:
    .space 1
acia3_data:
    .space 1

    .space 8

slot2:
    ; PIAs
    .space 0x10

slot3:
    .space 0x10

slot4:
    .space 0x10

slot5:
    .space 0x10

slot6:
    .space 0x10

slot7:
    .space 0x10

slot8:
    .space 0x10

slot9:
    .space 0x10

slotA:
    .space 0x10

slotB:
    .space 0x10

slotC:
    .space 0x10

slotD:
    .space 0x10

slotE:
    .space 0x10

slotF:
    .space 0x10
