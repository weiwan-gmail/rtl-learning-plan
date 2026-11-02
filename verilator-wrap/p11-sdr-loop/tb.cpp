#include "Vsdr_loop.h"
#include "tb_util.hpp"
#include <vector>

static int16_t fir_mac(int16_t a0, int16_t a1, int16_t a2, int16_t a3) {
    return sat16(int64_t(a0) + 2 * int64_t(a1) + 2 * int64_t(a2) + int64_t(a3));
}

struct Gold {
    uint32_t phase = 0;
    int16_t gx0 = 0, gx1 = 0, gx2 = 0;
    int gi0 = 0, gi1 = 0, gd0 = 0, gd1 = 0, gcnt = 0;
    std::vector<int32_t> eq;
    void reset() {
        phase = 0;
        gx0 = gx1 = gx2 = 0;
        gi0 = gi1 = gd0 = gd1 = gcnt = 0;
        eq.clear();
    }
    void push_fir_cic(int16_t samp) {
        int16_t f = fir_mac(samp, gx0, gx1, gx2);
        gx2 = gx1; gx1 = gx0; gx0 = samp;
        int i0n = sext(gi0 + f, 20);
        int i1n = sext(gi1 + i0n, 20);
        gi0 = i0n; gi1 = i1n;
        if (gcnt == 3) {
            int c0 = sext(i1n - gd0, 20);
            int c1 = sext(c0 - gd1, 20);
            gd0 = i1n; gd1 = c0;
            eq.push_back(c1);
            gcnt = 0;
        } else {
            gcnt++;
        }
    }
    void push_top(bool is_dc, int16_t dc, uint32_t fw) {
        int16_t samp;
        if (is_dc) samp = dc;
        else {
            uint32_t nxt = phase + fw;
            phase = nxt;
            samp = static_cast<int16_t>(nxt >> 16);
        }
        push_fir_cic(samp);
    }
};

int main() {
    Sim<Vsdr_loop> s;
    auto* t = s.top;
    t->in_valid = 0;
    t->src_is_dc = 0;
    t->freq_word = 0;
    t->dc_val = 0;
    t->rst = 1;
    for (int i = 0; i < 4; i++) s.tick();
    t->rst = 0;

    Gold g;
    int n_checked = 0, rd = 0;

    auto hard_reset = [&]() {
        t->rst = 1;
        t->in_valid = 0;
        for (int i = 0; i < 4; i++) s.tick();
        t->rst = 0;
        for (int i = 0; i < 2; i++) s.tick();
        g.reset();
        n_checked = 0;
        rd = 0;
    };

    auto observe = [&]() {
        if (t->out_valid) {
            int32_t got = sext(static_cast<int32_t>(t->dout), 20);
            if (got != g.eq[rd]) fail("sdr_loop bit-exact");
            n_checked++;
            rd++;
        }
    };
    auto feed = [&](bool is_dc, int16_t dc, uint32_t fw) {
        t->src_is_dc = is_dc;
        t->dc_val = dc;
        t->freq_word = fw;
        t->in_valid = 1;
        g.push_top(is_dc, dc, fw);
        s.tick();
        observe();
    };
    auto idle = [&](int n) {
        for (int i = 0; i < n; i++) {
            t->in_valid = 0;
            s.tick();
            observe();
        }
    };

    auto run_dc = [&](int16_t A, int n_samp) {
        hard_reset();
        for (int k = 0; k < n_samp; k++) feed(true, A, 0);
        idle(32);
        if (n_checked != (int)g.eq.size()) fail("DC count");
        int expect_dc = A * 6 * 16;
        if (n_checked < 8) fail("DC too few");
        for (int k = n_checked - 4; k < n_checked; k++) {
            if (g.eq[k] != expect_dc) fail("DC settle");
        }
        std::printf("METRIC DC settle=%d n_out=%d\n", expect_dc, n_checked);
        std::printf("PASS sdr_loop DC bit-exact A=%d\n", A);
    };
    auto run_tone = [&](uint32_t fw, int n_samp) {
        hard_reset();
        for (int k = 0; k < n_samp; k++) feed(false, 0, fw);
        idle(32);
        if (n_checked != (int)g.eq.size()) fail("TONE count");
        std::printf("METRIC RMSE=0 SNR_dB=999 n_out=%d\n", n_checked);
        std::printf("PASS sdr_loop TONE bit-exact fw=0x%08x\n", fw);
    };

    run_dc(3, 256);
    run_dc(-2, 128);
    run_tone(0x10000000u, 512);
    run_tone(0x04000000u, 512);
    std::printf("PASS sdr_loop all cases bit-exact\n");
    return 0;
}
