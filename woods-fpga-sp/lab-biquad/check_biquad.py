#!/usr/bin/env python3
B0, B1, B2 = 8192, 8192, 8192
A1, A2 = -16384, 8192

def run(xs):
    x1=x2=y1=y2=0
    ys=[]
    for x in xs:
        acc = B0*x + B1*x1 + B2*x2 - A1*y1 - A2*y2
        # match Verilog signed [31:0] then [30:15]
        acc &= 0xFFFFFFFF
        if acc >= 0x80000000: acc -= 0x100000000
        y = (acc >> 15) & 0xFFFF
        if y >= 0x8000: y -= 0x10000
        # Use arithmetic >>> on Python int before wrap for golden of small inputs
        acc2 = B0*x + B1*x1 + B2*x2 - A1*y1 - A2*y2
        y = acc2 >> 15
        y = ((y + 0x8000) & 0xFFFF) - 0x8000
        ys.append(y)
        x2,x1,y2,y1 = x1,x,y1,y
    return ys

def main():
    xs = [0, 1000, 2000, 3000, -1000, 500]
    ys = run(xs)
    assert len(ys)==len(xs)
    # first sample: only b0*x >>>15
    assert ys[0] == (B0*0)>>15
    assert ys[1] == (B0*1000)>>15
    print("ys", ys)
    print("PASS check_biquad.py")

if __name__ == "__main__":
    main()
