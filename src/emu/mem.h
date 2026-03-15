#pragma once

#include <cstdint>

class Mem
{
public:
    virtual ~Mem() = default;

    virtual bool read(uint16_t addr, uint8_t &value) const = 0;
    virtual void write(uint16_t addr, uint8_t value) = 0;
}