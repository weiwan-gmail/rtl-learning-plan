#!/usr/bin/env python3
def apply(c, s, x, y):
    # QR nulling: [c s; -s c]
    xn = (c * x + s * y) >> 15
    yn = (-s * x + c * y) >> 15
    return xn, yn

def main():
    xr, yr = apply(32767, 0, 1000, 2000)
    assert xr == (32767 * 1000) >> 15
    assert yr == (32767 * 2000) >> 15
    c, s = 19661, 26214  # 3/5, 4/5 in Q15
    xr, yr = apply(c, s, 3000, 4000)
    print("null", xr, yr)
    assert abs(yr) <= 5, (xr, yr)
    assert abs(xr - 5000) <= 5, (xr, yr)
    print("PASS check_givens2.py")

if __name__ == "__main__":
    main()
