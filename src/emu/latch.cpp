#include <stdio.h>
#include "latch.h"

void Latch::out(uint8_t addr, uint8_t value)
{
    value_ = value;

    // printf("latch %1x aet %02x\n", offset_, value_);
}
