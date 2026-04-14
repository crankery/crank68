#pragma once

#include <cstdio>
#include <deque>
#include <string>
#include <string_view>

class LogBuffer
{
public:
    explicit LogBuffer(std::size_t max_messages = 1024)
        : max_messages_(max_messages)
    {
    }

    void log(std::string_view message);
    const std::deque<std::string> &messages() const;

private:
    std::size_t max_messages_;
    std::deque<std::string> messages_;
};