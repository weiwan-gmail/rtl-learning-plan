#include "Vwrap_p3_fir_nco.h"
#include "tb_util.hpp"
#include <vector>

static int16_t fir_mac(int16_t a0, int16_t a1, int16_t a2, int16_t a3) {
    int64_t acc = int64_t(a0) * 1 + int64_t(a1) * 2 + int64_t(a2) * 2 + int64_t(a3) * 1;
    return sat16(acc);
}

int main() {
    Sim<Vwrap_p3_fir_nco> s;
    auto* t = s.top;
    t->fir_in_valid = 0;
    t->nco_in_valid = 0;
    t->fir_din = 0;
    t->freq_word = 0;
    s.reset(4);

    std::vector<int16_t> eq;
    int16_t gx0 = 0, gx1 = 0, gx2 = 0;
    int n_fir = 0, rd = 0;

    auto observe_fir = [&]() {
        if (t->fir_out_valid) {
            if (s16(t->fir_dout) != eq[rd]) fail("fir4");
            n_fir++;
            rd++;
        }
    };
    auto apply = [&](int16_t samp) {
        int16_t y = fir_mac(samp, gx0, gx1, gx2);
        gx2 = gx1; gx1 = gx0; gx0 = samp;
        eq.push_back(y);
        t->fir_din = samp;
        t->fir_in_valid = 1;
        s.tick();
        observe_fir();
    };
    auto idle = [&](int n) {
        for (int i = 0; i < n; i++) {
            t->fir_in_valid = 0;
            t->fir_din = 0;
            s.tick();
            observe_fir();
        }
    };

    apply(1000); idle(1); apply(0); apply(0); apply(0); apply(0); idle(3);
    for (int i = 0; i < 8; i++) apply(500);
    idle(3);
    for (int i = 0; i < 16; i++) apply(i & 1 ? -2000 : 2000);
    idle(3);
    apply(111); idle(3); apply(222); idle(1); apply(-333); idle(3);
    Rng rng(0xF1840001u);
    for (int i = 0; i < 64; i++) {
        if ((rng.next() & 7) == 0) idle(1 + (rng.next() & 3));
        apply(rng.s16rand());
    }
    idle(5);
    apply(32767); apply(32767); apply(32767); apply(32767);
    apply(-32768); apply(-32768); apply(-32768); apply(-32768);
    idle(5);
    if (rd != (int)eq.size()) fail("fir leftover");
    std::printf("PASS fir4 checked=%d\n", n_fir);

    // NCO: reset DUT nco via full rst
    t->rst = 1;
    t->nco_in_valid = 0;
    t->fir_in_valid = 0;
    for (int i = 0; i < 3; i++) s.tick();
    t->rst = 0;
    s.tick();

    uint32_t gphase = 0;
    int n_nco = 0;
    auto step_nco = [&](uint32_t fw) {
        t->freq_word = fw;
        t->nco_in_valid = 1;
        uint32_t nxt = gphase + fw;
        gphase = nxt;
        int16_t exp = static_cast<int16_t>(nxt >> 16);
        s.tick();
        if (!t->nco_out_valid || s16(t->nco_dout) != exp) fail("nco");
        n_nco++;
    };
    auto idle_nco = [&](int n) {
        for (int i = 0; i < n; i++) {
            t->nco_in_valid = 0;
            s.tick();
        }
    };
    for (int i = 0; i < 64; i++) step_nco(0x10000000u);
    idle_nco(3);
    Rng nr(0xC0000001u);
    for (int i = 0; i < 64; i++) {
        if ((nr.next() & 5) == 0) idle_nco(1 + (nr.next() & 2));
        step_nco(nr.next());
    }
    idle_nco(4);
    std::printf("PASS nco checked=%d\n", n_nco);
    std::printf("PASS p3-fir-nco fir+nco bit-exact\n");
    return 0;
}
