; ------------------------------------------------------------
; memory mapped io
; ------------------------------------------------------------       

    .include "defs.s"

; memory map:
;   $0000-$bfff   ram
;   $c000-$cfff   SRAM window selected by $e002
;   $d000-$dfff   SRAM window selected by $e003
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
    .global config_switches
    .global sram_page_low
    .global sram_page_high
    
    ; IO board strapped to slot 1 (its address comparator is configurable)
    .global acia0_reg   ; ACIA 1, main console
    .global acia0_data
    .global acia1_reg   ; ACIA 2
    .global acia1_data
    .global pia0        ; PIA 1
    .global pia1        ; PIA 2

    ; optional and emulated devices at their current default addresses
    .global sound_data
    .global rtc_address
    .global rtc_data
    .global sd_reg
    .global sd_data
    .global keyboard_status
    .global keyboard_data

slot0:
    ; registers and switches
    .space 1                 ; $E000: no bank register
config_switches:
    .space 1
sram_page_low:
    .space 1                 ; $E002: $C000-$CFFF page latch
sram_page_high:
    .space 1                 ; $E003: $D000-$DFFF page latch

    .space 12

slot1:
    ; IO board U2B decodes A3:A2: ACIA 1, ACIA 2, PIA 1, PIA 2.
    ; These addresses assume the board's slot comparator selects $E01x.
acia0_reg:
    .space 1                 ; $E010
acia0_data:
    .space 1                 ; $E011
    .space 2
acia1_reg:
    .space 1                 ; $E014
acia1_data:
    .space 1                 ; $E015
    .space 2
pia0:
    .space 4                 ; $E018-$E01B
pia1:
    .space 4                 ; $E01C-$E01F

slot2:
    .space 0x10

slot3:
    .space 0x10

slot4:
    .space 0x10

slot5:
    .space 0x10

slot6:
sound_data:
    .space 1                 ; $E060: optional SN76489 sound board
    .space 15

slot7:
rtc_address:
    .space 1                 ; $E070: emulated RP5C01A address latch
rtc_data:
    .space 1                 ; $E071: emulated RP5C01A nibble data
    .space 14

slot8:
    ; Instore SD and keyboard card, when strapped to slot 8
sd_reg:
    .space 1                 ; $E080: read status / write command
sd_data:
    .space 1                 ; $E081: response / parameter data
keyboard_status:
    .space 1                 ; $E082: keyboard status
keyboard_data:
    .space 1                 ; $E083: keyboard data
    .space 12

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
