#include "Vbiquad_df1.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vbiquad_df1> s;
    auto* t = s.top;
    const int16_t B0 = 8192, B1 = 8192, B2 = 8192;
    const int16_t A1 = -16384, A2 = 8192;
    t->in_valid = 0;
    t->x_in = 0;
    t->b0 = B0;
    t->b1 = B1;
    t->b2 = B2;
    t->a1 = A1;
    t->a2 = A2;
    s.reset(3);

    int16_t x1 = 0, x2 = 0, y1 = 0, y2 = 0;
    int n = 0;
    Rng rng(0xB1C0u);
    std::vector<int16_t> xs = {0, 1000, 2000, 3000, -1000, 500};
    for (int i = 0; i < 20; i++)
        xs.push_back(static_cast<int16_t>(rng.s16rand() >> 2));

    for (int16_t x : xs) {
        int32_t acc = (int32_t)B0 * x + (int32_t)B1 * x1 + (int32_t)B2 * x2 -
                      (int32_t)A1 * y1 - (int32_t)A2 * y2;
        int16_t y = q15_bits_30_15(acc);
        t->x_in = x;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s16(t->y_out) != y) fail("biquad");
        x2 = x1;
        x1 = x;
        y2 = y1;
        y1 = y;
        n++;
        t->in_valid = 0;
        s.tick();
    }
    if (n == 0) fail("biquad empty");
    std::printf("PASS biquad_df1 n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
