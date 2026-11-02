#!/usr/bin/env python3
H = [1, 2, 2, 1]

def da_lut(addr):
    s = 0
    for i, h in enumerate(H):
        if (addr >> (3 - i)) & 1:
            s += h
    return s

def da_signed(xs):
    """xs: 4 signed ints in [-128,127], newest first x0..x3"""
    # pack as 8-bit two's complement
    bits = []
    for b in range(8):
        addr = 0
        for i, x in enumerate(xs):
            xb = x & 0xFF
            if (xb >> b) & 1:
                addr |= 1 << (3 - i)
        bits.append(da_lut(addr))
    acc = 0
    for b in range(7):
        acc += bits[b] << b
    acc -= bits[7] << 7
    return acc

def main():
    taps = [0, 0, 0, 0]
    for s in [0, 1, -1, 2, -2, 10, -10, 127, -128, 50]:
        taps = [s] + taps[:3]
        y_da = da_signed(taps)
        y_ref = sum(h * x for h, x in zip(H, taps))
        assert y_da == y_ref, (s, taps, y_da, y_ref)
    print("PASS check_da_fir_signed.py")

if __name__ == "__main__":
    main()
