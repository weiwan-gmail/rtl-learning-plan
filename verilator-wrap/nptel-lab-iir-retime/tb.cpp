#include "Vwrap_iir_retime.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vwrap_iir_retime> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    std::vector<int16_t> expect;
    int gx = 0, gy = 0, rd_c = 0, rd_p = 0, n = 0;

    auto observe = [&]() {
        if (t->ov_c) {
            if (s16(t->y_c) != expect[rd_c]) fail("combo mismatch");
            rd_c++; n++;
        }
        if (t->ov_p) {
            if (s16(t->y_p) != expect[rd_p]) fail("pipe mismatch");
            rd_p++;
        }
    };
    auto feed = [&](int16_t samp) {
        int64_t acc = int64_t(samp) * 1 + int64_t(gx) * 1 + int64_t(gy) * 1;
        int16_t yn = sat16(acc >> 1);
        expect.push_back(yn);
        gx = samp;
        gy = yn;
        t->din = samp;
        t->in_valid = 1;
        s.tick();
        observe();
        t->in_valid = 0;
        s.tick();
        observe();
        for (int i = 0; i < 4; i++) {
            s.tick();
            observe();
        }
    };

    const int16_t first[] = {0, 8, 16, -8, 4};
    for (int16_t v : first) feed(v);
    for (int k = 0; k < 12; k++) feed(static_cast<int16_t>(k - 6));
    for (int i = 0; i < 6; i++) {
        s.tick();
        observe();
    }
    if (rd_c != (int)expect.size() || rd_p != (int)expect.size()) fail("count");
    std::printf("PASS iir-retime combo+pipe n=%d mismatches=0\n", n);
    std::printf("METRIC LATENCY_COMBO=1 LATENCY_PIPE=2 SAME_BITEXACT=1\n");
    return 0;
}
