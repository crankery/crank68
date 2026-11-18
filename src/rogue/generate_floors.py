"""Create the immutable terrain files used by the FLEX ROGUE command.

Each file is RFL1, depth, up-room, down-room, nine six-byte room records,
1200 map bytes, then an XOR of all bytes after the magic. Mutable game state
is deliberately outside this format.
"""

from collections import deque
from functools import reduce
from random import Random

WIDTH, HEIGHT, FLOOR_COUNT = 60, 20, 26
PASSABLE = set(b'.#+*%<')


def make_floor(depth, up_room, rng):
    cells = bytearray(b' ' * (WIDTH * HEIGHT))
    rooms = []
    for slot in range(9):
        sx, sy = 1 + 20 * (slot % 3), 1 + 6 * (slot // 3)
        width, height = rng.randint(12, 16), rng.randint(4, 5)
        left, top = sx + rng.randint(0, 2), sy + rng.randint(0, 1)
        right, bottom = left + width - 1, top + height - 1
        room = (left, right, top, bottom, (left + right) // 2, (top + bottom) // 2)
        rooms.append(room)
        for y in range(top, bottom + 1):
            for x in range(left, right + 1):
                cells[y * WIDTH + x] = ord('-' if y in (top, bottom) else
                                         '|' if x in (left, right) else '.')

    for a, b in ((0, 1), (1, 2), (3, 4), (4, 5), (6, 7), (7, 8)):
        y = max(rooms[a][2], rooms[b][2]) + 1
        for x in range(rooms[a][1], rooms[b][0] + 1):
            cells[y * WIDTH + x] = ord('+' if x in (rooms[a][1], rooms[b][0]) else '#')
    # Two separate bridges between each pair of room bands give the player
    # more than one visible route into the next three rooms.
    for row in (0, 1):
        for column in rng.sample(range(3), 2):
            a = row * 3 + column
            b = a + 3
            x = max(rooms[a][0], rooms[b][0]) + 1 + rng.randrange(4)
            for y in range(rooms[a][3], rooms[b][2] + 1):
                cells[y * WIDTH + x] = ord('+' if y in (rooms[a][3], rooms[b][2]) else '#')

    down_room = rng.choice([i for i in range(9) if i != up_room])
    def center(room):
        return room[5] * WIDTH + room[4]
    cells[center(rooms[up_room])] = ord('<')
    cells[center(rooms[down_room])] = ord('%')
    for i, room in enumerate(rooms):
        if i not in (up_room, down_room) and rng.randrange(2):
            cells[center(room)] = ord('*')

    seen = {center(rooms[up_room])}
    todo = deque(seen)
    while todo:
        pos = todo.popleft()
        for nxt in (pos - WIDTH, pos + WIDTH, pos - 1, pos + 1):
            if 0 <= nxt < len(cells) and nxt not in seen and cells[nxt] in PASSABLE:
                seen.add(nxt)
                todo.append(nxt)
    assert all(i in seen for i, tile in enumerate(cells) if tile in PASSABLE)
    assert all(cells[x] == 32 and cells[(HEIGHT - 1) * WIDTH + x] == 32
               for x in range(WIDTH))
    assert all(cells[y * WIDTH] == 32 and cells[y * WIDTH + WIDTH - 1] == 32
               for y in range(HEIGHT))
    body = bytes((depth, up_room, down_room)) + bytes(v for room in rooms for v in room) + cells
    return b'RFL1' + body + bytes((reduce(lambda a, b: a ^ b, body, 0),)), down_room


def floor_files():
    rng = Random(0xC6800)
    up_room = 0
    files = []
    for depth in range(1, FLOOR_COUNT + 1):
        data, up_room = make_floor(depth, up_room, rng)
        files.append((f'RFL{depth:02d}.DAT', data))
    assert len({data for _, data in files}) == FLOOR_COUNT
    return files
