#include "Vwrap_arith.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_arith> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->a = t->b = 0;
    t->cin = 0;
    t->ma = t->mb = 0;
    s.reset(3);
    int n = 0;
    Rng rng(0xA5A5u);

    auto check = [&](int16_t aa, int16_t bb, int cin0) {
        uint32_t wide = (uint16_t)aa + (uint16_t)bb + (uint32_t)cin0;
        uint16_t exp_sum = static_cast<uint16_t>(wide & 0xFFFF);
        int exp_cout = (wide >> 16) & 1;
        uint16_t exp_prod = static_cast<uint16_t>((aa & 0xFF) * (bb & 0xFF));
        t->a = aa;
        t->b = bb;
        t->cin = cin0;
        t->ma = aa & 0xFF;
        t->mb = bb & 0xFF;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || (uint16_t)t->sum != exp_sum || t->cout != exp_cout)
            fail("add");
        if (!t->mout_valid || (uint16_t)t->product != exp_prod) fail("mul");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    check(0, 0, 0);
    check(100, 200, 0);
    check(-50, 80, 0);
    check(static_cast<int16_t>(0xFFFF), 1, 0);
    check(0x7FFF, 1, 0);
    check(7, 9, 1);
    for (int k = 0; k < 40; k++)
        check(rng.s16rand(), rng.s16rand(), k & 1);
    std::printf("PASS cla_add16+array_mult8 n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
