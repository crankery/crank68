; ------------------------------------------------------------       
; strings
; ------------------------------------------------------------       

    .include "defs.s"

    .section ".strings","adr"

    .global st_banner_msg
    .global s_crlf
    .global s_monitor_unknown
    .global st_monitor_help

st_banner_msg:
    .byte 0x02
    .string "C68 BIOS"
    .string "Dave Hamilton 2026"

s_crlf:
    .string "\r\n"

s_monitor_unknown:
    .string "Unknown command, enter H for help"

st_monitor_help:
    .byte   0x04
    .string "H (?)               - Display help"
    .string "S [address]         - Show memory contents"
    .string "G [address]         - Run the program at address"
    .string "D [address] [value] - Deposit value at address"