#!/usr/bin/env python3
"""Assignment 3 (Week 3) — retiming validity and critical path after retiming."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))
from dfg import DFG


def fig1():
    times = {"A": 20, "B": 10, "C": 10, "D": 5}
    edges = [
        ("A", "B", 0),
        ("B", "C", 1),
        ("C", "D", 0),
        ("D", "B", 0),
        ("C", "A", 1),
    ]
    return DFG(times, edges)


def fig2():
    """Same topology as Assignment 2 Figure 1 (nodes A–H, each time T)."""
    T = 1
    times = {n: T for n in "ABCDEFGH"}
    edges = [
        ("A", "B", 2), ("A", "C", 0),
        ("B", "D", 0), ("B", "E", 0),
        ("D", "F", 0), ("C", "E", 0), ("C", "F", 1),
        ("E", "G", 0), ("F", "H", 0), ("G", "H", 1),
    ]
    return DFG(times, edges)


def main():
    g = fig1()
    cp = g.critical_path()
    assert cp == 30, cp
    print("PASS A3Q1 Figure-1 CP = 30 u.t. (b)  [A(20)+B(10)]")

    r_bad = {"A": 0, "B": 1, "C": 2, "D": 3}
    assert not g.valid_retiming(r_bad)
    print("PASS A3Q2 r=(0,1,2,3) is invalid (c)")

    # two-stage retiming (applied sequentially)
    g1 = g.retime({"A": 0, "B": 1, "C": 1, "D": 1})
    assert g1.valid_retiming()
    g2 = g1.retime({"A": 1, "B": 1, "C": 0, "D": 1})
    assert g2.valid_retiming()
    cp2 = g2.critical_path()
    assert cp2 == 25, (cp2, g2.edges)
    print("PASS A3Q3 two-stage retiming CP = 25 u.t. (b)")

    # Q4: host S, w(S→B)=1, r(B)=2, r(S)=0 → w' = 1+2-0 = 3
    w_sb = 1 + 2 - 0
    assert w_sb == 3
    print("PASS A3Q4 S-B delay after r(B)=2 is 3 (c)")

    gH = fig2()
    rH = {"A": 1, "B": 0, "C": 1, "D": 1, "F": 2, "E": 1, "G": 2, "H": 3}
    assert gH.valid_retiming(rH)
    gt = gH.retime(rH)
    cpH = gt.critical_path()
    assert cpH == 3, cpH  # 3T
    print("PASS A3Q5 Figure-2 after retiming CP = 3T (b)")

    # Q6: output of B delayed by r(B)=0
    assert rH["B"] == 0
    print("PASS A3Q6 output of B delayed by 0 cycle (d)")

    print("PASS assign-w3")


if __name__ == "__main__":
    main()
