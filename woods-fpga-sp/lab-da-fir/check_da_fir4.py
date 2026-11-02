#!/usr/bin/env python3
H = [1, 2, 2, 1]

def da_y(xs):
    """xs[0]=newest..xs[3]=oldest, unsigned 8-bit."""
    y = 0
    for b in range(8):
        addr_bits = [(xs[i] >> b) & 1 for i in range(4)]
        lut = sum(H[i] for i in range(4) if addr_bits[i])
        y += lut << b
    return y

def mac_y(xs):
    return sum(H[i] * xs[i] for i in range(4))

def main():
    xs = [0, 0, 0, 0]
    samples = [0, 1, 2, 3, 10, 255, 128] + [((k * 13) & 255) for k in range(20)]
    for s in samples:
        xs = [s] + xs[:3]
        assert da_y(xs) == mac_y(xs), (xs, da_y(xs), mac_y(xs))
    print("PASS check_da_fir4.py")

if __name__ == "__main__":
    main()
