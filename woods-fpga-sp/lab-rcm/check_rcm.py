#!/usr/bin/env python3
COEF = {0: 7, 1: 5, 2: 9, 3: 15, 4: 6}

def rcm(x, sel):
    x = int(x)
    if sel == 0: return (x << 3) - x
    if sel == 1: return (x << 2) + x
    if sel == 2: return (x << 3) + x
    if sel == 3: return (x << 4) - x
    if sel == 4: return (x << 2) + (x << 1)
    return 0

def main():
    for s, c in COEF.items():
        for x in [-20, -3, 0, 1, 7, 10, 100]:
            assert rcm(x, s) == x * c, (x, s)
    print("PASS check_rcm.py")

if __name__ == "__main__":
    main()
