#pragma once
#include <stddef.h>
#include <stdint.h>

namespace sdbridge
{
static const uint8_t ProtocolVersion = 2, Tracks = 128, SectorsPerTrack = 32;
static const uint16_t SectorBytes = 256;
static const uint32_t ImageBytes = uint32_t(Tracks) * SectorsPerTrack * SectorBytes;
static const uint32_t LinkTimeoutMs = 2000;
enum class Status : uint8_t
{
    Ok = 0,
    NoCard = 1,
    NoFilesystem = 2,
    NoImage = 3,
    BadImage = 4,
    BadAddress = 5,
    IoError = 6,
    BadCommand = 7,
    BadChecksum = 8
};

enum class Command : uint8_t
{
    Info = 0x00,
    Status = 0x01,
    Read = 0x10,
    Write = 0x11,
    Sync = 0x12
};

// Sum the 256 unsigned payload bytes; transmit high byte then low byte.
inline uint16_t sectorChecksum(const uint8_t *data)
{
    uint16_t sum = 0;
    for (uint16_t n = 0; n < SectorBytes; ++n)
        sum = uint16_t(sum + data[n]);
    return sum;
}

inline bool validAddress(uint8_t track, uint8_t sector)
{
    return track < Tracks && sector >= 1 && sector <= SectorsPerTrack;
}

inline uint32_t fileOffset(uint8_t track, uint8_t sector)
{
    return (uint32_t(track) * SectorsPerTrack + (sector - 1)) * SectorBytes;
}

// Storage supplies status(), read(offset,buf), write(offset,buf), sync().
// One 256-byte staging buffer; no heap, dynamic strings or second sector copy.
template <class Storage> class Engine
{
public:
    explicit Engine(Storage &storage) : storage_(storage)
    {
        reset();
    }

    void reset()
    {
        state_ = State::SyncA;
        received_ = outAt_ = outSize_ = 0;
        readReply_ = false;
    }

    bool receiving() const
    {
        return state_ != State::Response;
    }

    bool idle() const
    {
        return state_ == State::SyncA;
    }

    bool active() const
    {
        return !idle();
    }

    bool responseByte(uint8_t &value) const
    {
        if (state_ != State::Response)
            return false;
        if (!readReply_ || outAt_ == 0)
            value = reply_[outAt_];
        else if (outAt_ <= SectorBytes)
            value = buffer_[outAt_ - 1];
        else
            value = outAt_ == SectorBytes + 1 ? uint8_t(checksum_ >> 8) : uint8_t(checksum_);
        return true;
    }

    bool acknowledgeResponse()
    {
        if (state_ != State::Response)
            return false;
        if (++outAt_ == outSize_)
            reset();
        return true;
    }

    bool receive(uint8_t value)
    {
        if (!receiving())
            return false;
        switch (state_)
        {
        case State::SyncA:
            if (value == 0xa5)
                state_ = State::SyncB;
            break;
        case State::SyncB:
            state_ = value == 0x5a ? State::Opcode : value == 0xa5 ? State::SyncB : State::SyncA;
            break;
        case State::Opcode:
            command_ = value;
            state_ = State::Track;
            break;
        case State::Track:
            track_ = value;
            state_ = State::Sector;
            break;
        case State::Sector:
            sector_ = value;
            dispatch();
            break;
        case State::Payload:
            buffer_[received_++] = value;
            checksum_ = uint16_t(checksum_ + value);
            if (received_ == SectorBytes)
                state_ = State::ChecksumHigh;
            break;
        case State::ChecksumHigh:
            checksumHigh_ = value;
            state_ = State::ChecksumLow;
            break;
        case State::ChecksumLow:
            if (!validAddress(track_, sector_))
                answer(Status::BadAddress);
            else if (checksum_ != uint16_t((uint16_t(checksumHigh_) << 8) | value))
                answer(Status::BadChecksum);
            else
                answer(storage_.write(fileOffset(track_, sector_), buffer_));
            break;
        case State::Response:
            return false;
        }

        return true;
    }

private:
    enum class State : uint8_t
    {
        SyncA,
        SyncB,
        Opcode,
        Track,
        Sector,
        Payload,
        ChecksumHigh,
        ChecksumLow,
        Response
    };

    void answer(Status status)
    {
        reply_[0] = static_cast<uint8_t>(status);
        outAt_ = 0;
        outSize_ = 1;
        readReply_ = false;
        state_ = State::Response;
    }

    void dispatch()
    {
        const auto command = static_cast<Command>(command_);
        if (command != Command::Read && command != Command::Write && (track_ || sector_))
        {
            answer(Status::BadAddress);
            return;
        }

        switch (command)
        {
        case Command::Info:
            answer(Status::Ok);
            reply_[1] = ProtocolVersion;
            reply_[2] = Tracks;
            reply_[3] = SectorsPerTrack;
            reply_[4] = uint8_t(SectorBytes);
            reply_[5] = uint8_t(SectorBytes >> 8);
            outSize_ = 6;
            break;
        case Command::Status:
            answer(storage_.status());
            break;
        case Command::Read:
        {
            auto status = validAddress(track_, sector_)
                              ? storage_.read(fileOffset(track_, sector_), buffer_)
                              : Status::BadAddress;
            answer(status);
            if (status == Status::Ok)
            {
                checksum_ = sectorChecksum(buffer_);
                readReply_ = true;
                outSize_ = SectorBytes + 3;
            }

            break;
        }

        case Command::Write:
            received_ = 0;
            checksum_ = 0;
            state_ = State::Payload;
            break;
        case Command::Sync:
            answer(storage_.sync());
            break;
        default:
            answer(Status::BadCommand);
            break;
        }
    }

    Storage &storage_;
    State state_;
    uint8_t command_, track_, sector_, checksumHigh_;
    uint16_t received_, outAt_, outSize_, checksum_;
    bool readReply_;
    uint8_t reply_[6], buffer_[SectorBytes];
};
} // namespace sdbridge
