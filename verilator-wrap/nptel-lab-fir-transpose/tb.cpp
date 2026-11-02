#include "Vwrap_fir_transpose.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vwrap_fir_transpose> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    std::vector<int32_t> expect;
    int hx[4] = {0, 0, 0, 0};
    int n = 0, rd_d = 0, rd_t = 0;

    auto feed = [&](int16_t samp) {
        hx[3] = hx[2]; hx[2] = hx[1]; hx[1] = hx[0]; hx[0] = samp;
        expect.push_back(1 * hx[0] + 2 * hx[1] + 2 * hx[2] + 1 * hx[3]);
        t->din = samp;
        t->in_valid = 1;
        s.tick();
        if (t->ov_d) {
            if (s32(t->y_d) != expect[rd_d]) fail("direct mismatch");
            rd_d++; n++;
        }
        if (t->ov_t) {
            if (s32(t->y_t) != expect[rd_t]) fail("transpose mismatch");
            rd_t++;
        }
        t->in_valid = 0;
        s.tick();
    };

    const int16_t seq[] = {0, 1, 2, 3, 4, -5, 10, -2};
    for (int16_t v : seq) feed(v);
    for (int k = 0; k < 16; k++) feed(static_cast<int16_t>(k - 8));
    for (int i = 0; i < 4; i++) {
        s.tick();
        if (t->ov_d) {
            if (s32(t->y_d) != expect[rd_d]) fail("direct drain");
            rd_d++; n++;
        }
        if (t->ov_t) {
            if (s32(t->y_t) != expect[rd_t]) fail("transpose drain");
            rd_t++;
        }
    }
    if (rd_d != (int)expect.size() || rd_t != (int)expect.size()) fail("count");
    std::printf("PASS fir-transpose direct+transposed n=%d mismatches=0\n", n);
    std::printf("METRIC SAME_BITEXACT=1 LINEAR_PHASE_H=1,2,2,1\n");
    return 0;
}
