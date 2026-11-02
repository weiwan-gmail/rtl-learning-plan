#!/usr/bin/env python3
"""Bit-exact golden for fft8.v — same Q15 twiddles and >>>1 butterflies."""
ONE_Q15 = 32767
COS_PI4 = 23170


def sext16(v):
    v &= 0xFFFF
    return v - 0x10000 if v >= 0x8000 else v


def mul_q15(a, b):
    return sext16((int(a) * int(b)) >> 15)


def bitrev3(a):
    return ((a & 1) << 2) | (a & 2) | ((a & 4) >> 2)


def twiddle(stage, bfly):
    if stage == 0:
        return ONE_Q15, 0
    if stage == 1:
        if (bfly & 1) == 0:
            return ONE_Q15, 0
        return 0, -ONE_Q15
    # stage 2
    return [
        (ONE_Q15, 0),
        (COS_PI4, -COS_PI4),
        (0, -ONE_Q15),
        (-COS_PI4, -COS_PI4),
    ][bfly]


def indices(stage, bfly):
    if stage == 0:
        return (bfly << 1), (bfly << 1) | 1
    if stage == 1:
        ia = ((bfly & 2) << 1) | (bfly & 1)  # {bfly[1],0,bfly[0]}
        # bfly[1] is bit1 of bfly
        ia = ((bfly >> 1) << 2) | (bfly & 1)
        ib = ia | 2
        return ia, ib
    return bfly, bfly + 4


def fft8(xr_in, xi_in):
    xr = [0] * 8
    xi = [0] * 8
    for n in range(8):
        xr[bitrev3(n)] = sext16(xr_in[n])
        xi[bitrev3(n)] = sext16(xi_in[n])
    for stage in range(3):
        for bfly in range(4):
            ia, ib = indices(stage, bfly)
            wr, wi = twiddle(stage, bfly)
            ar, ai = xr[ia], xi[ia]
            br, bi = xr[ib], xi[ib]
            pr = sext16(((br * wr) - (bi * wi)) >> 15)
            pi = sext16(((br * wi) + (bi * wr)) >> 15)
            s_r = ar + pr
            s_i = ai + pi
            d_r = ar - pr
            d_i = ai - pi
            # >>> 1 arithmetic
            xr[ia] = sext16(s_r >> 1)
            xi[ia] = sext16(s_i >> 1)
            xr[ib] = sext16(d_r >> 1)
            xi[ib] = sext16(d_i >> 1)
    return xr, xi


def main():
    # DC
    xr = [1000] * 8
    xi = [0] * 8
    Xr, Xi = fft8(xr, xi)
    print("DC", Xr, Xi)
    # expect bin0 ≈ 1000 (after /8): 1000*8/8=1000
    assert abs(Xr[0] - 1000) <= 4, Xr
    # impulse
    xr = [8000, 0, 0, 0, 0, 0, 0, 0]
    Xr, Xi = fft8(xr, xi)
    print("impulse", Xr, Xi)
    # tone k=1 rough
    import math
    xr = [int(round(4000 * math.cos(2 * math.pi * 1 * n / 8))) for n in range(8)]
    xi = [0] * 8
    Xr, Xi = fft8(xr, xi)
    print("tone1", list(zip(Xr, Xi)))
    print("PASS check_fft8.py")


if __name__ == "__main__":
    main()
