#include "key_logic.h"

namespace keyboard
{
namespace
{
constexpr uint16_t ColumnMask = 0x07ff;

// Zeroes are modifier, unused, or currently untranslated positions.
constexpr char Plain[Rows][Columns + 1] = {
    "\0331234567890",
    "\tqwertyuiop",
    "\0asdfghjkl;",
    "\0zxcvbnm,./",
    "\0\0\0 \0\0\0\0\0\0\0",
    "=]\b\r`-['\\\0\0",
};

constexpr char Shifted[Rows][Columns + 1] = {
    "\033!@#$%^&*()",
    "\tQWERTYUIOP",
    "\0ASDFGHJKL:",
    "\0ZXCVBNM<>?",
    "\0\0\0 \0\0\0\0\0\0\0",
    "+}\b\r~_{\"|\0\0",
};

bool down(const uint16_t rows[Rows], uint8_t row, uint8_t column)
{
    return (rows[row] & (uint16_t(1) << column)) != 0;
}
}

State::State()
    : candidate_{}, stable_{}, queue_{}, head_(0), tail_(0), same_(0),
      dropped_(0), caps_(false), breakHeld_(false), resetHeld_(false)
{
}

uint8_t State::front() const
{
    return head_ == tail_ ? 0 : queue_[tail_];
}

void State::consume()
{
    if (head_ != tail_)
    {
        tail_ = uint8_t((tail_ + 1) & (QueueSize - 1));
    }
}

void State::push(uint8_t value)
{
    const uint8_t next = uint8_t((head_ + 1) & (QueueSize - 1));
    if (next == tail_)
    {
        if (dropped_ != 255)
        {
            ++dropped_;
        }
        return;
    }

    queue_[head_] = value;
    head_ = next;
}

Events State::scan(const uint16_t rows[Rows])
{
    Events events = {false, false, false};
    bool matches = true;
    for (uint8_t row = 0; row < Rows; ++row)
    {
        if ((rows[row] & ColumnMask) != candidate_[row])
        {
            matches = false;
        }

        candidate_[row] = uint16_t(rows[row] & ColumnMask);
    }

    if (!matches)
    {
        same_ = 1;
        return events;
    }

    if (same_ < 3)
    {
        ++same_;
    }

    if (same_ < 3)
    {
        return events;
    }

    uint16_t pressed[Rows];
    for (uint8_t row = 0; row < Rows; ++row)
    {
        pressed[row] = uint16_t(candidate_[row] & ~stable_[row]);
        stable_[row] = candidate_[row];
    }

    if (pressed[2] & 1)
    {
        caps_ = !caps_;
        events.capsChanged = true;
    }

    const bool control = down(stable_, 4, 0) || down(stable_, 4, 6);
    const bool shift = down(stable_, 3, 0) || down(stable_, 5, 9);
    const bool resetting = control && down(stable_, 5, 2);
    const bool breaking = control && down(stable_, 5, 8) && !resetting;
    if (resetting && !resetHeld_)
    {
        events.resetPressed = true;
    }

    if (breaking && !breakHeld_)
    {
        events.breakPressed = true;
    }

    breakHeld_ = breaking;
    resetHeld_ = resetting;

    for (uint8_t row = 0; row < Rows; ++row)
    {
        for (uint8_t column = 0; column < Columns; ++column)
        {
            if (!(pressed[row] & (uint16_t(1) << column)))
            {
                continue;
            }

            // Ctrl+backslash reaches NMI without entering the character queue.
            if (row == 5 && ((breaking && column == 8) ||
                             (resetting && (column == 2 || column == 8))))
            {
                continue;
            }

            uint8_t value = uint8_t(Plain[row][column]);
            if (!value)
            {
                continue;
            }

            if (value >= 'a' && value <= 'z')
            {
                if (caps_ != shift)
                {
                    value = uint8_t(value - ('a' - 'A'));
                }
            }
            else if (shift)
            {
                value = uint8_t(Shifted[row][column]);
            }

            if (control && ((value >= 'a' && value <= 'z') ||
                            (value >= 'A' && value <= 'Z')))
            {
                value &= 0x1f;
            }

            if (value)
            {
                push(value);
            }
        }
    }

    return events;
}
}
