#include "Vdivu16_nr.h"
#include "tb_util.hpp"

int main() {
    Sim<Vdivu16_nr> s;
    auto* t = s.top;
    t->start = 0;
    t->numer = 0;
    t->denom = 1;
    s.reset(3);

    int n = 0;

    auto wait_done = [&]() {
        for (int k = 0; k < 32; k++) {
            if (t->done) return;
            s.tick();
        }
        fail("div timeout");
    };

    auto run_div = [&](uint16_t nn, uint16_t dd) {
        uint16_t eq = static_cast<uint16_t>(nn / dd);
        uint16_t er = static_cast<uint16_t>(nn % dd);
        t->numer = nn;
        t->denom = dd;
        t->start = 1;
        s.tick();
        t->start = 0;
        wait_done();
        if (t->div_by_zero || (uint16_t)t->quot != eq || (uint16_t)t->rem != er)
            fail("div");
        n++;
        s.tick();
    };

    t->numer = 42;
    t->denom = 0;
    t->start = 1;
    s.tick();
    t->start = 0;
    if (!t->done || !t->div_by_zero || (uint16_t)t->quot != 0xFFFFu ||
        (uint16_t)t->rem != 42)
        fail("dz");
    n++;
    s.tick();

    run_div(0, 1);
    run_div(1, 1);
    run_div(100, 7);
    run_div(65535, 255);
    run_div(65535, 1);
    run_div(256, 16);
    run_div(12345, 678);
    for (int a = 1; a < 40; a++)
        for (int b = 1; b < 20; b++)
            run_div(static_cast<uint16_t>((a * 97 + b) & 0xFFFF),
                    static_cast<uint16_t>(b));

    std::printf("PASS divu16_restoring n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
