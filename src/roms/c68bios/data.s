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
    .byte 0x03
    .string "C68 BIOS v0.01"
    .string "Dave Hamilton 2026"
    .include "build_tag.inc"

s_crlf:
    .string "\r\n"

s_monitor_unknown:
    .string "Unknown command, enter H for help"

st_monitor_help:
    .byte   0x04
    .string "H (?)               - Display help"
    .string "F                   - Boot FLEX from SRAM"
    .string "address             - Examine one byte"
    .string "start.end           - Examine inclusive range"
