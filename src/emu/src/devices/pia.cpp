#include "pia.h"
#include "machine/machine.h"

uint8_t Pia::in(uint8_t port)
{
    char buf[256];

    switch (port & 0xf)
    {
    case 0:
    case 1:
    case 2:
    case 3:
    default:
        snprintf(buf, sizeof(buf), "%s in 0x00", name());
        Logging::log(buf);
    }

    return 0x0;
}

void Pia::out(uint8_t port, uint8_t value)
{
    char buf[256];

    switch (port & 0xf)
    {
    case 0:
    case 1:
    case 2:
    case 3:
    default:
        snprintf(buf, sizeof(buf), "%s out %02x", name(), value);
        Logging::log(buf);
    }
}