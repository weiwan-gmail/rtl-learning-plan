#include "Vda_fir4.h"
#include "tb_util.hpp"
#include <vector>

int main() {
    Sim<Vda_fir4> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->din = 0;
    s.reset(3);

    int hx[4] = {0, 0, 0, 0};
    int n_checked = 0;
    int samples[] = {0, 1, 2, 3, 10, 255, 128};
    std::vector<int> seq(samples, samples + 7);
    for (int k = 0; k < 20; k++) seq.push_back((k * 13) & 255);

    for (int samp : seq) {
        hx[3] = hx[2]; hx[2] = hx[1]; hx[1] = hx[0]; hx[0] = samp;
        int y = 1 * hx[0] + 2 * hx[1] + 2 * hx[2] + 1 * hx[3];
        t->din = static_cast<int16_t>(samp);
        t->in_valid = 1;
        s.tick();
        t->in_valid = 0;
        bool got = false;
        for (int k = 0; k < 16; k++) {
            s.tick();
            if (t->out_valid) {
                if (s16(t->dout) != y) fail("da_fir4 mismatch");
                n_checked++;
                got = true;
                break;
            }
        }
        if (!got) fail("da_fir4 timeout");
    }
    if (n_checked == 0) fail("no samples");
    std::printf("PASS da_fir4 n_checked=%d mismatches=0\n", n_checked);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
