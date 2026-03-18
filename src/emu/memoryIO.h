#pragma once

#include <cstdint>

#include "mem.h"
#include "memoryIODevice.h"

static const uint16_t StartAddress = 0xE000;
static const uint16_t EndAddress = 0xE0FF;

class MemoryIO : Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress)
    {
        devices_.fill(NULL);
    }

    bool AddDevice(MemoryIODevice *device)
    {
        // slot needs to be between 0 and 15.
        // TODO: assert
        uint8_t baseAddress = device->getSlot() * 0x10;

        // offset should be 0..255
        // register count should fit inside of the page
        // todo: assert that and that there's nothing already servicing that range
        for (uint8_t i = device->getOffset(); i < device->getCount(); i++)
        {
            devices_[baseAddress + i] = device;
        }
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        // see if there's any device at this address
        uint8_t io = addr & 0xff;
        MemoryIODevice *device = devices_[io];
        if (device)
        {
            // todo: make sure device->slot() matches io >> 8
            // figure out the offset from the base of this slot's addresses
            uint8_t io_offset = io & 0x0f;
            uint8_t dev_offset = device->getOffset();

            // now, figure out how far into this slot this particular port lives on the device
            uint8_t dev_port = io_offset - dev_offset;
            return device->in(dev_port);
        }
        else
        {
            // open bus read
            return 0xFF;
        }
    }

    virtual void write(uint16_t addr, uint8_t value) override
    {
        uint8_t io = addr & 0xff;
        MemoryIODevice *device = devices_[io];
        if (device)
        {
            uint8_t io_offset = io & 0x0f;
            uint8_t dev_offset = device->getOffset();
            uint8_t dev_port = io_offset - dev_offset;
            device->out(dev_port, value);
        }
        else
        {
            // open bus write
        }
    }

private:
    // MemoryIODevice getDevice(address)

    std::array<MemoryIODevice *, 0x100> devices_;
};