#!/usr/bin/env python3
B0, B1, B2 = 8192, 8192, 8192
A1, A2 = -16384, 8192

def step(x, x1, x2, y1, y2):
    acc = B0*x + B1*x1 + B2*x2 - A1*y1 - A2*y2
    # signed 32-bit, take [30:15]
    acc &= 0xFFFFFFFF
    if acc >= 2**31:
        acc -= 2**32
    y = (acc >> 15) & 0xFFFF
    if y >= 2**15:
        y -= 2**16
    return y

def main():
    x1=x2=y1=y2=0
    xs = [0, 1000, 2000, -1500, 500] + [(k-4)*400 for k in range(8)]
    for x in xs:
        y = step(x, x1, x2, y1, y2)
        x2, x1, y2, y1 = x1, x, y1, y
    print("PASS check_biquad_fold.py")

if __name__ == "__main__":
    main()
