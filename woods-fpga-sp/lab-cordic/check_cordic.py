#!/usr/bin/env python3
"""Golden model for cordic_rotate / cordic_vector."""
import math

ATAN_Q13 = [int(round(math.atan(2 ** (-i)) * 8192)) for i in range(16)]


def _wrap16(v):
    return ((v + 0x8000) & 0xFFFF) - 0x8000


def cordic_rotate(x, y, z, niter=16):
    x, y, z = int(x), int(y), int(z)
    for i in range(niter):
        xs, ys, at = x >> i, y >> i, ATAN_Q13[i]
        if z < 0:
            x, y, z = x + ys, y - xs, z + at
        else:
            x, y, z = x - ys, y + xs, z - at
        x, y, z = _wrap16(x), _wrap16(y), _wrap16(z)
    return x, y, z


def cordic_vector(x, y, z, niter=16):
    x, y, z = int(x), int(y), int(z)
    for i in range(niter):
        xs, ys, at = x >> i, y >> i, ATAN_Q13[i]
        if y < 0:
            x, y, z = x - ys, y + xs, z - at
        else:
            x, y, z = x + ys, y - xs, z + at
        x, y, z = _wrap16(x), _wrap16(y), _wrap16(z)
    return x, y, z


def main():
    print("ATAN_Q13 =", ATAN_Q13)
    vecs = [
        (9949, 0, 0), (9949, 0, 6434), (9949, 0, -6434), (9949, 0, 3217),
        (4000, 3000, 1000), (-2000, 1500, -2000), (100, 0, 100), (8000, -1000, 500),
    ]
    for v in vecs:
        print("rot", v, "->", cordic_rotate(*v))
    x, y, z = cordic_rotate(9949, 0, 0)
    assert abs(x - 16384) <= 4 and abs(y) <= 8, (x, y, z)
    xv, yv, zv = cordic_vector(8000, 8000, 0)
    print("vec (8000,8000,0) ->", (xv, yv, zv))
    assert abs(yv) <= 20 and abs(zv - 6434) <= 8, (xv, yv, zv)
    print("PASS check_cordic.py")


if __name__ == "__main__":
    main()
