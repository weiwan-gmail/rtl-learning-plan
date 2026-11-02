// Shared helpers for verilator-wrap C++ testbenches.
#pragma once

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <verilated.h>

inline int8_t s8(uint32_t v) { return static_cast<int8_t>(v & 0xFFu); }
inline int16_t s16(uint32_t v) { return static_cast<int16_t>(v & 0xFFFFu); }
inline int32_t s32(uint32_t v) { return static_cast<int32_t>(v); }

inline int32_t sext(int32_t v, int width) {
    const int shift = 32 - width;
    return (v << shift) >> shift;
}

inline int16_t wrap16(int32_t v) { return static_cast<int16_t>(v & 0xFFFF); }

inline int16_t sat16(int64_t v) {
    if (v > 32767) return 32767;
    if (v < -32768) return -32768;
    return static_cast<int16_t>(v);
}

inline int16_t q15_bits_30_15(int64_t acc) {
    // Verilog: yn = acc[30:15] as signed 16-bit
    const uint32_t u = static_cast<uint32_t>(acc);
    return static_cast<int16_t>((u >> 15) & 0xFFFFu);
}

[[noreturn]] inline void fail(const char* msg) {
    std::printf("FAIL %s\n", msg);
    std::fflush(stdout);
    std::exit(1);
}

inline void pass(const char* msg) {
    std::printf("PASS %s\n", msg);
    std::fflush(stdout);
}

// xorshift32 — deterministic “random” independent of Verilog $random.
struct Rng {
    uint32_t s;
    explicit Rng(uint32_t seed) : s(seed) {}
    uint32_t next() {
        s ^= s << 13;
        s ^= s >> 17;
        s ^= s << 5;
        return s;
    }
    int16_t s16rand() { return static_cast<int16_t>(next() & 0xFFFFu); }
};

template <typename Top>
struct Sim {
    Top* top;
    Sim() : top(new Top) { Verilated::traceEverOn(false); }
    ~Sim() {
        top->final();
        delete top;
    }
    Sim(const Sim&) = delete;
    Sim& operator=(const Sim&) = delete;
    void tick() {
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
    }
    void reset(int n = 3) {
        top->rst = 1;
        for (int i = 0; i < n; ++i) tick();
        top->rst = 0;
        tick();
    }
};
