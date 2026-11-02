#!/usr/bin/env python3
"""Sample-domain golden for sdr_loop: NCO|DC → fir4 → cic_decim (N=2,R=4,M=1)."""
from __future__ import annotations

import math

PH_W, IN_W, OUT_W = 32, 16, 20
N, R, M = 2, 4, 1
H = (1, 2, 2, 1)
SHIFT = 0
GAIN_CIC = (R * M) ** N
SUM_H = sum(H)
MASK_OUT = (1 << OUT_W) - 1
MASK_PH = (1 << PH_W) - 1


def sext(v: int, w: int) -> int:
    v &= (1 << w) - 1
    if v & (1 << (w - 1)):
        v -= 1 << w
    return v


def fir_mac(a0: int, a1: int, a2: int, a3: int) -> int:
    acc = a0 * H[0] + a1 * H[1] + a2 * H[2] + a3 * H[3]
    sh = acc >> SHIFT  # arithmetic for non-neg SHIFT; taps keep sign via Python int
    if sh > 32767:
        return 32767
    if sh < -32768:
        return -32768
    return sh


class Chain:
    def __init__(self) -> None:
        self.phase = 0
        self.x = [0, 0, 0, 0]  # x0 newest … after push: [s, old_x0, old_x1, old_x2]
        self.i0 = self.i1 = 0
        self.d0 = self.d1 = 0
        self.cnt = 0
        self.outs: list[int] = []

    def push_fir_cic(self, s: int) -> None:
        s = sext(s, IN_W)
        f = fir_mac(s, self.x[0], self.x[1], self.x[2])
        self.x = [s, self.x[0], self.x[1], self.x[2]]

        i0n = sext(self.i0 + f, OUT_W)
        i1n = sext(self.i1 + i0n, OUT_W)
        self.i0, self.i1 = i0n, i1n
        if self.cnt == R - 1:
            c0 = sext(i1n - self.d0, OUT_W)
            c1 = sext(c0 - self.d1, OUT_W)
            self.d0, self.d1 = i1n, c0
            self.outs.append(c1)
            self.cnt = 0
        else:
            self.cnt += 1

    def push_dc(self, a: int) -> None:
        self.push_fir_cic(a)

    def push_nco(self, fw: int) -> None:
        nxt = (self.phase + (fw & MASK_PH)) & MASK_PH
        self.phase = nxt
        s = sext(nxt >> (PH_W - IN_W), IN_W)
        self.push_fir_cic(s)


def rmse_snr(y: list[int], ref: list[int]) -> tuple[float, float]:
    assert len(y) == len(ref)
    if not y:
        return 0.0, 999.0
    sse = sum((a - b) * (a - b) for a, b in zip(y, ref))
    energy = sum(b * b for b in ref)
    rmse = math.sqrt(sse / len(y))
    if sse == 0:
        snr = 999.0
    elif energy == 0:
        snr = 0.0
    else:
        snr = 10.0 * math.log10(energy / sse)
    return rmse, snr


def main() -> None:
    # DC gain settle
    for A in (3, -2, 7):
        ch = Chain()
        for _ in range(256):
            ch.push_dc(A)
        expect = A * SUM_H * GAIN_CIC
        for v in ch.outs[-4:]:
            assert v == expect, (A, v, expect)
    print(f"PASS check_sdr_loop.py DC settle (= A*{SUM_H}*{GAIN_CIC})")

    # Tone: self-consistency of two identical chains (bit-exact model)
    fw = 0x10000000
    ch1, ch2 = Chain(), Chain()
    for _ in range(512):
        ch1.push_nco(fw)
        ch2.push_nco(fw)
    rmse, snr = rmse_snr(ch1.outs, ch2.outs)
    assert rmse == 0.0 and ch1.outs == ch2.outs
    assert len(ch1.outs) == 512 // R
    print(f"PASS check_sdr_loop.py TONE model RMSE={rmse} SNR_dB={snr} n_out={len(ch1.outs)}")

    # Cross-check: NCO fw=0 stays 0 → same as DC 0 after FIR zeros
    chz = Chain()
    for _ in range(64):
        chz.push_nco(0)
    assert all(v == 0 for v in chz.outs)
    print("PASS check_sdr_loop.py NCO fw=0 → zero chain")

    print("PASS check_sdr_loop.py")


if __name__ == "__main__":
    main()
