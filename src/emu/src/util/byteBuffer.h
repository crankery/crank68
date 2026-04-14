#pragma once

#include <optional>
#include <cstdint>
#include <queue>

class ByteBuffer
{
public:
    ByteBuffer()
    {
    }

    void push(uint8_t b)
    {
        items.push(b);
    }

    std::optional<uint8_t> next()
    {
        if (!empty())
        {
            auto item = items.front();
            items.pop();

            return item;
        }

        return std::nullopt;
    }

    bool empty() const
    {
        return items.empty();
    }

    int length()
    {
        return items.size();
    }

private:
    std::queue<uint8_t> items;
};