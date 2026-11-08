#include <cassert>
#include <cstring>
#include "key_logic.h"

using keyboard::Rows;

static keyboard::Events settle(keyboard::State &keys, const uint16_t rows[Rows])
{
    keys.scan(rows);
    keys.scan(rows);
    return keys.scan(rows);
}

int main()
{
    keyboard::State keys;
    uint16_t rows[Rows] = {};
    assert(keys.front() == 0);

    rows[1] = uint16_t(1 << 1); // q
    keys.scan(rows);
    assert(keys.front() == 0); // Bounce cannot emit a character.
    rows[1] = 0;
    settle(keys, rows);
    rows[1] = uint16_t(1 << 1);
    settle(keys, rows);
    assert(keys.front() == 'q');
    settle(keys, rows);
    assert(keys.front() == 'q'); // Held key does not repeat.
    keys.consume();
    assert(keys.front() == 0);

    rows[2] = 1; // Caps
    assert(settle(keys, rows).capsChanged);
    assert(keys.caps());
    rows[1] = 0;
    settle(keys, rows);
    rows[1] = uint16_t(1 << 1);
    settle(keys, rows);
    assert(keys.front() == 'Q');
    keys.consume();

    rows[1] = 0;
    rows[3] = 1; // Shift reverses caps for a letter.
    settle(keys, rows);
    rows[1] = uint16_t(1 << 1);
    settle(keys, rows);
    assert(keys.front() == 'q');
    keys.consume();

    rows[1] = 0;
    rows[2] = 0;
    rows[3] = 0;
    rows[4] = 1; // Left Control
    settle(keys, rows);
    rows[5] = uint16_t(1 << 8); // Ctrl+backslash raises NMI, never enters queue.
    assert(settle(keys, rows).breakPressed);
    assert(keys.front() == 0);
    assert(!settle(keys, rows).breakPressed);
    rows[5] = 0;
    settle(keys, rows);
    rows[5] = uint16_t(1 << 8);
    assert(settle(keys, rows).breakPressed);
    assert(keys.front() == 0);

    rows[5] = 0;
    rows[4] = uint16_t(1 << 6); // Right Control also works.
    settle(keys, rows);
    rows[5] = uint16_t(1 << 8);
    assert(settle(keys, rows).breakPressed);
    assert(keys.front() == 0);

    rows[5] = 0;
    settle(keys, rows);
    rows[5] = uint16_t(1 << 2); // Ctrl+Backspace raises RESET.
    assert(settle(keys, rows).resetPressed);
    assert(keys.front() == 0);
    assert(!settle(keys, rows).resetPressed);
    rows[5] = 0;
    settle(keys, rows);
    rows[5] = uint16_t(1 << 2);
    assert(settle(keys, rows).resetPressed);
    assert(keys.front() == 0);

    rows[5] = 0;
    settle(keys, rows);
    rows[5] = uint16_t((1 << 2) | (1 << 8));
    const keyboard::Events both = settle(keys, rows);
    assert(both.resetPressed && !both.breakPressed); // Reset takes precedence.
    assert(keys.front() == 0);

    std::memset(rows, 0, sizeof(rows));
    settle(keys, rows);
    rows[4] = 1; // Ctrl+Q
    rows[1] = uint16_t(1 << 1);
    settle(keys, rows);
    assert(keys.front() == 17);
    keys.consume();
    assert(keys.front() == 0);

    std::memset(rows, 0, sizeof(rows));
    settle(keys, rows);
    rows[4] = uint16_t(1 << 3); // Space, distinct from Alt.
    settle(keys, rows);
    assert(keys.front() == ' ');
    keys.consume();

    rows[4] = 0;
    settle(keys, rows);
    rows[0] = uint16_t(1 << 1); // '1' with Shift.
    rows[3] = 1;
    settle(keys, rows);
    assert(keys.front() == '!');
    keys.consume();
    assert(keys.front() == 0);

    keyboard::State full;
    uint16_t fill[Rows] = {};
    for (int i = 0; i < 16; ++i)
    {
        fill[1] = uint16_t(1 << 1);
        settle(full, fill);
        fill[1] = 0;
        settle(full, fill);
    }

    assert(full.dropped() == 1);
    fill[4] = 1;
    fill[5] = uint16_t(1 << 8);
    assert(settle(full, fill).breakPressed); // NMI bypasses a full queue.
    assert(full.front() == 'q');

    fill[5] = 0;
    settle(full, fill);
    fill[5] = uint16_t(1 << 2);
    assert(settle(full, fill).resetPressed); // RESET also bypasses a full queue.
    assert(full.front() == 'q');
}
