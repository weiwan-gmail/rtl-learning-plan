#include "Vfft8.h"
#include "tb_util.hpp"

static const int16_t ONE_Q15 = 32767;
static const int16_t COS_PI4 = 23170;

static int bitrev3(int a) { return ((a & 1) << 2) | (a & 2) | ((a & 4) >> 2); }

static void gold_fft(const int16_t xin_r[8], const int16_t xin_i[8],
                     int16_t gxr[8], int16_t gxi[8]) {
    for (int n = 0; n < 8; n++) {
        gxr[bitrev3(n)] = xin_r[n];
        gxi[bitrev3(n)] = xin_i[n];
    }
    for (int stage = 0; stage < 3; stage++) {
        for (int bfly = 0; bfly < 4; bfly++) {
            int ia, ib;
            if (stage == 0) { ia = bfly * 2; ib = ia + 1; }
            else if (stage == 1) {
                ia = ((bfly >> 1) << 2) | (bfly & 1);
                ib = ia | 2;
            } else { ia = bfly; ib = bfly + 4; }
            int16_t wr = ONE_Q15, wi = 0;
            if (stage == 1 && (bfly & 1)) { wr = 0; wi = -ONE_Q15; }
            if (stage == 2) {
                switch (bfly) {
                    case 0: wr = ONE_Q15; wi = 0; break;
                    case 1: wr = COS_PI4; wi = -COS_PI4; break;
                    case 2: wr = 0; wi = -ONE_Q15; break;
                    default: wr = -COS_PI4; wi = -COS_PI4; break;
                }
            }
            int16_t ar = gxr[ia], ai = gxi[ia], br = gxr[ib], bi = gxi[ib];
            int16_t pr = wrap16(static_cast<int32_t>(((int64_t)br * wr - (int64_t)bi * wi) >> 15));
            int16_t pi = wrap16(static_cast<int32_t>(((int64_t)br * wi + (int64_t)bi * wr) >> 15));
            int sr = ar + pr, si = ai + pi, dr = ar - pr, di = ai - pi;
            gxr[ia] = wrap16(sr >> 1);
            gxi[ia] = wrap16(si >> 1);
            gxr[ib] = wrap16(dr >> 1);
            gxi[ib] = wrap16(di >> 1);
        }
    }
}

int main() {
    Sim<Vfft8> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din_re = t->din_im = 0;
    t->rst = 1;
    for (int i = 0; i < 4; i++) s.tick();
    t->rst = 0;
    s.tick();

    auto run_vec = [&](const int16_t xr[8], const int16_t xi[8]) {
        int16_t gxr[8], gxi[8];
        gold_fft(xr, xi, gxr, gxi);
        for (int i = 0; i < 8; i++) {
            int guard = 0;
            while (!t->in_ready) {
                s.tick();
                if (++guard > 64) fail("in_ready timeout");
            }
            t->din_re = xr[i];
            t->din_im = xi[i];
            t->in_valid = 1;
            s.tick();
        }
        t->in_valid = 0;
        int n_out = 0;
        for (int k = 0; k < 64 && n_out < 8; k++) {
            s.tick();
            if (t->out_valid) {
                if (s16(t->dout_re) != gxr[n_out] || s16(t->dout_im) != gxi[n_out])
                    fail("fft8 bin");
                n_out++;
            }
        }
        if (n_out != 8) fail("fft8 count");
    };

    int16_t xr[8], xi[8];
    for (int i = 0; i < 8; i++) { xr[i] = 1000; xi[i] = 0; }
    run_vec(xr, xi);
    for (int i = 0; i < 8; i++) { xr[i] = 0; xi[i] = 0; }
    xr[0] = 8000;
    run_vec(xr, xi);
    for (int i = 0; i < 8; i++) { xr[i] = static_cast<int16_t>(i * 100); xi[i] = 0; }
    run_vec(xr, xi);
    int16_t tr[8] = {4000, 0, -4000, 0, 4000, 0, -4000, 0};
    int16_t ti[8] = {0, -4000, 0, 4000, 0, -4000, 0, 4000};
    run_vec(tr, ti);

    std::printf("PASS fft8 vectors=4 mismatches=0\n");
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
