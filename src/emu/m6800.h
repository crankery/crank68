#pragma once

#include <cstdint>
#include <functional>
#include <stdexcept>
#include <string>

class M6800 {
public:
    using ReadFn  = std::function<uint8_t(uint16_t)>;
    using WriteFn = std::function<void(uint16_t, uint8_t)>;

    enum CC : uint8_t {
        C = 0x01, // Carry
        V = 0x02, // Overflow
        Z = 0x04, // Zero
        N = 0x08, // Negative
        I = 0x10, // IRQ mask
        H = 0x20  // Half-carry
    };

    struct State {
        uint8_t  a = 0;
        uint8_t  b = 0;
        uint16_t x = 0;
        uint16_t sp = 0;
        uint16_t pc = 0;
        uint8_t  cc = 0;
    };

    M6800(ReadFn read_fn, WriteFn write_fn);

    void reset();
    void step();

    const State& state() const { return s_; }
    State& state() { return s_; }

private:
    State s_;
    ReadFn read_;
    WriteFn write_;

    uint8_t  fetch8();
    uint16_t fetch16();
    uint8_t  read8(uint16_t addr) const;
    uint16_t read16(uint16_t addr) const;
    void     write8(uint16_t addr, uint8_t value);
    void     write16(uint16_t addr, uint16_t value);

    void push8(uint8_t v);
    void push16(uint16_t v);
    uint8_t pop8();
    uint16_t pop16();

    void set_nz8(uint8_t v);
    void set_nz16(uint16_t v);
    void set_flag(uint8_t flag, bool on);
    bool get_flag(uint8_t flag) const;

    uint8_t add8(uint8_t lhs, uint8_t rhs, bool carry_in = false);
    uint8_t sub8(uint8_t lhs, uint8_t rhs, bool carry_in = false);

    [[noreturn]] void unimplemented(uint8_t opcode) const;
};
