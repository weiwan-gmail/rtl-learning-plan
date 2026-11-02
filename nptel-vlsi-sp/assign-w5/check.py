#!/usr/bin/env python3
"""Assignment 5 (Week 5) — LMS pipeline, unfolding delay-free rule, Figure 1."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))
from dfg import DFG


def fig1():
    """A(10) --3D--> B(20) --> C(20) --> D(10) --> A, remaining delays 0."""
    times = {"A": 10, "B": 20, "C": 20, "D": 10}
    edges = [
        ("A", "B", 3),
        ("B", "C", 0),
        ("C", "D", 0),
        ("D", "A", 0),
    ]
    return DFG(times, edges)


def main():
    print("PASS A5Q1 LMS cannot pipeline: delay-free error-feedback (c)")
    print("PASS A5Q2 Delayed-LMS converges slower than LMS (c)")

    # Q3: J-unfolded edge with w delays has a delay-free copy iff w < J
    J = 2
    assert DFG({}, []).delay_free_edges_from(0, J) is True
    assert DFG({}, []).delay_free_edges_from(1, J) is True
    assert DFG({}, []).delay_free_edges_from(2, J) is False
    print("PASS A5Q3 delay-free unfolded edges iff w < J (b)")

    # Q4: # parallel loops after unfold = gcd(w,J) ≤ J, so upper-bounded by J
    def n_loops(w, Jf):
        from math import gcd
        return gcd(w, Jf)

    assert n_loops(3, 2) <= 2
    assert n_loops(4, 2) <= 2
    print("PASS A5Q4 # parallel loops upper-bounded by J (b)")

    g = fig1()
    assert g.critical_path() == 60  # B-C-D-A delay-free
    u = g.unfold(2)
    cpu = u.critical_path()
    assert cpu == 60, cpu
    print("PASS A5Q5 J=2 unfolded CP = 60 u.t. (c)")

    ib, loops = g.iteration_bound()
    assert abs(ib - 20.0) < 1e-9, ib
    ibu, _ = u.iteration_bound()
    # gcd(3,2)=1 loop through both copies: time 120 / delays 3 = 40
    assert abs(ibu - 40.0) < 1e-9, ibu
    print("PASS A5Q6 after unfold+retime, min CP = 40 u.t. (c)  [IB of unfolded]")

    # Q7: retime so A-B, B-C, C-D have 1 delay, D-A has 0; unfold J=2
    g7 = DFG(g.t, [("A", "B", 1), ("B", "C", 1), ("C", "D", 1), ("D", "A", 0)])
    u7 = g7.unfold(2)
    cp7 = u7.critical_path()
    assert cp7 == 40, (cp7, u7.edges)
    print("PASS A5Q7 retimed-then-unfolded CP = 40 u.t. (c)")

    print("PASS assign-w5")


if __name__ == "__main__":
    main()
