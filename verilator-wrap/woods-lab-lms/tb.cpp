#include "Vlms2.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vlms2> s;
    auto* t = s.top;
    const int WSHIFT = 0, MUSHIFT = 5, N = 256;
    t->in_valid = 0;
    t->xin = 0;
    t->din = 0;
    s.reset(3);

    int gx0 = 0, gw0 = 0, gw1 = 0, px = 0, n_checked = 0;
    std::vector<int16_t> ey, ee;

    for (int k = 0; k < N; k++) {
        int16_t x = static_cast<int16_t>(((k * 5) % 17) - 8);
        int16_t d = sat16(2 * x + 1 * px);
        int nx0 = x, nx1 = gx0;
        int y = sat16((nx0 * gw0 + nx1 * gw1) >> WSHIFT);
        int e = sat16(d - y);
        int nw0 = sat16(gw0 + ((e * nx0) >> MUSHIFT));
        int nw1 = sat16(gw1 + ((e * nx1) >> MUSHIFT));
        ey.push_back(static_cast<int16_t>(y));
        ee.push_back(static_cast<int16_t>(e));
        gx0 = nx0; gw0 = nw0; gw1 = nw1;
        px = x;

        t->xin = x;
        t->din = d;
        t->in_valid = 1;
        s.tick();
        if (t->out_valid) {
            if (s16(t->yout) != ey[n_checked] || s16(t->eout) != ee[n_checked])
                fail("lms bit-exact");
            n_checked++;
        }
    }
    t->in_valid = 0;
    for (int i = 0; i < 4; i++) {
        s.tick();
        if (t->out_valid) {
            if (s16(t->yout) != ey[n_checked] || s16(t->eout) != ee[n_checked])
                fail("lms drain");
            n_checked++;
        }
    }
    if (n_checked != N) fail("lms count");
    int w0 = s16(t->w0_out), w1 = s16(t->w1_out);
    std::printf("INFO final w0=%d w1=%d (plant 2, 1)\n", w0, w1);
    if (w0 < 1 || w0 > 3) fail("w0 not converged");
    if (w1 < 0 || w1 > 2) fail("w1 not converged");
    std::printf("PASS lms2 n_checked=%d mismatches=0\n", n_checked);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
