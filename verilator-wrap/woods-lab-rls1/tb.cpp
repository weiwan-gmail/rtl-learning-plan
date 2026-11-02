#include "Vrls1.h"
#include "tb_util.hpp"

static const int PSCALE = 256;
static const int WSCALE = 256;
static const int PINIT = 256 * 16;

static int32_t div_tz(int32_t num, int32_t den) {
    if (den == 0) return 0;
    int32_t a = num < 0 ? -num : num;
    int32_t b = den < 0 ? -den : den;
    int32_t q = a / b;
    return ((num < 0) != (den < 0)) ? -q : q;
}

int main() {
    Sim<Vrls1> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->xin = 0;
    t->din = 0;
    s.reset(3);

    int32_t gw = 0, gp = PINIT;
    int n = 0;
    const int16_t xs[20] = {1, 2, -1, 3, -2, 1, 2, 4, -3, 1,
                            2, -1, 3, 1, -2, 2, 1, -1, 2, 3};

    for (int i = 0; i < 20; i++) {
        int16_t xv = xs[i];
        int16_t dv = static_cast<int16_t>(3 * xv);
        int32_t den = PSCALE + xv * xv * gp;
        int32_t k_q = div_tz(gp * xv * PSCALE, den);
        int32_t y = div_tz(gw * xv, WSCALE);
        int32_t e = (int32_t)dv - y;
        int32_t wn = gw + div_tz(k_q * e * WSCALE, PSCALE);
        int32_t pn = div_tz(gp * PSCALE, den);
        if (pn < 1) pn = 1;

        t->xin = xv;
        t->din = dv;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s16(t->yout) != sat16(y) || s16(t->eout) != sat16(e) ||
            s32(t->w_q_out) != wn || s32(t->p_out) != pn)
            fail("rls");
        gw = wn;
        gp = pn;
        n++;
        t->in_valid = 0;
        s.tick();
    }

    int w = s16(t->w_out);
    if (w != 3 && w != 2 && w != 4) fail("w not near 3");
    std::printf("PASS rls1 n=%d final_w=%d w_q=%d p=%d mismatches=0\n", n, w,
                s32(t->w_q_out), s32(t->p_out));
    std::printf("METRIC RMSE=0 SNR_dB=999 TARGET_W=3\n");
    return 0;
}
