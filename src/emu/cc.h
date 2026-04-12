#pragma once

enum CC : uint8_t
{
    C = 0x01, // Carry
    V = 0x02, // Overflow
    Z = 0x04, // Zero
    N = 0x08, // Negative
    I = 0x10, // IRQ mask
    H = 0x20  // Half-carry
};