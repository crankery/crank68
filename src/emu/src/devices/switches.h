#pragma once

#include "memoryIODevice.h"

// dip switches
class Switches : public MemoryIODevice
{
public:
    Switches(const uint8_t slot, const uint8_t offset)
        : MemoryIODevice(slot, offset, 1)
    {
        value_ = 0;
        snprintf(name_, sizeof(name_), "switch(%x:%0x)", slot, offset);
    }

    virtual uint8_t in(uint8_t port) override;

    virtual void out(uint8_t addr, uint8_t value) override;

    virtual char *name() override
    {
        return name_;
    }

    void setValue(uint8_t value)
    {
        value_ = value;
    }

private:
    uint8_t value_;
    char name_[25];
};