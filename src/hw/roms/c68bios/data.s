; ------------------------------------------------------------       
; strings
; ------------------------------------------------------------       

    .include "defs.s"

    .section ".strings","adr"

    .global st_banner_msg
    .global s_crlf
    .global s_monitor_unknown
    .global s_no_resume
    .global s_interrupt
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

s_no_resume:
    .string "No interrupted program"

s_interrupt:
    .string "(Interrupt)\r\n"

s_build_tag:
    .include "build_tag.inc"

st_monitor_help:
    .byte   0x09
    .string "H (?)"
    .byte 15
    .string "- Display help"
    .string "F"
    .byte 19
    .string "- Boot FLEX from SRAM"
    .string "R"
    .byte 19
    .string "- Resume after NMI"
    .string "address"
    .byte 13
    .string "- Examine one byte"
    .string "start.end"
    .byte 11
    .string "- Examine inclusive range"
    .string "address: bytes"
    .byte 6
    .string "- Write hex bytes to memory"
    .string ": bytes"
    .byte 13
    .string "- Continue at next address"
    .string "addressG"
    .byte 12
    .string "- Run code (RTS returns here)"
    .string "addressU"
    .byte 12
    .string "- Enter binary upload mode"
