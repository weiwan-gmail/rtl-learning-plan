#!/usr/bin/env python3
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))
from dfg import csd_digits, csd_value

def main():
    assert csd_value("100T01") == 29
    assert csd_value("T0T01") == -19
    for x in range(-20, 21):
        assert ((x << 5) - (x << 2) + x) == 29 * x
        assert (-(x << 4) - (x << 2) + x) == -19 * x
    print("PASS check_csd.py")

if __name__ == "__main__":
    main()
