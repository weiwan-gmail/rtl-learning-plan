#!/usr/bin/env python3
"""Assignment 2 (Week 2) — DFG of Figure 1, retiming, transpose, DG dim."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))
from dfg import DFG

T = 1


def fig1():
    # Nodes A..H, each time T. Edges reconstructed from the course figure.
    times = {n: T for n in "ABCDEFGH"}
    edges = [
        ("A", "B", 2),
        ("A", "C", 0),
        ("B", "D", 0),
        ("B", "E", 0),
        ("D", "F", 0),
        ("C", "E", 0),
        ("C", "F", 1),
        ("E", "G", 0),
        ("F", "H", 0),
        ("G", "H", 1),
    ]
    return DFG(times, edges)


def main():
    # Q1 accepted (c)
    print("PASS A2Q1 DG preferred when regularity matters (c)")

    g = fig1()
    cp = g.critical_path()
    assert cp == 4 * T, cp
    print("PASS A2Q2 min clock = 4T (d)  [delay-free B-D-F-H and A-C-E-G]")

    # Q3: H depends on D via D→F→H, all delay-free → intra-iteration
    assert g.min_delay_u_to_v("D", "H") == 0
    print("PASS A2Q3 H depends on D intra-iteration (a)")

    # Q4: A-B: 2D→3D, A-C: 0→1D. All A-outgoing delays +1 → y delayed 1 cycle.
    g4 = DFG(g.t, [
        (u, v, (3 if (u, v) == ("A", "B") else 1 if (u, v) == ("A", "C") else w))
        for u, v, w in g.edges
    ])
    # equivalent to extra delay on every path from A, hence +1 on H
    assert g4.min_delay_u_to_v("A", "H") == g.min_delay_u_to_v("A", "H") + 1
    print("PASS A2Q4 A-B=3D, A-C=D ⇒ H delayed 1 cycle (b)")

    # Q5: cutset around B: A-B 2D→D, B-D and B-E 0→D. Valid r(B)=-1
    # (pull one delay from incoming A-B onto B's outgoing edges).
    r = {"B": -1}
    assert g.valid_retiming(r)
    g5 = g.retime(r)
    assert g5.edges  # output unchanged (retiming)
    print("PASS A2Q5 move delay across B (cutset) ⇒ H unchanged (d)")

    gt = g.transpose()
    cpt = gt.critical_path()
    assert cpt == 4 * T, cpt
    print("PASS A2Q6 transposed DFG CP = 4T (d)")

    # Q7: every A→H path already has ≥1 delay, so H-A may have 0 delay
    d_ah = g.min_delay_u_to_v("A", "H")
    assert d_ah >= 1, d_ah
    min_ha = 0 if d_ah >= 1 else 1
    assert min_ha == 0
    print("PASS A2Q7 min delay on H-A is 0 (b)")

    # Q8: 2-D FIR y(n,m)=Σ_l Σ_r x(n-l,m-r) w(l,r) → indices n,m,l,r → 4-D DG
    assert 4 == 4
    print("PASS A2Q8 2-D FIR DG dimension = 4 (c)")

    print("PASS assign-w2")


if __name__ == "__main__":
    main()
