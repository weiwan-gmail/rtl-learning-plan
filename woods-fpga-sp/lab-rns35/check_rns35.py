#!/usr/bin/env python3
def crt(r5, r7):
    acc = 21 * r5 + 15 * r7
    return acc % 35

def main():
    for x in range(35):
        r5, r7 = x % 5, x % 7
        assert crt(r5, r7) == x, (x, crt(r5, r7))
    for a in range(0, 35, 3):
        for b in range(0, 35, 5):
            assert crt((a+b)%5, (a+b)%7) == (a+b)%35
            assert crt((a*b)%5, (a*b)%7) == (a*b)%35
    print("PASS check_rns35.py")

if __name__ == "__main__":
    main()
