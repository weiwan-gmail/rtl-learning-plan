#include "Vwrap_biquad_fold.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_biquad_fold> s;
    auto* t = s.top;
    const int16_t B0 = 8192, B1 = 8192, B2 = 8192, A1 = -16384, A2 = 8192;
    t->in_p = 0;
    t->in_f = 0;
    t->xp = t->xf = 0;
    t->b0 = B0; t->b1 = B1; t->b2 = B2; t->a1 = A1; t->a2 = A2;
    s.reset(3);

    int16_t gx1 = 0, gx2 = 0, gy1 = 0, gy2 = 0;
    int n = 0;

    auto push_both = [&](int16_t xv) {
        int64_t gacc = int64_t(B0) * xv + int64_t(B1) * gx1 + int64_t(B2) * gx2
                       - int64_t(A1) * gy1 - int64_t(A2) * gy2;
        int16_t gy = q15_bits_30_15(gacc);

        t->xp = xv;
        t->in_p = 1;
        t->in_f = 0;
        s.tick();
        if (!t->ov_p || s16(t->yp) != gy) fail("par mismatch");
        t->in_p = 0;
        s.tick();

        t->xf = xv;
        t->in_f = 1;
        s.tick();
        t->in_f = 0;
        bool got = false;
        for (int k = 0; k < 8; k++) {
            s.tick();
            if (t->ov_f) {
                if (s16(t->yf) != gy) fail("fold mismatch");
                n++;
                got = true;
                break;
            }
        }
        if (!got) fail("fold timeout");
        gx2 = gx1; gx1 = xv; gy2 = gy1; gy1 = gy;
    };

    push_both(0);
    push_both(1000);
    push_both(2000);
    push_both(-1500);
    push_both(500);
    for (int k = 0; k < 8; k++) push_both(static_cast<int16_t>((k - 4) * 400));
    std::printf("PASS biquad-fold parallel vs N=5 folded n=%d\n", n);
    std::printf("METRIC FOLDING_FACTOR=5 SAME_BITEXACT=1\n");
    return 0;
}
