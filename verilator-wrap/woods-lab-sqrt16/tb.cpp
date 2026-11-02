#include "Vsqrt16.h"
#include "tb_util.hpp"

static void gold_sqrt(uint16_t x, uint8_t& rq, uint16_t& rr) {
    uint32_t rad = x, q = 0, r = 0;
    for (int i = 0; i < 8; i++) {
        uint32_t bits = (rad >> 14) & 3;
        uint32_t acc = (r << 2) | bits;
        uint32_t sub = (q << 2) | 1;
        if (acc >= sub) {
            r = acc - sub;
            q = (q << 1) | 1;
        } else {
            r = acc;
            q = q << 1;
        }
        rad = (rad << 2) & 0xFFFF;
    }
    rq = static_cast<uint8_t>(q);
    rr = static_cast<uint16_t>(r);
}

int main() {
    Sim<Vsqrt16> s;
    auto* t = s.top;
    t->start = 0;
    t->radicand = 0;
    s.reset(3);

    int n = 0;
    auto run_one = [&](uint16_t x) {
        uint8_t rq;
        uint16_t rr;
        gold_sqrt(x, rq, rr);
        t->radicand = x;
        t->start = 1;
        s.tick();
        t->start = 0;
        bool got = false;
        for (int k = 0; k < 16; k++) {
            s.tick();
            if (t->done) {
                if ((uint8_t)t->root != rq || (uint16_t)t->rem != rr) fail("sqrt");
                if ((uint32_t)t->root * t->root + (uint16_t)t->rem != x)
                    fail("sqrt ident");
                got = true;
                break;
            }
        }
        if (!got) fail("sqrt timeout");
        n++;
        s.tick();
    };

    const uint16_t first[] = {0, 1, 4, 9, 15, 16, 255, 256, 1000, 322, 65535, 65025};
    for (uint16_t x : first) run_one(x);
    for (int k = 0; k < 80; k++)
        run_one(static_cast<uint16_t>((k * 7919) & 0xFFFF));

    std::printf("PASS sqrt16 n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
