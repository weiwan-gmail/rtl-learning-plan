#include "Vbitserial_fir.h"
#include "tb_util.hpp"

int main() {
    Sim<Vbitserial_fir> s;
    auto* t = s.top;
    const int W = 8, NS = 12;
    int xs[NS] = {0, 1, 2, -3, 4, -5, 6, -1, 3, -4, 7, -2};
    int golds[NS];
    int xprev = 0;
    for (int i = 0; i < NS; i++) {
        golds[i] = -3 * xs[i] + 3 * xprev;
        xprev = xs[i];
    }

    t->word_start = 0;
    t->xbit = 0;
    s.reset(4);

    int wr = 0;
    auto observe = [&]() {
        if (t->y_word_valid) {
            if (s16(t->y_word) != golds[wr]) fail("bitserial y_word");
            wr++;
        }
    };

    for (int si = 0; si < NS; si++) {
        for (int b = 0; b < W; b++) {
            t->word_start = (b == 0);
            t->xbit = (xs[si] >> b) & 1;
            s.tick();
            observe();
        }
    }
    t->word_start = 0;
    t->xbit = 0;
    for (int i = 0; i < W + 8; i++) {
        s.tick();
        observe();
    }
    if (wr != NS) fail("word count");
    std::printf("PASS bitserial-fir y=-3x+3x_d n=%d\n", wr);
    std::printf("METRIC LSB_LATENCY=3 W=%d\n", W);
    return 0;
}
