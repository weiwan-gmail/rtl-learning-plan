#!/usr/bin/env python3
"""Bit-exact golden for cic_decim (N=2,R=4,M=1) — sanity vs pure Python."""
from __future__ import annotations

N, R, M = 2, 4, 1
IN_W, OUT_W = 16, 20
MASK = (1 << OUT_W) - 1


def sext(v: int, w: int = OUT_W) -> int:
    v &= (1 << w) - 1
    if v & (1 << (w - 1)):
        v -= 1 << w
    return v


def cic_run(samples: list[int]) -> list[int]:
    i0 = i1 = 0
    d0 = d1 = 0
    cnt = 0
    outs: list[int] = []
    for s in samples:
        s = sext(s, IN_W)
        i0n = sext(i0 + s)
        i1n = sext(i1 + i0n)
        i0, i1 = i0n, i1n
        if cnt == R - 1:
            c0 = sext(i1n - d0)
            c1 = sext(c0 - d1)
            d0, d1 = i1n, c0
            outs.append(c1)
            cnt = 0
        else:
            cnt += 1
    return outs


def main() -> None:
    ramp = list(range(64))
    alt = [1 if (t % 2 == 0) else -1 for t in range(64)]
    # deterministic LCG matching rough TB coverage size
    seed = 0xC1C00001
    rnd = []
    for _ in range(256):
        seed = (seed * 1103515245 + 12345) & 0xFFFFFFFF
        # TB uses $random — we only check internal model consistency + gain
        x = seed & 0xFFFF
        if x >= 0x8000:
            x -= 0x10000
        rnd.append(x)

    for name, vec in (("ramp", ramp), ("alt", alt), ("rnd", rnd)):
        y = cic_run(vec)
        assert len(y) == len(vec) // R, (name, len(y), len(vec) // R)

    # DC gain check: constant A → after settle, out ≈ A * (R*M)^N
    A = 3
    settle = cic_run([A] * (R * 16))
    gain = (R * M) ** N
    # last few should equal A*gain (integrators/combs on DC)
    for v in settle[-4:]:
        assert v == A * gain, (v, A * gain)

    print(f"PASS check_cic.py bit-exact model N={N} R={R} M={M} gain={gain}")


if __name__ == "__main__":
    main()
