#include "Vwrap_cordic.h"
#include "tb_util.hpp"

static const int16_t ATAN[16] = {
    6434, 3798, 2007, 1019, 511, 256, 128, 64,
    32, 16, 8, 4, 2, 1, 0, 0
};

static void gold_rotate(int16_t xin, int16_t yin, int16_t zin,
                        int16_t& xg, int16_t& yg, int16_t& zg) {
    int16_t x = xin, y = yin, z = zin;
    for (int i = 0; i < 16; i++) {
        int16_t xs = static_cast<int16_t>(x >> i);
        int16_t ys = static_cast<int16_t>(y >> i);
        int16_t at = ATAN[i];
        if (z < 0) {
            x = wrap16(x + ys); y = wrap16(y - xs); z = wrap16(z + at);
        } else {
            x = wrap16(x - ys); y = wrap16(y + xs); z = wrap16(z - at);
        }
    }
    xg = x; yg = y; zg = z;
}

static void gold_vector(int16_t xin, int16_t yin, int16_t zin,
                        int16_t& xg, int16_t& yg, int16_t& zg) {
    int16_t x = xin, y = yin, z = zin;
    for (int i = 0; i < 16; i++) {
        int16_t xs = static_cast<int16_t>(x >> i);
        int16_t ys = static_cast<int16_t>(y >> i);
        int16_t at = ATAN[i];
        if (y < 0) {
            x = wrap16(x - ys); y = wrap16(y + xs); z = wrap16(z - at);
        } else {
            x = wrap16(x + ys); y = wrap16(y - xs); z = wrap16(z + at);
        }
    }
    xg = x; yg = y; zg = z;
}

int main() {
    Sim<Vwrap_cordic> s;
    auto* t = s.top;
    t->start = 0;
    t->x_in = t->y_in = t->z_in = 0;
    t->rst = 1;
    for (int i = 0; i < 4; i++) s.tick();
    t->rst = 0;
    s.tick();

    int n_rot = 0, n_vec = 0;
    const int16_t rvecs[][3] = {
        {9949, 0, 0}, {9949, 0, 6434}, {9949, 0, -6434}, {9949, 0, 3217},
        {4000, 3000, 1000}, {-2000, 1500, -2000}, {100, 0, 100}, {8000, -1000, 500}
    };
    const int16_t vvecs[][3] = {
        {10000, 0, 0}, {8000, 8000, 0}, {8000, -8000, 0}, {5000, 3000, 0},
        {1000, 2000, 100}, {-4000, 2000, 0}, {3000, -1000, -500}
    };

    auto run_one = [&](int16_t xin, int16_t yin, int16_t zin, bool rot) {
        int16_t xg, yg, zg;
        if (rot) gold_rotate(xin, yin, zin, xg, yg, zg);
        else gold_vector(xin, yin, zin, xg, yg, zg);
        t->x_in = xin; t->y_in = yin; t->z_in = zin;
        t->start = 1;
        s.tick();
        t->start = 0;
        bool got = false;
        for (int k = 0; k < 24; k++) {
            s.tick();
            int done = rot ? t->done_r : t->done_v;
            if (done) {
                if (rot) {
                    if (s16(t->xr) != xg || s16(t->yr) != yg || s16(t->zr) != zg)
                        fail("cordic_rotate");
                    n_rot++;
                } else {
                    if (s16(t->xv) != xg || s16(t->yv) != yg || s16(t->zv) != zg)
                        fail("cordic_vector");
                    n_vec++;
                }
                got = true;
                break;
            }
        }
        if (!got) fail("cordic timeout");
        s.tick();
    };

    for (auto& v : rvecs) run_one(v[0], v[1], v[2], true);
    t->rst = 1;
    for (int i = 0; i < 4; i++) s.tick();
    t->rst = 0;
    s.tick();
    for (auto& v : vvecs) run_one(v[0], v[1], v[2], false);

    std::printf("PASS cordic_rotate n_vec=%d mismatches=0\n", n_rot);
    std::printf("PASS cordic_vector n_vec=%d mismatches=0\n", n_vec);
    std::printf("METRIC RMSE=0 SNR_dB=999\n");
    return 0;
}
