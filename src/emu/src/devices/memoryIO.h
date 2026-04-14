#pragma once

#include <cstdint>
#include <vector>

#include "mem.h"
#include "memoryIODevice.h"
#include "latch.h"
#include "acia.h"
#include "pia.h"
#include "switches.h"

class MemoryIO : public Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress),
          banked_memory_latch_(0x0, 0x0),
          config_switches_(0x0, 0x1),
          acia_1_0_(0x1, 0x0),
          pia_2_0_(0x2, 0x0),
          pia_2_1_(0x2, 0x4),
          acia_2_0_(0x2, 0x8),
          acia_2_1_(0x2, 0xA)
    {
        // slot 0
        devices_.push_back(&banked_memory_latch_);
        devices_.push_back(&config_switches_);

        // slot 1
        devices_.push_back(&acia_1_0_);

        // slot 2
        devices_.push_back(&pia_2_0_);
        devices_.push_back(&pia_2_1_);
        devices_.push_back(&acia_2_0_);
        devices_.push_back(&acia_2_1_);
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        for (auto dev : devices_)
        {
            if (dev->handles(addr) >= 0)
            {
                return dev->in(addr);
            }
        }

        return 0xff;
    }

    virtual void write(uint16_t addr, uint8_t value) override
    {
        for (auto dev : devices_)
        {
            int8_t port = dev->handles(addr);
            if (port >= 0)
            {
                dev->out(port, value);
                return;
            }
        }
    }

    // slot 0, latches and such
    Latch banked_memory_latch_;
    Switches config_switches_;

    // slot 1, terminal card
    Acia acia_1_0_;

    // slot 2, io card
    Pia pia_2_0_;
    Pia pia_2_1_;
    Acia acia_2_0_;
    Acia acia_2_1_;

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    std::vector<MemoryIODevice *> devices_;
};