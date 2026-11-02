#!/usr/bin/env python3
WSHIFT, MUSHIFT = 0, 5

def sat16(v):
    return max(-32768, min(32767, int(v)))

def run(N=256):
    x0 = w0 = w1 = px = 0
    for k in range(N):
        x = ((k * 5) % 17) - 8
        d = sat16(2 * x + 1 * px)
        y = sat16((x * w0 + x0 * w1) >> WSHIFT)
        e = sat16(d - y)
        w0 = sat16(w0 + ((e * x) >> MUSHIFT))
        w1 = sat16(w1 + ((e * x0) >> MUSHIFT))
        x0 = x
        px = x
    return w0, w1

def main():
    w0, w1 = run()
    print(f"final w0={w0} w1={w1}")
    assert 1 <= w0 <= 3 and 0 <= w1 <= 2, (w0, w1)
    print("PASS check_lms2.py")

if __name__ == "__main__":
    main()
