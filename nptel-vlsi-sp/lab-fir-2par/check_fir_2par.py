#!/usr/bin/env python3
H = [1, 2, 2, 1]

def serial(xs):
    x = [0, 0, 0]
    ys = []
    for s in xs:
        ys.append(H[0]*s + H[1]*x[0] + H[2]*x[1] + H[3]*x[2])
        x = [s, x[0], x[1]]
    return ys

def par2(xs):
    xe_d = xo_d = xo_d2 = 0
    ye, yo = [], []
    for k in range(0, len(xs), 2):
        xe, xo = xs[k], xs[k+1]
        ye.append(H[0]*xe + H[1]*xo_d + H[2]*xe_d + H[3]*xo_d2)
        yo.append(H[0]*xo + H[1]*xe   + H[2]*xo_d + H[3]*xe_d)
        xo_d2, xo_d, xe_d = xo_d, xo, xe
    return ye, yo

def main():
    xs = list(range(-16, 16))
    ys = serial(xs)
    ye, yo = par2(xs)
    inter = [v for p in zip(ye, yo) for v in p]
    assert inter == ys, list(zip(inter, ys))
    print("PASS check_fir_2par.py")

if __name__ == "__main__":
    main()
