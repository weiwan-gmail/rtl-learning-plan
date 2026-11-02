#include "Vrcm_const_mul.h"
#include "tb_util.hpp"

static const int COEFFS[5] = {7, 5, 9, 15, 6};

int main() {
    Sim<Vrcm_const_mul> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->x = 0;
    t->sel = 0;
    s.reset(3);

    int n = 0;
    Rng rng(0x51C0u);

    auto check = [&](int16_t xv, int sel) {
        int32_t exp = (int32_t)xv * COEFFS[sel];
        t->x = xv;
        t->sel = sel;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s32(t->y) != exp) fail("rcm");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    check(1, 0);
    check(10, 1);
    check(-3, 2);
    check(100, 3);
    check(7, 4);
    check(-20, 0);
    for (int k = 0; k < 30; k++)
        check(rng.s16rand(), k % 5);

    std::printf("PASS rcm_const_mul n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
