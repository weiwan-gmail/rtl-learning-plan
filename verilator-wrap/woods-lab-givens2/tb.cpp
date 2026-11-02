#include "Vgivens_apply.h"
#include "tb_util.hpp"

int main() {
    Sim<Vgivens_apply> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->c = t->s = t->x_in = t->y_in = 0;
    s.reset(3);

    int n = 0;
    auto check = [&](int16_t cv, int16_t sv, int16_t xv, int16_t yv) {
        int32_t xn = (int32_t)cv * xv + (int32_t)sv * yv;
        int32_t yn = -(int32_t)sv * xv + (int32_t)cv * yv;
        int16_t xe = q15_bits_30_15(xn);
        int16_t ye = q15_bits_30_15(yn);
        t->c = cv;
        t->s = sv;
        t->x_in = xv;
        t->y_in = yv;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s16(t->x_out) != xe || s16(t->y_out) != ye)
            fail("givens");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    check(32767, 0, 1000, 2000);
    check(23170, 23170, 1000, 0);
    check(0, 32767, 1000, 0);
    check(19661, 26214, 3000, 4000);
    check(19661, 26214, 1000, 2000);

    std::printf("PASS givens_apply n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999 NULL_DEMO=1\n");
    return 0;
}
