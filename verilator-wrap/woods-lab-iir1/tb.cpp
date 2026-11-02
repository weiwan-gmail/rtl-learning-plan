#include "Viir1.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Viir1> s;
    auto* t = s.top;
    const int B0 = 1, B1 = 1, A1 = 1, SHIFT = 1;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    int gx1 = 0, gy1 = 0, n = 0;
    std::vector<int16_t> xs = {0, 1000, 1000, 1000, -500, 0, 0};
    for (int k = 0; k < 40; k++)
        xs.push_back(static_cast<int16_t>((k * 37) & 0xFFFF));
    xs.push_back(2000);
    for (int k = 0; k < 10; k++) xs.push_back(0);

    for (int16_t x : xs) {
        int32_t acc = (int32_t)x * B0 + gx1 * B1 + gy1 * A1;
        int16_t y = sat16(acc >> SHIFT);
        gx1 = x;
        gy1 = y;
        t->din = x;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s16(t->dout) != y) fail("iir1");
        n++;
    }
    t->in_valid = 0;
    s.tick();
    if (n == 0) fail("iir1 empty");
    std::printf("PASS iir1 n_checked=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
