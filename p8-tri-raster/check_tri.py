#!/usr/bin/env python3
"""Integer edge-function golden for tri_raster (W=64,H=48) — bit-exact model."""
from __future__ import annotations

W, H = 64, 48


def edge(ax: int, ay: int, bx: int, by: int, px: int, py: int) -> int:
    return (px - ax) * (by - ay) - (py - ay) * (bx - ax)


def fill_tri(
    verts: tuple[tuple[int, int], tuple[int, int], tuple[int, int]],
    color: int = 1,
    fb: list[int] | None = None,
    clear: bool = True,
) -> list[int]:
    if fb is None:
        fb = [0] * (W * H)
    elif clear:
        for i in range(len(fb)):
            fb[i] = 0
    (ax, ay), (bx, by), (cx, cy) = verts
    area = edge(ax, ay, bx, by, cx, cy)
    for y in range(H):
        for x in range(W):
            e0 = edge(bx, by, cx, cy, x, y)
            e1 = edge(cx, cy, ax, ay, x, y)
            e2 = edge(ax, ay, bx, by, x, y)
            inside = False
            if area > 0:
                inside = e0 >= 0 and e1 >= 0 and e2 >= 0
            elif area < 0:
                inside = e0 <= 0 and e1 <= 0 and e2 <= 0
            if inside:
                fb[y * W + x] = color
    return fb


def count(fb: list[int]) -> int:
    return sum(1 for v in fb if v)


def write_ppm(path: str, fb: list[int]) -> None:
    lines = [f"P3\n{W} {H}\n255\n"]
    for y in range(H):
        row = []
        for x in range(W):
            v = 255 if fb[y * W + x] else 0
            row.append(f"{v} {v} {v}")
        lines.append(" ".join(row) + "\n")
    with open(path, "w", encoding="ascii") as f:
        f.writelines(lines)


def main() -> None:
    # Case 1 CCW
    fb1 = fill_tri(((10, 5), (50, 8), (28, 40)))
    n1 = count(fb1)
    assert n1 > 100, n1

    # Case 2 CW — same coverage as mirrored winding of case1 verts order
    fb2 = fill_tri(((10, 5), (28, 40), (50, 8)))
    assert count(fb2) == n1

    # Case 3 degenerate colinear
    fb3 = fill_tri(((5, 5), (20, 5), (40, 5)))
    assert count(fb3) == 0

    # Case 4 partial off-screen
    fb4 = fill_tri(((50, 10), (80, 20), (55, 45)))
    n4 = count(fb4)
    assert 0 < n4 < n1, (n4, n1)

    write_ppm("golden_case1.ppm", fb1)
    write_ppm("golden_case4.ppm", fb4)

    # If sim dumped PPMs, compare pixel equality (P3 ASCII)
    for sim, gold in (("tri_case1.ppm", "golden_case1.ppm"), ("tri_case4.ppm", "golden_case4.ppm")):
        try:
            with open(sim, "r", encoding="ascii") as a, open(gold, "r", encoding="ascii") as b:
                sa, sb = a.read().split(), b.read().split()
            # header P3 W H 255 then RGB triples — compare all tokens
            assert sa == sb, (sim, "ppm mismatch vs golden")
            print(f"PASS ppm match {sim}")
        except FileNotFoundError:
            print(f"SKIP ppm compare (no {sim}; run iverilog TB first)")

    print(f"PASS check_tri.py edge-function W={W} H={H} n_ccw={n1} n_clip={n4}")


if __name__ == "__main__":
    main()
