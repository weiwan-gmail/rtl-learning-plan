#!/usr/bin/env python3
"""Small DFG helpers for NPTEL 108105157 homework checkers (stdlib only).

Critical path = max sum of node computation times along a delay-free path
(including trivial single-node paths). Iteration bound = max T_loop / D_loop
over simple cycles. Retiming: w'(e:u->v) = w(e) + r(v) - r(u).
"""
from __future__ import annotations

from collections import defaultdict
from math import gcd, inf


class DFG:
    def __init__(self, times, edges):
        """times: dict name -> computation time
        edges: list of (u, v, delays)
        """
        self.t = dict(times)
        self.edges = [(u, v, int(w)) for u, v, w in edges]
        for u, v, _ in self.edges:
            if u not in self.t:
                self.t[u] = 0
            if v not in self.t:
                self.t[v] = 0

    def nodes(self):
        return list(self.t.keys())

    def retime(self, r):
        r = defaultdict(int, r)
        new_e = []
        for u, v, w in self.edges:
            w2 = w + r[v] - r[u]
            new_e.append((u, v, w2))
        return DFG(self.t, new_e)

    def valid_retiming(self, r=None):
        g = self if r is None else self.retime(r)
        return all(w >= 0 for _, _, w in g.edges)

    def delay_free_adj(self):
        adj = defaultdict(list)
        for u, v, w in self.edges:
            if w == 0:
                adj[u].append(v)
        return adj

    def has_combinational_cycle(self):
        adj = self.delay_free_adj()
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {n: WHITE for n in self.t}

        def dfs(u):
            color[u] = GRAY
            for v in adj.get(u, []):
                if color[v] == GRAY:
                    return True
                if color[v] == WHITE and dfs(v):
                    return True
            color[u] = BLACK
            return False

        return any(dfs(n) for n in self.t if color[n] == WHITE)

    def critical_path(self):
        """Longest delay-free path cost (sum of node times). Single nodes count."""
        if self.has_combinational_cycle():
            return inf
        adj = self.delay_free_adj()
        memo = {}

        def dfs(u):
            if u in memo:
                return memo[u]
            best = self.t[u]
            for v in adj.get(u, []):
                best = max(best, self.t[u] + dfs(v))
            memo[u] = best
            return best

        return max(dfs(n) for n in self.t)

    def simple_cycles(self):
        """Simple directed cycles as lists of node names (start=end not repeated)."""
        adj = defaultdict(list)
        for u, v, w in self.edges:
            adj[u].append((v, w))
        cycles = []
        nodes = list(self.t)

        def dfs(start, u, path, nodeset, delays):
            for v, w in adj.get(u, []):
                if v == start and len(path) >= 1:
                    cycles.append((list(path), delays + w))
                elif v not in nodeset and nodes.index(v) >= nodes.index(start):
                    path.append(v)
                    nodeset.add(v)
                    dfs(start, v, path, nodeset, delays + w)
                    path.pop()
                    nodeset.remove(v)

        for i, s in enumerate(nodes):
            dfs(s, s, [s], {s}, 0)
        # unique by frozenset of edges
        uniq = []
        seen = set()
        for path, dly in cycles:
            key = tuple(path)
            if key not in seen:
                seen.add(key)
                uniq.append((path, dly))
        return uniq

    def iteration_bound(self):
        best = 0.0
        loops = []
        for path, dly in self.simple_cycles():
            if dly <= 0:
                continue
            T = sum(self.t[n] for n in path)
            ib = T / dly
            loops.append((path, T, dly, ib))
            if ib > best:
                best = ib
        return best, loops

    def min_delay_u_to_v(self, src, dst):
        """Min total delays on any path src->dst. inf if unreachable."""
        adj = defaultdict(list)
        for u, v, w in self.edges:
            adj[u].append((v, w))
        best = {n: inf for n in self.t}
        best[src] = 0
        # Bellman-Ford (delays are non-negative if valid DFG, but be general)
        for _ in range(len(self.t)):
            updated = False
            for u in list(self.t):
                if best[u] is inf:
                    continue
                for v, w in adj.get(u, []):
                    if best[u] + w < best[v]:
                        best[v] = best[u] + w
                        updated = True
            if not updated:
                break
        return best[dst]

    def transpose(self):
        return DFG(self.t, [(v, u, w) for u, v, w in self.edges])

    def unfold(self, J):
        """J-unfolded DFG. Edge u->v with w delays becomes J edges
        u_i -> v_{(i+w) mod J} with floor((i+w)/J) delays (Parhi).
        """
        times = {}
        for n, tv in self.t.items():
            for i in range(J):
                times[f"{n}_{i}"] = tv
        edges = []
        for u, v, w in self.edges:
            for i in range(J):
                dest = (i + w) % J
                dly = (i + w) // J
                edges.append((f"{u}_{i}", f"{v}_{dest}", dly))
        return DFG(times, edges)

    def delay_free_edges_from(self, w, J):
        """Unfolding: original edge with w delays yields a delay-free edge iff w < J."""
        return w < J


def folding_delay(N, w, P_u, u, v):
    """Parhi folding formula D_F(U->V) = N*w - P_U + v - u."""
    return N * w - P_u + v - u


def csd_digits(n, width=None):
    """Canonical signed digit (non-adjacent 1/T). Returns string MSB-first with T=-1."""
    return _csd_from_int(n, width)


def _csd_from_int(n, width=None):
    n = int(n)
    if n == 0:
        return "0"
    # work with enough bits
    mag = abs(n)
    w = width or (mag.bit_length() + 2)
    # CSD conversion from LSB
    x = n
    digits = []
    for _ in range(w + 2):
        if x == 0 and len(digits) > 0:
            break
        if (x & 1) == 0:
            digits.append(0)
            x >>= 1
        else:
            # choose ±1 to avoid adjacent
            # if x % 4 == 3 or x % 4 == -1 (i.e. 3 mod 4): use -1
            if (x & 3) == 3:
                digits.append(-1)
                x = (x + 1) >> 1
            else:
                digits.append(1)
                x = (x - 1) >> 1
    while len(digits) > 1 and digits[-1] == 0:
        digits.pop()
    # MSB-first string
    chars = []
    for d in reversed(digits):
        chars.append("1" if d == 1 else ("T" if d == -1 else "0"))
    return "".join(chars)


def csd_value(s):
    v = 0
    for ch in s:
        v *= 2
        if ch == "1":
            v += 1
        elif ch in "T-":
            v -= 1
    return v
