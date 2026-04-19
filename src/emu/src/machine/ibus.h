#pragma once

class IBus
{
public:
    virtual ~IBus() = default;
    virtual uint8_t read8(uint16_t addr) = 0;
    virtual void write8(uint16_t addr, uint8_t value) = 0;
};