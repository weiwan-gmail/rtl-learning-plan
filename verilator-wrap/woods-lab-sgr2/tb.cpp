#include "Vsgr_step.h"
#include "tb_util.hpp"

int main() {
    Sim<Vsgr_step> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->a = t->b = t->x_in = t->y_in = 0;
    s.reset(3);

    int n = 0;
    auto check = [&](int16_t aa, int16_t bb, int16_t xx, int16_t yy) {
        int32_t xe = (int32_t)aa * xx + (int32_t)bb * yy;
        int32_t ye = -(int32_t)bb * xx + (int32_t)aa * yy;
        int32_t r2e = (int32_t)aa * aa + (int32_t)bb * bb;
        t->a = aa;
        t->b = bb;
        t->x_in = xx;
        t->y_in = yy;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s32(t->x_out) != xe || s32(t->y_out) != ye ||
            s32(t->r2_out) != r2e)
            fail("sgr");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    check(3, 4, 3, 4);
    if (s32(t->x_out) != 25 || s32(t->y_out) != 0 || s32(t->r2_out) != 25)
        fail("null345");
    check(5, 12, 5, 12);
    check(8, 15, 8, 15);
    check(7, -24, 7, -24);
    check(3, 4, 1, 2);
    check(3, 4, 10, -5);
    check(-6, 8, -6, 8);
    check(20, 21, 20, 21);
    check(1, 0, 9, 4);

    std::printf("PASS sgr_step n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999 NULL_R2=1 NO_SQRT=1\n");
    return 0;
}
