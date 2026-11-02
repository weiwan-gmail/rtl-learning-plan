#!/usr/bin/env python3
B0, B1, A1, SHIFT = 1, 1, 1, 1

def sat16(v):
    return max(-32768, min(32767, int(v)))

def run(xs):
    x1 = y1 = 0
    ys = []
    for x in xs:
        y = sat16((x * B0 + x1 * B1 + y1 * A1) >> SHIFT)
        ys.append(y)
        x1, y1 = x, y
    return ys

def main():
    xs = [0, 1000, 1000, 1000, -500, 0, 0]
    for k in range(40):
        v = (k * 37) & 0xFFFF
        xs.append(v - 0x10000 if v >= 0x8000 else v)
    xs += [2000] + [0] * 10
    ys = run(xs)
    assert ys[1] == 500
    assert ys[2] == 1250, ys[2]
    print("first ys", ys[:6])
    print("PASS check_iir1.py")

if __name__ == "__main__":
    main()
