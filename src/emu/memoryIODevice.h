#pragma once

#include "mem.h"

class MemoryIODevice
{
public:
    MemoryIODevice(const uint8_t slot, const uint8_t offset, const uint8_t count)
        : slot_(slot), offset_(offset), count_(count)
    {
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

    virtual uint8_t in(uint8_t addr) const
    {
        return 0xff;
    }

    virtual void out(uint8_t addr, uint8_t value)
    {
        // do nothing
    }

    // -1 if no match with this device
    // port number on device (0-15) on match
    virtual int8_t getPort(uint8_t addr)
    {
        uint8_t slot = (addr & 0xF0) >> 4;
        uint8_t offset = addr & 0xf;

        if (slot == slot_ && offset >= offset_ && offset <= offset_ + count_)
        {
            // the port number on the device is the device's offset minus the address's offset
            return offset_ - offset;
        }

        return -1;
    }

protected:
    const uint8_t slot_;
    const uint8_t offset_;
    const uint8_t count_;
};