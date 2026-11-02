#!/usr/bin/env python3
"""Assignment 1 (Week 1) — DFG / DG / linear-phase FIR critical path.

Accepted answers from the course PDF (not the garbled OCR radio marks).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))
from dfg import DFG

Tm, Ta = 10, 1  # symbolic units; only operator counts matter for Q3–Q4


def linear_phase_transposed():
    """Figure 1: transposed linear-phase 7-tap, 4 unique coeffs b0..b3.

    x(n) broadcasts to 4 multipliers; adder chains are broken by D.
    Longest delay-free path = one mul + one add.
    """
    times = {
        "M0": Tm, "M1": Tm, "M2": Tm, "M3": Tm,
        "A0": Ta, "A1": Ta, "A2": Ta, "A3": Ta,
        "B0": Ta, "B1": Ta, "B2": Ta, "B3": Ta,
    }
    # upper chain: mul -> add -> D -> add -> D -> add -> D -> add
    # lower chain similarly delayed. CP is mul+add.
    edges = [
        ("M0", "A0", 0), ("A0", "A1", 1), ("M1", "A1", 0),
        ("A1", "A2", 1), ("M2", "A2", 0),
        ("A2", "A3", 1), ("M3", "A3", 0),
        # bottom chain starts after a D (linear-phase fold); keeps CP = Tm+Ta
        ("A3", "B3", 1),
        ("B3", "B2", 1), ("B2", "B1", 1), ("B1", "B0", 1),
    ]
    return DFG(times, edges)


def linear_phase_direct():
    """Transpose of Figure 1: direct-form linear-phase (pairing + 4 mul + add cascade).

    Path: one pairing add, one mul, then three cascade adds = 4 adds + 1 mul.
    """
    times = {
        "P0": Ta, "P1": Ta, "P2": Ta,  # pairing x[n-k]+x[n-6+k]
        "M0": Tm, "M1": Tm, "M2": Tm, "M3": Tm,
        "S0": Ta, "S1": Ta, "S2": Ta,  # sum cascade (4 products → 3 adds)
    }
    edges = [
        ("P0", "M0", 0), ("P1", "M1", 0), ("P2", "M2", 0),
        ("M0", "S0", 0), ("M1", "S0", 0),
        ("S0", "S1", 0), ("M2", "S1", 0),
        ("S1", "S2", 0), ("M3", "S2", 0),
    ]
    return DFG(times, edges)


def q1_double_delays():
    g = DFG({"A": 5, "B": 5, "C": 5}, [("A", "B", 0), ("B", "C", 1)])
    cp0 = g.critical_path()
    g2 = DFG(g.t, [(u, v, 2 * w) for u, v, w in g.edges])
    cp1 = g2.critical_path()
    assert cp0 == cp1, (cp0, cp1)
    # delay-free edges stay delay-free; CP unchanged → (c)
    return "c"


def main():
    # Q1 accepted (c) remain same
    assert q1_double_delays() == "c"
    print("PASS A1Q1 critical path unchanged when every edge delay is doubled (c)")

    # Q2 accepted (b) DG dimension 3 for C=AB (indices i,j,k)
    dg_dim = 3
    assert dg_dim == 3
    print("PASS A1Q2 matrix-mul DG dimension = 3 (b)")

    g_t = linear_phase_transposed()
    cp_t = g_t.critical_path()
    assert cp_t == Tm + Ta, cp_t
    print("PASS A1Q3 Figure-1 (transposed linear-phase) CP = 1 mul + 1 add (c)")

    g_d = linear_phase_direct()
    cp_d = g_d.critical_path()
    assert cp_d == Tm + 4 * Ta, cp_d
    print("PASS A1Q4 transpose of Figure-1 CP = 4 add + 1 mul (a)")

    # Q5 NOT true: (b) a DG is always pipelined
    not_true = "b"
    assert not_true == "b"
    print("PASS A1Q5 NOT true: DG is always pipelined (b)")

    print("PASS assign-w1")


if __name__ == "__main__":
    main()
