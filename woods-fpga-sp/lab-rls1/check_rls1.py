#!/usr/bin/env python3
PSCALE = 256
WSCALE = 256
PINIT = 256 * 16

def div_tz(num, den):
    if den == 0:
        return 0
    q = abs(int(num)) // abs(int(den))
    return -q if (num < 0) ^ (den < 0) else q

def rls1_step(w_q, p, x, d):
    den = PSCALE + x * x * p
    k_q = div_tz(p * x * PSCALE, den)
    y = div_tz(w_q * x, WSCALE)
    e = d - y
    w_new = w_q + div_tz(k_q * e * WSCALE, PSCALE)
    p_new = div_tz(p * PSCALE, den)
    if p_new < 1:
        p_new = 1
    return w_new, p_new, y, e, k_q

def main():
    xs = [1, 2, -1, 3, -2, 1, 2, 4, -3, 1, 2, -1, 3, 1, -2, 2, 1, -1, 2, 3]
    ds = [3 * x for x in xs]
    w_q, p = 0, PINIT
    hist = []
    for x, d in zip(xs, ds):
        w_q, p, y, e, k = rls1_step(w_q, p, x, d)
        hist.append((w_q, p, y, e, k))
    w_int = div_tz(w_q, WSCALE)
    print("w_q traj", [h[0] for h in hist])
    print("final w_int,w_q,p", w_int, w_q, p)
    assert abs(w_int - 3) <= 1, (w_int, w_q, p)
    assert abs(w_q - 3 * WSCALE) <= WSCALE // 4, (w_q,)
    print("PASS check_rls1.py")

if __name__ == "__main__":
    main()
