#include "Vrns35.h"
#include "tb_util.hpp"

int main() {
    Sim<Vrns35> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->op = 0;
    t->bin_a = 0;
    t->bin_b = 0;
    t->a5 = t->a7 = t->b5 = t->b7 = 0;
    s.reset(3);

    int n = 0;

    auto do_op = [&](int o, int ba, int xa5, int xa7, int xb5, int xb7) {
        t->op = o;
        t->bin_a = ba;
        t->bin_b = 0;
        t->a5 = xa5;
        t->a7 = xa7;
        t->b5 = xb5;
        t->b7 = xb7;
        t->in_valid = 1;
        s.tick();
        if (!t->out_valid) fail("rns nov");
        n++;
        t->in_valid = 0;
        s.tick();
    };

    for (int i = 0; i < 35; i++) {
        do_op(0, i, 0, 0, 0, 0);
        if ((int)t->r5 != (i % 5) || (int)t->r7 != (i % 7)) fail("enc");
        int sa5 = t->r5, sa7 = t->r7;
        do_op(3, 0, sa5, sa7, 0, 0);
        if ((int)t->bin_out != i) fail("crt");
    }

    for (int i = 0; i < 35; i += 3) {
        for (int j = 0; j < 35; j += 5) {
            do_op(0, i, 0, 0, 0, 0);
            int sa5 = t->r5, sa7 = t->r7;
            do_op(0, j, 0, 0, 0, 0);
            int sb5 = t->r5, sb7 = t->r7;
            do_op(1, 0, sa5, sa7, sb5, sb7);
            if ((int)t->r5 != ((i + j) % 5) || (int)t->r7 != ((i + j) % 7))
                fail("add");
            do_op(3, 0, t->r5, t->r7, 0, 0);
            if ((int)t->bin_out != ((i + j) % 35)) fail("addcrt");
            do_op(2, 0, sa5, sa7, sb5, sb7);
            if ((int)t->r5 != ((i * j) % 5) || (int)t->r7 != ((i * j) % 7))
                fail("mul");
            do_op(3, 0, t->r5, t->r7, 0, 0);
            if ((int)t->bin_out != ((i * j) % 35)) fail("mulcrt");
        }
    }

    std::printf("PASS rns35 n=%d mismatches=0\n", n);
    std::printf("METRIC RMSE=0 SNR_dB=999 M=35\n");
    return 0;
}
