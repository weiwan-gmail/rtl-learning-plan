#!/usr/bin/env python3
def restoring_div(numer, denom, bits=16):
    if denom == 0:
        return 0xFFFF, numer, True
    r = 0
    q = 0
    n = numer & ((1 << bits) - 1)
    d = denom & ((1 << bits) - 1)
    for i in range(bits - 1, -1, -1):
        r = ((r << 1) | ((n >> i) & 1)) & ((1 << (bits + 1)) - 1)
        if r >= d:
            r -= d
            q |= 1 << i
    return q & 0xFFFF, r & 0xFFFF, False

def main():
    for n, d in [(0,1),(1,1),(100,7),(65535,255),(256,16),(12345,678)]:
        q, r, dz = restoring_div(n, d)
        assert not dz and q == n // d and r == n % d, (n, d, q, r)
    print("PASS check_div.py")

if __name__ == "__main__":
    main()
