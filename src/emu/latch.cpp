#include <stdio.h>
#include "latch.h"

uint8_t Latch::in(uint8_t port)
{
    return 0xff;
}

void Latch::out(uint8_t addr, uint8_t value)
{
    value_ = value;
}
