#include "Vbaugh_wooley8.h"
#include "tb_util.hpp"

int main() {
    Sim<Vbaugh_wooley8> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->a = 0;
    t->b = 0;
    s.reset(3);
    int n = 0;

    auto check = [&](uint8_t aa, uint8_t bb) {
        int sa = static_cast<int8_t>(aa);
        int sb = static_cast<int8_t>(bb);
        int p = sa * sb;
        t->a = aa;
        t->b = bb;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s16(t->product) != static_cast<int16_t>(p)) fail("baugh-wooley");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    check(0x00, 0x00);
    check(0x01, 0x01);
    check(0xFF, 0xFF);
    check(0x80, 0x80);
    check(0x7F, 0x7F);
    check(0x80, 0x7F);
    check(0x7F, 0x80);
    for (int ia = 0; ia < 256; ia += 17)
        for (int ib = 0; ib < 256; ib += 13)
            check(static_cast<uint8_t>(ia), static_cast<uint8_t>(ib));
    std::printf("PASS baugh-wooley8 n=%d mismatches=0\n", n);
    std::printf("METRIC SIGNED_ARRAY=1\n");
    return 0;
}
