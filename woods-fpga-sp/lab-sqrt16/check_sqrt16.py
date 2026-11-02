#!/usr/bin/env python3
def sqrt16(n):
    rad, q, r = n & 0xFFFF, 0, 0
    for _ in range(8):
        bits = (rad >> 14) & 3
        acc = (r << 2) | bits
        sub = (q << 2) | 1
        if acc >= sub:
            r, q = acc - sub, (q << 1) | 1
        else:
            r, q = acc, (q << 1)
        rad = (rad << 2) & 0xFFFF
    return q, r

def main():
    for n in list(range(0, 300, 7)) + [65535, 65025, 1000]:
        q, r = sqrt16(n)
        assert q == int(n ** 0.5) and q * q + r == n, (n, q, r)
    print("PASS check_sqrt16.py")

if __name__ == "__main__":
    main()
