#pragma once

#include <cstdint>
#include <functional>
#include <stdexcept>
#include <string>
#include <map>
#include <optional>

#include "gen/cpu_defs.g.h"
#include "cc.h"

class Cpu
{
public:
    enum class ShiftOp
    {
        asl,
        asr,
        lsr,
        rol,
        ror
    };

    struct State
    {
        uint8_t a = 0;
        uint8_t b = 0;
        uint16_t x = 0;
        uint16_t sp = 0;
        uint16_t pc = 0;
        uint8_t cc = 0;
    };

    Cpu()
    {
    }

    void reset();
    void step();

    const State &state() const { return s_; }
    State &state() { return s_; }

    State s_;

    uint32_t cycles_ = 0;

private:
    uint8_t read8(uint16_t addr) const;
    uint16_t read16(uint16_t addr) const;

    void write16(uint16_t addr, uint16_t value);
    void write8(uint16_t addr, uint8_t value);

    // fetch bytes at pc
    uint8_t fetch8();
    uint16_t fetch16();

    // push bytes to stack
    void push8(uint8_t v);
    void push16(uint16_t v);

    // pop bytes from stack
    uint8_t pop8();
    uint16_t pop16();

    // get/set flags
    void set_nz8(uint8_t v);
    void set_nz16(uint16_t v);
    void set_flag(uint8_t flag, bool on);
    bool get_flag(uint8_t flag) const;

    // math helpers
    uint8_t add8(uint8_t lhs, uint8_t rhs, bool carry_in = false);
    uint8_t sub8(uint8_t lhs, uint8_t rhs, bool carry_in = false);
    uint16_t sub16(uint16_t lhs, uint16_t rhs, bool carry_in = false);

    [[noreturn]] void infiniteloop() const;
    [[noreturn]] void unimplemented(uint8_t opcode) const;

    bool dispatch(uint8_t op, OpInfo op_info);

    uint8_t adc8(uint8_t a, uint8_t b);
    uint8_t inc8(uint8_t value);
    uint8_t dec8(uint8_t value);

    uint8_t do_shift8(uint8_t value, ShiftOp op);
    uint8_t do_rol8(uint8_t value);
    uint8_t do_ror8(uint8_t value);

    bool shift_a(ShiftOp op);
    bool shift_b(ShiftOp op);
    bool shift_mem(addr_mode mode, ShiftOp op);

    bool branch_if(bool condition, addr_mode mode);

    bool do_jump(addr_mode mode, bool subroutine);
    void do_test(uint8_t value);

    bool load8(uint8_t &value, addr_mode mode);
    bool load16(uint16_t &dst, addr_mode mode);
    bool store8(uint8_t value, addr_mode mode);
    bool store16(uint16_t value, addr_mode mode);

    uint8_t logic8(uint8_t result);

    std::optional<uint8_t> read_operand8(addr_mode mode);
    std::optional<uint16_t> resolve_operand_addr(addr_mode mode);

    bool neg_a();
    bool neg_b();
    bool neg_mem(addr_mode mode);
    uint8_t do_neg8(uint8_t value);

#include "gen/cpu_operations.g.h"
};
