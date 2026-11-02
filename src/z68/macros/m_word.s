.macro ld16 addr
    ldaa \addr
    ldab \addr+1
.endm

.macro st16 addr
    staa \addr
    stab \addr+1
.endm

.macro inc16 addr
    inc \addr+1
    bne 1f
    inc \addr
1:
.endm