#include "Vwrap_fir_2par.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_fir_2par> s;
    auto* t = s.top;
    t->in_s = 0;
    t->in_p = 0;
    t->din = 0;
    t->xe = 0;
    t->xo = 0;
    s.reset(3);

    int n = 0;
    int hx[4] = {0, 0, 0, 0};
    int16_t seq[32];
    for (int i = 0; i < 32; i++) seq[i] = static_cast<int16_t>(i - 16);

    for (int k = 0; k < 32; k++) {
        int16_t samp = seq[k];
        hx[3] = hx[2]; hx[2] = hx[1]; hx[1] = hx[0]; hx[0] = samp;
        int32_t exp = 1 * hx[0] + 2 * hx[1] + 2 * hx[2] + 1 * hx[3];
        t->din = samp;
        t->in_s = 1;
        t->in_p = 0;
        s.tick();
        if (!t->ov_s || s32(t->ys) != exp) fail("serial mismatch");
        n++;
        t->in_s = 0;
        s.tick();
    }

    t->rst = 1;
    s.tick();
    s.tick();
    t->rst = 0;
    s.tick();

    int gx[4] = {0, 0, 0, 0};
    for (int i = 0; i < 32; i += 2) {
        t->xe = seq[i];
        t->xo = seq[i + 1];
        t->in_p = 1;
        t->in_s = 0;
        s.tick();
        if (!t->ov_p) fail("2par no out");
        gx[3] = gx[2]; gx[2] = gx[1]; gx[1] = gx[0]; gx[0] = seq[i];
        int32_t ge = 1 * gx[0] + 2 * gx[1] + 2 * gx[2] + 1 * gx[3];
        gx[3] = gx[2]; gx[2] = gx[1]; gx[1] = gx[0]; gx[0] = seq[i + 1];
        int32_t go = 1 * gx[0] + 2 * gx[1] + 2 * gx[2] + 1 * gx[3];
        if (s32(t->ye) != ge || s32(t->yo) != go) fail("2par mismatch");
        t->in_p = 0;
        s.tick();
    }
    std::printf("PASS fir-2par serial vs even/odd polyphase bit-exact n_serial=%d\n", n);
    std::printf("METRIC PARALLEL=2 SAME_BITEXACT=1\n");
    return 0;
}
