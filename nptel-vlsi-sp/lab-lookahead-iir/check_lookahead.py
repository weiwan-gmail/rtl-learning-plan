#!/usr/bin/env python3
def plain(xs):
    y, ys = 0, []
    for x in xs:
        y = y + x
        ys.append(y)
    return ys

def la(xs):
    x1 = y1 = y2 = 0
    ys = []
    for x in xs:
        yn = x + x1 + y2
        ys.append(yn)
        x1, y2, y1 = x, y1, yn
    return ys

def main():
    xs = [1, 2, 3, 4, -2, 5, -1, 8]
    assert plain(xs) == la(xs)
    print("PASS check_lookahead.py")

if __name__ == "__main__":
    main()
