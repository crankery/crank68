#pragma once

#include <cstddef>
#include <cstdint>
#include <deque>
#include <optional>

// Single-client, loopback-only raw TCP serial transport. No terminal editing,
// case conversion or protocol negotiation occurs here. All I/O is nonblocking.
class TcpConsole {
public:
    static constexpr size_t BufferLimit = 65536;
    explicit TcpConsole(uint16_t port);
    ~TcpConsole();
    TcpConsole(const TcpConsole &) = delete;
    TcpConsole &operator=(const TcpConsole &) = delete;

    void poll();
    bool connected() const { return client_ >= 0; }
    uint16_t port() const { return port_; }
    std::optional<uint8_t> read();
    bool writable() const { return output_.size() < BufferLimit; }
    void write(uint8_t value);

private:
    int listener_ = -1;
    int client_ = -1;
    uint16_t port_ = 0;
    std::deque<uint8_t> input_;
    std::deque<uint8_t> output_;
    void disconnect();
};
