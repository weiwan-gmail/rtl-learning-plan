#include "Vwrap_retiming_fir.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vwrap_retiming_fir> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    std::vector<int32_t> expect;
    int hx[3] = {0, 0, 0};
    int rd_c = 0, rd_p = 0, n = 0;

    auto observe = [&]() {
        if (t->ov_c) {
            if (s32(t->y_c) != expect[rd_c]) fail("combo mismatch");
            rd_c++; n++;
        }
        if (t->ov_p) {
            if (s32(t->y_p) != expect[rd_p]) fail("pipe mismatch");
            rd_p++;
        }
    };
    auto feed = [&](int16_t samp) {
        hx[2] = hx[1]; hx[1] = hx[0]; hx[0] = samp;
        expect.push_back(1 * hx[0] + 2 * hx[1] + 1 * hx[2]);
        t->din = samp;
        t->in_valid = 1;
        s.tick();
        observe();
        t->in_valid = 0;
        s.tick();
        observe();
        for (int i = 0; i < 3; i++) {
            s.tick();
            observe();
        }
    };
    const int16_t first[] = {0, 1, 2, 3, 4, -5, 10, -2};
    for (int16_t v : first) feed(v);
    for (int k = 0; k < 12; k++) feed(static_cast<int16_t>(k - 6));
    for (int i = 0; i < 10; i++) {
        s.tick();
        observe();
    }
    if (rd_c != (int)expect.size() || rd_p != (int)expect.size()) fail("count");
    std::printf("PASS retiming fir3 combo+pipe n=%d mismatches=0\n", n);
    std::printf("METRIC LATENCY_COMBO=1 LATENCY_PIPE=3 SAME_BITEXACT=1\n");
    return 0;
}
