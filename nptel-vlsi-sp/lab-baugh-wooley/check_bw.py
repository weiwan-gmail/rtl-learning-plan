#!/usr/bin/env python3
"""Algebraic Baugh–Wooley 8×8 vs Python signed multiply."""


def s8(x):
    x &= 0xFF
    return x - 256 if x >= 128 else x


def s16(x):
    x &= 0xFFFF
    return x - 65536 if x >= 32768 else x


def baugh_wooley8(a, b):
    n = 8
    s = 0x8100  # +1 at bits n and 2n-1
    for i in range(n):
        for j in range(n):
            p = ((a >> i) & 1) & ((b >> j) & 1)
            if (i == n - 1) ^ (j == n - 1):
                p ^= 1
            s += p << (i + j)
    return s16(s)


def main():
    n = 0
    for a in range(256):
        for b in range(0, 256, 5):
            assert baugh_wooley8(a, b) == s8(a) * s8(b), (a, b)
            n += 1
    assert baugh_wooley8(0, 0) == 0
    assert baugh_wooley8(0xFF, 0xFF) == 1
    assert baugh_wooley8(0x80, 0x80) == 16384
    print(f"PASS check_bw.py n={n}")


if __name__ == "__main__":
    main()
