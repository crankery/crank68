#pragma once

#include <cstdint>

class Mem
{
public:
    Mem(uint16_t startAddress, uint16_t endAddress)
    {
        startAddress_ = startAddress;
        endAddress_ = endAddress;
    }

    virtual ~Mem() = default;

    virtual uint8_t read(uint16_t addr) const = 0;
    virtual void write(uint16_t addr, uint8_t value) = 0;

protected:
    uint16_t size()
    {
        return endAddress_ - startAddress_ + 1;
    }

    uint16_t startAddress_;
    uint16_t endAddress_;
};