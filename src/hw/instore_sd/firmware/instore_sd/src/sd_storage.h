#pragma once
#include <SD.h>
#include "avr_board.h"
#include "protocol.h"

// Use the Arduino SD library's SdFile API so sync() failures are observable.
// The public File::flush() wrapper returns void. No FILE_WRITE/O_APPEND.
class SdStorage
{
public:
    SdStorage() : status_(sdbridge::Status::NoCard)
    {
    }

    void begin()
    {
        using sdbridge::Status;
        if (!card_.init(SPI_HALF_SPEED, 10))
        {
            status_ = Status::NoCard;
            return;
        }

        if (!volume_.init(&card_) || !root_.openRoot(&volume_))
        {
            status_ = Status::NoFilesystem;
            return;
        }

        if (!image_.open(&root_, "FLEX.DSK", O_READ | O_WRITE))
        {
            status_ = Status::NoImage;
            return;
        }

        if (image_.fileSize() != sdbridge::ImageBytes)
        {
            image_.close();
            status_ = Status::BadImage;
            return;
        }

        status_ = Status::Ok;
    }

    sdbridge::Status status() const
    {
        return status_;
    }

    sdbridge::Status read(uint32_t offset, uint8_t *buffer)
    {
        if (status_ != sdbridge::Status::Ok)
            return status_;
        if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
            return sdbridge::Status::BadAddress;
        board::beginActivity();
        const bool ok = image_.seekSet(offset) &&
                        image_.read(buffer, sdbridge::SectorBytes) == sdbridge::SectorBytes;
        board::endActivity();
        return ok ? sdbridge::Status::Ok : fail();
    }

    sdbridge::Status write(uint32_t offset, const uint8_t *buffer)
    {
        if (status_ != sdbridge::Status::Ok)
            return status_;
        if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
            return sdbridge::Status::BadAddress;
        board::beginActivity();
        const bool ok = image_.seekSet(offset) &&
                        image_.write(buffer, sdbridge::SectorBytes) == sdbridge::SectorBytes &&
                        image_.sync();
        board::endActivity();
        return ok ? sdbridge::Status::Ok : fail();
    }

    sdbridge::Status sync()
    {
        if (status_ != sdbridge::Status::Ok)
            return status_;
        board::beginActivity();
        const bool ok = image_.sync();
        board::endActivity();
        return ok ? sdbridge::Status::Ok : fail();
    }

private:
    sdbridge::Status fail()
    {
        status_ = sdbridge::Status::IoError;
        return status_;
    }

    Sd2Card card_;
    SdVolume volume_;
    SdFile root_, image_;
    sdbridge::Status status_;
};
