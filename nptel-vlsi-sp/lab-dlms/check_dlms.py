#!/usr/bin/env python3
MUSHIFT = 6

def sat16(v):
    return max(-32768, min(32767, int(v)))

def lms(N=400):
    w = 0
    for k in range(N):
        x = ((k * 5) % 17) - 8
        d = 3 * x
        y = sat16(x * w)
        e = sat16(d - y)
        w = sat16(w + ((e * x) >> MUSHIFT))
    return w

def dlms(N=400):
    w = e_d = x_d = 0
    for k in range(N):
        x = ((k * 5) % 17) - 8
        d = 3 * x
        y = sat16(x * w)
        e = sat16(d - y)
        w = sat16(w + ((e_d * x_d) >> MUSHIFT))
        e_d, x_d = e, x
    return w

def main():
    w0, d0 = lms(), dlms()
    assert 2 <= w0 <= 4, w0
    assert 2 <= d0 <= 4, d0
    print("PASS check_dlms.py LMS_w0=%d DLMS_w0=%d" % (w0, d0))

if __name__ == "__main__":
    main()
