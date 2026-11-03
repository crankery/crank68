#pragma once
#include "protocol.h"
namespace sdbridge
{
static const uint8_t ReceiveEvent = 1, ConsumeEvent = 2, OverrunEvent = 4;

// IO: now(), receiveByte(), acknowledgeReceive(), publishByte(byte),
// withdrawByte(), idle(). Keeps the hardware-independent ordering testable.
template <class Engine, class IO> class Link
{
public:
    Link(Engine &engine, IO &io) : engine_(engine), io_(io), lastProgress_(0), published_(false)
    {
    }

    void begin()
    {
        recover();
    }

    void poll(uint8_t events)
    {
        if ((events & OverrunEvent) || ((events & ConsumeEvent) && !published_))
        {
            recover();
            return;
        }

        if (events & ConsumeEvent)
        {
            io_.withdrawByte();
            published_ = false;
            engine_.acknowledgeResponse();
            lastProgress_ = io_.now();
        }

        // Consume the final response ACK before accepting a new request from
        // the same interrupt batch. This permits back-to-back transactions.
        if (events & ReceiveEvent)
        {
            if (!engine_.receiving())
            {
                recover();
                return;
            }

            const uint8_t value = io_.receiveByte();
            engine_.receive(value);
            io_.acknowledgeReceive();
            lastProgress_ = io_.now();
        }

        if (!published_)
        {
            uint8_t value;
            if (engine_.responseByte(value))
            {
                io_.publishByte(value);
                published_ = true;
                lastProgress_ = io_.now();
            }
        }

        if (engine_.active() && uint32_t(io_.now() - lastProgress_) > LinkTimeoutMs)
            recover();
    }

private:
    void recover()
    {
        io_.idle();
        engine_.reset();
        published_ = false;
        lastProgress_ = io_.now();
    }

    Engine &engine_;
    IO &io_;
    uint32_t lastProgress_;
    bool published_;
};
} // namespace sdbridge
