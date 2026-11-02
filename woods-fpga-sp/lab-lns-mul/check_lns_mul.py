#!/usr/bin/env python3
import math
LOG = [0] + [int(round(math.log2(i) * 256)) for i in range(1, 33)]
EXP = [int(round((2 ** (f/256.0)) * 256)) for f in range(256)]

def lns_mul(a, b):
    s = LOG[a] + LOG[b]
    ip, frac = (s >> 8) & 0xFF, s & 0xFF
    mant = EXP[frac]
    return (mant << ip) >> 8, s

def main():
    max_e = 0
    for a in range(1, 33):
        for b in range(1, 33):
            y, s = lns_mul(a, b)
            max_e = max(max_e, abs(y - a * b))
            assert y == lns_mul(a, b)[0]
    assert max_e <= 2, max_e
    print("PASS check_lns_mul.py max_abs_err=%d" % max_e)

if __name__ == "__main__":
    main()
