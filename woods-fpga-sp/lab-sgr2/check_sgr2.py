#!/usr/bin/env python3
def sgr(a, b, x, y):
    return a * x + b * y, -b * x + a * y, a * a + b * b

def main():
    x, y, r2 = sgr(3, 4, 3, 4)
    assert (x, y, r2) == (25, 0, 25)
    x, y, r2 = sgr(5, 12, 5, 12)
    assert (x, y, r2) == (169, 0, 169)
    x, y, _ = sgr(3, 4, 1, 2)
    assert (x, y) == (11, 2)
    print("PASS check_sgr2.py")

if __name__ == "__main__":
    main()
