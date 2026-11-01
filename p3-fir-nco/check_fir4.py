#!/usr/bin/env python3
"""NumPy golden for fir4: same coeffs/SHIFT/sat as RTL. Prints RMSE/SNR."""
from __future__ import annotations

import sys

import numpy as np

H = np.array([1, 2, 2, 1], dtype=np.int64)
SHIFT = 0


def sat16(x: np.ndarray) -> np.ndarray:
    return np.clip(x, -32768, 32767).astype(np.int64)


def fir4_gold(x: np.ndarray) -> np.ndarray:
    """Streamed FIR with zero-initialized taps; one output per input."""
    taps = np.zeros(4, dtype=np.int64)
    y = np.empty(len(x), dtype=np.int64)
    for i, s in enumerate(x.astype(np.int64)):
        taps = np.concatenate(([s], taps[:3]))
        acc = int(np.dot(taps, H))
        y[i] = sat16(np.array([acc >> SHIFT]))[0]
    return y


def main() -> int:
    rng = np.random.default_rng(0xF1840001)
    # directed
    impulse = np.array([1000, 0, 0, 0, 0], dtype=np.int64)
    y_i = fir4_gold(impulse)
    expect_i = sat16(np.array([1000 * 1, 1000 * 2, 1000 * 2, 1000 * 1, 0]))
    # impulse into zero taps: y0=H0*1000, y1=H1*1000, ...
    if not np.array_equal(y_i, expect_i):
        print("FAIL impulse", y_i, expect_i)
        return 1
    print(f"PASS numpy impulse y={y_i.tolist()}")

    x = rng.integers(-32768, 32768, size=512, dtype=np.int64)
    # also force sat corners
    x = np.concatenate([x, np.full(4, 32767), np.full(4, -32768)])
    y = fir4_gold(x)
    # second model: convolution with same initial zeros, then sat
    # np.convolve is full; take causal length-len(x) with zero pre-pad
    padded = np.concatenate([np.zeros(3, dtype=np.int64), x])
    y2 = np.array(
        [sat16(np.array([int(np.dot(padded[i : i + 4][::-1], H)) >> SHIFT]))[0]
         for i in range(len(x))],
        dtype=np.int64,
    )
    # taps order: [newest..oldest] dot [H0..H3]
    # padded[i:i+4] is [x[i-3],x[i-2],x[i-1],x[i]] oldest..newest → reverse
    if not np.array_equal(y, y2):
        mism = np.where(y != y2)[0][:5]
        print("FAIL dual-model mismatch at", mism, y[mism], y2[mism])
        return 1

    err = (y - y2).astype(np.float64)
    rmse = float(np.sqrt(np.mean(err ** 2)))
    ref = y2.astype(np.float64)
    snr = float("inf") if rmse == 0.0 else 10.0 * np.log10(np.sum(ref ** 2) / np.sum(err ** 2))
    print(f"METRIC bit-exact=YES checked={len(y)} RMSE={rmse} SNR_dB={snr}")
    print("PASS check_fir4.py")
    return 0


if __name__ == "__main__":
    sys.exit(main())
