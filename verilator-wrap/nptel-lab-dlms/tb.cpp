#include "Vwrap_dlms.h"
#include "tb_util.hpp"

int main() {
    Sim<Vwrap_dlms> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->xin = 0;
    t->din = 0;
    s.reset(3);

    const int N = 400;
    for (int k = 0; k < N; k++) {
        int16_t x = static_cast<int16_t>(((k * 5) % 17) - 8);
        int16_t d = sat16(3 * x);
        t->xin = x;
        t->din = d;
        t->in_valid = 1;
        s.tick();
    }
    t->in_valid = 0;
    for (int i = 0; i < 4; i++) s.tick();

    int wL = s16(t->w0_l);
    int wD = s16(t->w0_d);
    std::printf("INFO LMS  w0=%d\n", wL);
    std::printf("INFO DLMS w0=%d\n", wD);
    if (wL < 2 || wL > 4) fail("LMS w0 not near 3");
    if (wD < 2 || wD > 4) fail("DLMS w0 not near 3");
    std::printf("PASS dlms LMS+DLMS plant d=3x  LMS_w0=%d DLMS_w0=%d\n", wL, wD);
    std::printf("METRIC DLMS_D=1 MUSHIFT=6 SAME_PLANT=1\n");
    return 0;
}
