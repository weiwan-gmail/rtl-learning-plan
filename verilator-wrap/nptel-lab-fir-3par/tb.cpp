#include "Vwrap_fir_3par.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_fir_3par> s;
    auto* t = s.top;
    t->in_p = 0;
    t->x0 = t->x1 = t->x2 = 0;
    s.reset(3);

    int n = 0;
    int16_t seq[30];
    for (int i = 0; i < 30; i++) seq[i] = static_cast<int16_t>(i - 15);
    int gx[3] = {0, 0, 0};
    for (int i = 0; i < 30; i += 3) {
        t->x0 = seq[i];
        t->x1 = seq[i + 1];
        t->x2 = seq[i + 2];
        t->in_p = 1;
        s.tick();
        if (!t->ov_p) fail("3par silent");
        gx[2] = gx[1]; gx[1] = gx[0]; gx[0] = seq[i];
        int32_t e0 = 1 * gx[0] + 2 * gx[1] + 1 * gx[2];
        gx[2] = gx[1]; gx[1] = gx[0]; gx[0] = seq[i + 1];
        int32_t e1 = 1 * gx[0] + 2 * gx[1] + 1 * gx[2];
        gx[2] = gx[1]; gx[1] = gx[0]; gx[0] = seq[i + 2];
        int32_t e2 = 1 * gx[0] + 2 * gx[1] + 1 * gx[2];
        if (s32(t->y0) != e0 || s32(t->y1) != e1 || s32(t->y2) != e2) fail("3par mismatch");
        n += 3;
        t->in_p = 0;
        s.tick();
    }
    std::printf("PASS fir-3par vs serial golden n=%d mismatches=0\n", n);
    std::printf("METRIC PARALLEL=3 SAME_BITEXACT=1\n");
    return 0;
}
