#include "Vda_fir4_signed.h"
#include "tb_util.hpp"
#include <vector>

static int sx8(int v) {
    v &= 255;
    return v >= 128 ? v - 256 : v;
}

int main() {
    Sim<Vda_fir4_signed> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    int hx[4] = {0, 0, 0, 0};
    int n_checked = 0;
    std::vector<int> seq = {0, 1, -1, 2, -2, 10, -10, 127, -128, 50};
    for (int k = 0; k < 16; k++) seq.push_back(k * 17 - 80);

    for (int samp : seq) {
        int ss = sx8(samp);
        hx[3] = hx[2];
        hx[2] = hx[1];
        hx[1] = hx[0];
        hx[0] = ss;
        int y = 1 * hx[0] + 2 * hx[1] + 2 * hx[2] + 1 * hx[3];
        t->din = static_cast<int16_t>(ss);
        t->in_valid = 1;
        s.tick();
        t->in_valid = 0;
        bool got = false;
        for (int k = 0; k < 16; k++) {
            s.tick();
            if (t->out_valid) {
                if (s16(t->dout) != y) fail("da_fir4_signed mismatch");
                n_checked++;
                got = true;
                break;
            }
        }
        if (!got) fail("da_fir4_signed timeout");
    }
    if (n_checked == 0) fail("no samples");
    std::printf("PASS da_fir4_signed n=%d mismatches=0\n", n_checked);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
