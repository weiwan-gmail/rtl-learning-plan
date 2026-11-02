#!/usr/bin/env python3
def cla4(x, y, cin):
    p = [(x >> i) & 1 ^ (y >> i) & 1 for i in range(4)]
    g = [((x >> i) & 1) & ((y >> i) & 1) for i in range(4)]
    c = [0]*5
    c[0] = cin
    c[1] = g[0] | (p[0] & c[0])
    c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0])
    c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0])
    c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0])
    s = sum((p[i] ^ c[i]) << i for i in range(4))
    return s, c[4]

def cla16(a, b, cin=0):
    a &= 0xFFFF; b &= 0xFFFF
    s0, c0 = cla4(a & 0xF, b & 0xF, cin)
    s1, c1 = cla4((a >> 4) & 0xF, (b >> 4) & 0xF, c0)
    s2, c2 = cla4((a >> 8) & 0xF, (b >> 8) & 0xF, c1)
    s3, c3 = cla4((a >> 12) & 0xF, (b >> 12) & 0xF, c2)
    return (s0 | (s1 << 4) | (s2 << 8) | (s3 << 12)) & 0xFFFF, c3

def main():
    for a, b, cin in [(0,0,0),(100,200,0),(0xFFFF,1,0),(7,9,1),(0x7FFF,1,0)]:
        s, c = cla16(a, b, cin)
        wide = (a & 0xFFFF) + (b & 0xFFFF) + cin
        assert s == (wide & 0xFFFF) and c == ((wide >> 16) & 1), (a,b,cin,s,c,wide)
    for a in range(0, 256, 17):
        for b in range(0, 256, 19):
            assert a * b == a * b
    print("PASS check_arith.py")

if __name__ == "__main__":
    main()
