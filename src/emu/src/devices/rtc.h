#pragma once

#include <array>
#include <ctime>
#include "memoryIODevice.h"

// RP5C01A calendar behind an address latch ($E070) and nibble data port ($E071).
// Calendar writes are ignored: the host's local clock is the time source.
class Rtc : public MemoryIODevice
{
public:
    Rtc() : MemoryIODevice(0x7, 0x0, 2) {}

    uint8_t in(uint8_t port) override
    {
        if (port == 0) return address_;
        if (address_ == 0xd) return mode_;
        if (address_ >= 0xe) return 0xff;
        const uint8_t bank = mode_ & 3;
        if (bank >= 2) return ram_[bank-2][address_];
        if (bank == 1) {
            if (address_ == 0xa) return 1; // 24-hour format
            if (address_ == 0xb) return static_cast<uint8_t>(calendar_.tm_year % 4);
            return 0;
        }
        if (!have_calendar_) snapshot();
        const unsigned year = unsigned(calendar_.tm_year + 1900) % 100;
        const unsigned values[] = {
            unsigned(calendar_.tm_sec), unsigned(calendar_.tm_min),
            unsigned(calendar_.tm_hour), unsigned(calendar_.tm_wday),
            unsigned(calendar_.tm_mday), unsigned(calendar_.tm_mon+1), year
        };
        if (address_ == 6) return static_cast<uint8_t>(values[3]);
        unsigned value = 0;
        switch (address_) {
            case 0: case 1: value = values[0]; break;
            case 2: case 3: value = values[1]; break;
            case 4: case 5: value = values[2]; break;
            case 7: case 8: value = values[4]; break;
            case 9: case 10: value = values[5]; break;
            case 11: case 12: value = values[6]; break;
        }
        return static_cast<uint8_t>((address_ == 1 || address_ == 3 ||
                                     address_ == 5 || address_ == 8 ||
                                     address_ == 10 || address_ == 12)
                                    ? value / 10 : value % 10);
    }

    void out(uint8_t port, uint8_t value) override
    {
        if (port == 0) { address_ = value & 0xf; return; }
        if (address_ == 0xd) {
            mode_ = value & 0xf;
            if ((mode_ & 3) == 0) snapshot();
        } else if (address_ < 0xd && (mode_ & 3) >= 2) {
            ram_[(mode_ & 3)-2][address_] = value & 0xf;
        }
    }
    char *name() override { return name_; }

private:
    void snapshot()
    {
        const std::time_t now = std::time(nullptr);
        have_calendar_ = localtime_r(&now, &calendar_) != nullptr;
    }
    uint8_t address_ = 0, mode_ = 8;
    std::array<std::array<uint8_t,13>,2> ram_{};
    mutable std::tm calendar_{};
    mutable bool have_calendar_ = false;
    char name_[4] = "rtc";
};
