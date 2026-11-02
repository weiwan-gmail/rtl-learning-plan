#!/usr/bin/env python3
def sat16(v):
    return max(-32768, min(32767, int(v)))

def run(xs, B0=1, B1=1, A1=1, SHIFT=1):
    x1 = y1 = 0
    ys = []
    for s in xs:
        y = sat16((s*B0 + x1*B1 + y1*A1) >> SHIFT)
        ys.append(y)
        x1, y1 = s, y
    return ys

def main():
    xs = [0, 8, 16, -8, 4] + list(range(-6, 6))
    ys = run(xs)
    assert ys[0] == 0
    print("PASS check_iir_retime.py n=%d" % len(ys))

if __name__ == "__main__":
    main()
