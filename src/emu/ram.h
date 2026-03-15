#pragma once

#include <array>
#include <cstdint>

#include "mem.h"

class Ram : Mem
{
public:
    static const uint16_t StartAddress = 0x0000;
    static const uint16_t EndAddress = 0xBFFF;

    Ram() : Mem()
    {
        memory_.fill(0xa5);
    }

    bool read(uint16_t addr, uint8_t &value) const;
    bool write(uint16_t addr, uint8_t value);

protected:
    virtual uint16_t size() const override
    {
        return EndAddress - StartAddress + 1;
    }

private:
    std::array<uint8_t, Ram::EndAddress - Ram::StartAddress + 1> memory_;
}