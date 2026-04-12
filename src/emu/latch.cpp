#include <stdio.h>
#include "latch.h"
#include "machine.h"

uint8_t Latch::in(uint8_t port)
{
    return 0xff;
}

void Latch::out(uint8_t addr, uint8_t value)
{
    char buf[80];
    snprintf(buf, sizeof(buf), "%s out: %02x\n", name(), value_);
    Machine::instance().log(buf);

    value_ = value;
}
