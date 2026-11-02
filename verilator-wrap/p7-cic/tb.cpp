#include "Vcic_decim.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vcic_decim> s;
    auto* t = s.top;
    const int R = 4, OUT_W = 20;
    t->in_valid = 0;
    t->din = 0;
    t->rst = 1;
    for (int i = 0; i < 4; i++) s.tick();
    t->rst = 0;
    s.tick();

    int gi0 = 0, gi1 = 0, gd0 = 0, gd1 = 0, gcnt = 0;
    std::vector<int32_t> expect;
    int n_in = 0, n_checked = 0, rd = 0;

    auto gold_push = [&](int32_t samp) {
        int i0n = sext(gi0 + samp, OUT_W);
        int i1n = sext(gi1 + i0n, OUT_W);
        gi0 = i0n;
        gi1 = i1n;
        if (gcnt == R - 1) {
            int c0 = sext(i1n - gd0, OUT_W);
            int c1 = sext(c0 - gd1, OUT_W);
            gd0 = i1n;
            gd1 = c0;
            expect.push_back(c1);
            gcnt = 0;
        } else {
            gcnt++;
        }
    };
    auto observe = [&]() {
        if (t->out_valid) {
            int32_t got = sext(static_cast<int32_t>(t->dout), OUT_W);
            if (got != expect[rd]) fail("cic bit-exact");
            n_checked++;
            rd++;
        }
    };
    auto feed = [&](int16_t samp) {
        t->din = samp;
        t->in_valid = 1;
        gold_push(samp);
        n_in++;
        s.tick();
        observe();
    };
    auto idle = [&](int n) {
        for (int i = 0; i < n; i++) {
            t->in_valid = 0;
            t->din = 0;
            s.tick();
            observe();
        }
    };

    for (int i = 0; i < 64; i++) feed(static_cast<int16_t>(i));
    idle(4);
    for (int i = 0; i < 64; i++) feed(i & 1 ? -1 : 1);
    idle(4);
    Rng rng(0xC1C00001u);
    for (int i = 0; i < 256; i++) feed(rng.s16rand());
    idle(8);

    if (rd != (int)expect.size()) fail("cic pending");
    if (n_checked != (64 + 64 + 256) / R) fail("cic count");
    std::printf("PASS cic_decim bit-exact n_in=%d n_out=%d N=2 R=4 M=1\n", n_in, n_checked);
    return 0;
}
