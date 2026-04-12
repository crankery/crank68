#include <stdio.h>
#include "switches.h"
#include "machine.h"

uint8_t Switches::in(uint8_t port)
{
    char buf[80];
    snprintf(buf, sizeof(buf), "%s in: %02x\n", name(), value_);
    Machine::instance().log(buf);

    return value_;
}

void Switches::out(uint8_t addr, uint8_t value)
{
}
