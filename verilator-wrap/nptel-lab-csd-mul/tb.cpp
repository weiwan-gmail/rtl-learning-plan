#include "Vcsd_mul.h"
#include "tb_util.hpp"

int main() {
    Sim<Vcsd_mul> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->x = 0;
    t->sel_m19 = 0;
    s.reset(3);
    int n = 0;

    auto check = [&](int16_t xv, int sel19) {
        int64_t e = sel19 ? int64_t(-19) * xv : int64_t(29) * xv;
        t->x = xv;
        t->sel_m19 = sel19;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid || s32(t->y) != static_cast<int32_t>(e)) fail("csd_mul");
        n++;
        t->in_valid = 0;
        s.tick();
    };
    for (int k = -20; k <= 20; k++) {
        check(static_cast<int16_t>(k), 0);
        check(static_cast<int16_t>(k), 1);
    }
    check(1000, 0);
    check(-1000, 1);
    std::printf("PASS csd-mul *29 and *-19 n=%d\n", n);
    std::printf("METRIC CSD_29=100T01 CSD_M19=T0T01\n");
    return 0;
}
