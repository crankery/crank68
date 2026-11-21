#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

#include "mem.h"
#include "memoryIODevice.h"
#include "latch.h"
#include "acia.h"
#include "pia.h"
#include "sd.h"
#include "switches.h"
#include "rtc.h"

class MemoryIO : public Mem
{
public:
    MemoryIO()
        : Mem(StartAddress, EndAddress),
          banked_memory_latch_(0x0, 0x2),
          banked_memory_high_latch_(0x0, 0x3),
          config_switches_(0x0, 0x1),
          rtc_(0x7, 0x0),
          acia_1_0_(0x1, 0x0),
          acia_1_1_(0x1, 0x4),
          pia_1_0_(0x1, 0x8),
          pia_1_1_(0x1, 0xC)
    {
        devices_.push_back(&banked_memory_latch_);
        devices_.push_back(&banked_memory_high_latch_);
        devices_.push_back(&config_switches_);
        devices_.push_back(&rtc_);
        devices_.push_back(&acia_1_0_);
        devices_.push_back(&acia_1_1_);
        devices_.push_back(&pia_1_0_);
        devices_.push_back(&pia_1_1_);
    }

    auto &bankedMemoryLatch() { return banked_memory_latch_; }
    const auto &bankedMemoryLatch() const { return banked_memory_latch_; }

    void attachSdImage(const std::string &path)
    {
        auto sd = std::make_unique<Sd>(path);
        devices_.push_back(sd.get());
        sd_ = std::move(sd);
    }

    virtual uint8_t read(uint16_t addr) const override
    {
        for (auto dev : devices_)
        {
            int8_t port = dev->handles(addr);
            if (port >= 0)
            {
                return dev->in(port);
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
    Latch banked_memory_high_latch_;
    Switches config_switches_;
    Rtc rtc_;

    // IO board in slot 1: U2B decodes A3:A2 as ACIA 1, ACIA 2, PIA 1, PIA 2.
    Acia acia_1_0_;
    Acia acia_1_1_;
    Pia pia_1_0_;
    Pia pia_1_1_;

private:
    static const uint16_t StartAddress = 0xE000;
    static const uint16_t EndAddress = 0xE0FF;

    std::vector<MemoryIODevice *> devices_;
    std::unique_ptr<Sd> sd_;
};
