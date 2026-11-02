#!/usr/bin/env python3
H = [1, 2, 2, 1]

def direct(xs):
    x = [0, 0, 0]
    ys = []
    for s in xs:
        y = H[0]*s + H[1]*x[0] + H[2]*x[1] + H[3]*x[2]
        ys.append(y)
        x = [s, x[0], x[1]]
    return ys

def transpose(xs):
    r = [0, 0, 0]
    ys = []
    for s in xs:
        y = H[0]*s + r[0]
        ys.append(y)
        r = [H[1]*s + r[1], H[2]*s + r[2], H[3]*s]
    return ys

def main():
    xs = list(range(-8, 12))
    a, b = direct(xs), transpose(xs)
    assert a == b, list(zip(a, b))
    print("PASS check_fir_transpose.py")

if __name__ == "__main__":
    main()
