#!/usr/bin/env python3
H = [1, 2, 1]

def serial(xs):
    x = [0, 0]
    ys = []
    for s in xs:
        ys.append(H[0]*s + H[1]*x[0] + H[2]*x[1])
        x = [s, x[0]]
    return ys

def par3(xs):
    x1d = x2d = 0
    out = []
    for k in range(0, len(xs), 3):
        x0, x1, x2 = xs[k], xs[k+1], xs[k+2]
        y0 = H[0]*x0 + H[1]*x2d + H[2]*x1d
        y1 = H[0]*x1 + H[1]*x0  + H[2]*x2d
        y2 = H[0]*x2 + H[1]*x1  + H[2]*x0
        out.extend([y0, y1, y2])
        x1d, x2d = x1, x2
    return out

def main():
    xs = list(range(-15, 15))
    assert serial(xs) == par3(xs)
    print("PASS check_fir_3par.py")

if __name__ == "__main__":
    main()
