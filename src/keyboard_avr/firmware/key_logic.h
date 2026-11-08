#pragma once

#include <stdint.h>

// Matrix rows and columns match ../Keyboard and vera/keyboard.s.
namespace keyboard
{
constexpr uint8_t Rows = 6;
constexpr uint8_t Columns = 11;
constexpr uint8_t QueueSize = 16;

struct Events
{
    bool capsChanged;
    bool breakPressed;
    bool resetPressed;
};

class State
{
public:
    State();

    // Call once per complete matrix scan, at roughly 5 ms intervals.
    Events scan(const uint16_t rows[Rows]);
    uint8_t front() const;
    void consume();
    bool caps() const { return caps_; }
    uint8_t dropped() const { return dropped_; }

private:
    uint16_t candidate_[Rows];
    uint16_t stable_[Rows];
    uint8_t queue_[QueueSize];
    uint8_t head_;
    uint8_t tail_;
    uint8_t same_;
    uint8_t dropped_;
    bool caps_;
    bool breakHeld_;
    bool resetHeld_;

    void push(uint8_t value);
};
}
