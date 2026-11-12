#pragma once
#include "protocol.h"

namespace sdbridge
{
namespace StatusBit
{
static const uint8_t RxSpace = 0x01, TxValid = 0x02, Busy = 0x04,
                     Error = 0x08, MediaReady = 0x10,
                     RxSequence = 0x20, TxSequence = 0x40;
}

// IO supplies pending(), takeCommand(), takeDataWrite(), clearDataRead(),
// clearAll(), stageData(byte), stageStatus(byte), and now(). The pending bits
// are held in hardware flip-flops until cleared through the 74HCT595.
template <class Engine, class IO> class DirectLink
{
public:
    DirectLink(Engine &engine, IO &io)
        : engine_(engine), io_(io), lastProgress_(0), txPublished_(false),
          error_(false), rxSequence_(false), txSequence_(false) {}

    void begin()
    {
        engine_.reset();
        io_.clearAll();
        io_.stageData(0);
        txPublished_ = error_ = rxSequence_ = txSequence_ = false;
        io_.stageStatus(status());
        lastProgress_ = io_.now();
    }

    void poll()
    {
        const uint8_t pending = io_.pending();
        // The host must wait for the sequence acknowledgment after each
        // access. Two outstanding events cannot be ordered from these flags.
        if ((pending & (pending - 1)) != 0)
        {
            recover();
            return;
        }

        if (pending & IO::CommandPending)
        {
            if (!engine_.expectsCommand())
            {
                recover();
                return;
            }
            const uint8_t command = io_.takeCommand();
            error_ = false;
            engine_.receiveCommand(command);
            publishResponse();
            updateStatus(true, false);
            lastProgress_ = io_.now();
        }
        else if (pending & IO::DataWritePending)
        {
            if (!engine_.expectsData())
            {
                recover();
                return;
            }
            const uint8_t value = io_.takeDataWrite();
            engine_.receiveData(value); // May block on SD I/O; host waits for RX sequence.
            publishResponse();
            updateStatus(true, false);
            lastProgress_ = io_.now();
        }
        else if (pending & IO::DataReadPending)
        {
            io_.clearDataRead();
            if (!txPublished_)
            {
                recover();
                return;
            }
            txPublished_ = false;
            engine_.acknowledgeResponse();
            publishResponse();
            updateStatus(false, true);
            lastProgress_ = io_.now();
        }
        else if (engine_.active() && uint32_t(io_.now() - lastProgress_) > LinkTimeoutMs)
        {
            recover();
        }
    }

    uint8_t status() const
    {
        uint8_t result = 0;
        if (engine_.receiving()) result |= StatusBit::RxSpace;
        if (txPublished_) result |= StatusBit::TxValid;
        if (engine_.active()) result |= StatusBit::Busy;
        if (error_) result |= StatusBit::Error;
        if (engine_.mediaReady()) result |= StatusBit::MediaReady;
        if (rxSequence_) result |= StatusBit::RxSequence;
        if (txSequence_) result |= StatusBit::TxSequence;
        return result;
    }

private:
    void publishResponse()
    {
        if (txPublished_)
            return;
        uint8_t value;
        if (engine_.responseByte(value))
        {
            io_.stageData(value);
            txPublished_ = true;
            if (engine_.responseStatus() != Status::Ok)
                error_ = true;
        }
    }

    void updateStatus(bool rxAck, bool txAck)
    {
        // Flags and the next data byte become stable before the sequence bit
        // changes. The host uses that bit as the completion acknowledgment.
        io_.stageStatus(status());
        if (rxAck) rxSequence_ = !rxSequence_;
        if (txAck) txSequence_ = !txSequence_;
        io_.stageStatus(status());
    }

    void recover()
    {
        io_.clearAll();
        engine_.reset();
        io_.stageData(0);
        txPublished_ = false;
        error_ = true;
        updateStatus(true, true);
        lastProgress_ = io_.now();
    }

    Engine &engine_;
    IO &io_;
    uint32_t lastProgress_;
    bool txPublished_, error_, rxSequence_, txSequence_;
};
} // namespace sdbridge
