#include "sdBridgePia.h"

#include <stdexcept>

SdImageStorage::SdImageStorage(const std::string &path)
{
    file_ = std::fopen(path.c_str(), "r+b");
    if (!file_)
        throw std::runtime_error("Cannot open SD image for read/write: " + path);

    if (std::fseek(file_, 0, SEEK_END) != 0 ||
        std::ftell(file_) != long(sdbridge::ImageBytes))
    {
        std::fclose(file_);
        file_ = nullptr;
        throw std::runtime_error("SD image must be exactly 1 MiB: " + path);
    }
}

SdImageStorage::~SdImageStorage()
{
    if (file_)
        std::fclose(file_);
}

sdbridge::Status SdImageStorage::status() const
{
    return status_;
}

sdbridge::Status SdImageStorage::fail()
{
    status_ = sdbridge::Status::IoError;
    return status_;
}

sdbridge::Status SdImageStorage::read(uint32_t offset, uint8_t *buffer)
{
    if (status_ != sdbridge::Status::Ok)
        return status_;
    if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
        return sdbridge::Status::BadAddress;
    if (std::fseek(file_, long(offset), SEEK_SET) != 0 ||
        std::fread(buffer, 1, sdbridge::SectorBytes, file_) != sdbridge::SectorBytes)
        return fail();
    return sdbridge::Status::Ok;
}

sdbridge::Status SdImageStorage::write(uint32_t offset, const uint8_t *buffer)
{
    if (status_ != sdbridge::Status::Ok)
        return status_;
    if (offset > sdbridge::ImageBytes - sdbridge::SectorBytes)
        return sdbridge::Status::BadAddress;
    if (std::fseek(file_, long(offset), SEEK_SET) != 0 ||
        std::fwrite(buffer, 1, sdbridge::SectorBytes, file_) != sdbridge::SectorBytes ||
        std::fflush(file_) != 0)
        return fail();
    return sdbridge::Status::Ok;
}

sdbridge::Status SdImageStorage::sync()
{
    if (status_ != sdbridge::Status::Ok)
        return status_;
    return std::fflush(file_) == 0 ? sdbridge::Status::Ok : fail();
}

SdBridgePia::SdBridgePia(const std::string &image)
    : Pia(0x2, 0x0), storage_(image), engine_(storage_)
{
}

void SdBridgePia::publish()
{
    if (!published_ && engine_.responseByte(pb_))
    {
        published_ = true;
        ready_flag_ = true;
    }
}

uint8_t SdBridgePia::in(uint8_t port)
{
    switch (port)
    {
    case 0:
        receive_flag_ = false;
        return cra_ & 4 ? pa_ : ddra_;
    case 1:
        return cra_ | (receive_flag_ ? 0x80 : 0);
    case 2:
        ready_flag_ = false;
        return crb_ & 4 ? pb_ : ddrb_;
    case 3:
        return crb_ | (ready_flag_ ? 0x80 : 0);
    default:
        return 0xff;
    }
}

void SdBridgePia::out(uint8_t port, uint8_t value)
{
    switch (port)
    {
    case 0:
        (cra_ & 4 ? pa_ : ddra_) = value;
        break;
    case 1:
    {
        const auto previous = cra_;
        cra_ = value;
        if ((previous & 0x38) == 0x30 && (value & 0x38) == 0x38)
        {
            if (!engine_.receive(pa_))
                engine_.reset();
            receive_flag_ = true;
            publish();
        }
        break;
    }
    case 2:
        (crb_ & 4 ? pb_ : ddrb_) = value;
        break;
    case 3:
    {
        const auto previous = crb_;
        crb_ = value;
        if ((previous & 0x38) == 0x30 && (value & 0x38) == 0x38 && published_)
        {
            engine_.acknowledgeResponse();
            published_ = false;
            ready_flag_ = false;
            publish();
        }
        break;
    }
    }
}
