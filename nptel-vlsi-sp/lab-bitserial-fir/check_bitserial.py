#!/usr/bin/env python3
def fir(xs):
    xp, ys = 0, []
    for x in xs:
        ys.append(-3 * x + 3 * xp)
        xp = x
    return ys

def main():
    xs = [0, 1, 2, -3, 4, -5, 6, -1, 3, -4, 7, -2]
    ys = fir(xs)
    assert ys[0] == 0
    assert ys[1] == -3   # -3*1 + 3*0
    assert ys[11] == 27  # -3*(-2) + 3*7
    print("PASS check_bitserial.py")

if __name__ == "__main__":
    main()
