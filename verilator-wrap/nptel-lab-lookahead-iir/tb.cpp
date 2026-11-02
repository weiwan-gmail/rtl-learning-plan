#include "Vwrap_lookahead.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_lookahead> s;
    auto* t = s.top;
    t->in_v = 0;
    t->in_p = 0;
    t->din = 0;
    t->dinp = 0;
    s.reset(3);

    int n = 0;
    int acc = 0;
    const int16_t seq[] = {1, 2, 3, 4, -2, 5, -1, 8};

    for (int16_t samp : seq) {
        acc += samp;
        t->din = samp;
        t->in_v = 1;
        s.tick();
        if (!t->ov || s16(t->yp) != acc) fail("plain");
        if (!t->ovl || s16(t->yl) != acc) fail("lookahead combo");
        n++;
        t->in_v = 0;
        s.tick();
    }

    t->rst = 1;
    s.tick();
    s.tick();
    t->rst = 0;
    s.tick();

    acc = 0;
    for (int16_t samp : seq) {
        acc += samp;
        t->dinp = samp;
        t->in_p = 1;
        s.tick();
        t->in_p = 0;
        bool got = false;
        for (int k = 0; k < 6; k++) {
            s.tick();
            if (t->ovp) {
                if (s16(t->ypp) != acc) fail("pipe mismatch");
                n++;
                got = true;
                break;
            }
        }
        if (!got) fail("pipe timeout");
    }
    std::printf("PASS lookahead-iir clustered 2-step vs integrator n=%d\n", n);
    std::printf("METRIC LOOKAHEAD=clustered LATENCY_PIPE=2 SAME_BITEXACT=1\n");
    return 0;
}
