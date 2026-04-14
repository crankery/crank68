#include "logBuffer.h"

void LogBuffer::log(std::string_view message)
{
    // Store a copy in the ring buffer
    messages_.emplace_back(message);

    // Trim oldest if over capacity
    if (messages_.size() > max_messages_)
    {
        messages_.pop_front();
    }
}

const std::deque<std::string> &LogBuffer::messages() const
{
    return messages_;
}
