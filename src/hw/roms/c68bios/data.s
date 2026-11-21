; ------------------------------------------------------------       
; strings
; ------------------------------------------------------------       

    .include "defs.s"

    .section ".strings","adr"

    .global st_banner_msg
    .global s_crlf
    .global s_monitor_unknown
    .global st_monitor_help
    .global s_starting_os
    .global s_build_tag

st_banner_msg:
    .byte 0x02
    .string "C68 BIOS v0.01"
    .string "Dave Hamilton 2026"

s_starting_os:
    .string "Starting OS"

s_crlf:
    .string "\r\n"

s_monitor_unknown:
    .string "Unknown command, enter H for help"

s_build_tag:
    .include "build_tag.inc"

st_monitor_help:
    .byte   0x07
    .string "H (?)               - Display help"
    .string "F                   - Boot FLEX from SRAM"
    .string "address             - Examine one byte"
    .string "start.end           - Examine inclusive range"
    .string "address: bytes      - Write hex bytes to memory"
    .string ": bytes             - Continue at next address"
    .string "addressG            - Run code (RTS returns here)"
