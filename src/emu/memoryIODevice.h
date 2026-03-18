#pragma once

#include "mem.h"

class MemoryIODevice
{
public:
    MemoryIODevice(uint8_t slot, uint8_t offset, uint8_t count)
    {
        slot_ = slot;
        offset_ = offset;
        count_ = count;
    }

    ~MemoryIODevice() = default;

    uint8_t getSlot()
    {
        return slot_;
    };

    uint8_t getOffset()
    {
        return offset_;
    };

    uint8_t getCount()
    {
        return count_;
    };

    uint8_t getPort(uint8_t a)
    {
        // this is the lower 8 bits of the address
        // we live at slot_ * 0x10 + offset_
        // we can disregard the slot_ honestly so the io is happening at a & 0xf
        // subtract the offset_ from a & 0xf and we have the device's port number

        return a & 0xf - offset_;
    }

    virtual uint8_t in(uint8_t addr) const = 0;
    virtual void out(uint8_t addr, uint8_t value) = 0;

protected:
private:
    uint8_t slot_;
    uint8_t offset_;
    uint8_t count_;
};