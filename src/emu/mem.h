#pragma once

#include <cstdint>

class Mem
{
public:
    virtual ~Mem() = default;

    virtual uint8_t read(uint16_t addr) const = 0;
    virtual void write(uint16_t addr, uint8_t value) = 0;

protected:
    virtual uint16_t size() const = 0;
};