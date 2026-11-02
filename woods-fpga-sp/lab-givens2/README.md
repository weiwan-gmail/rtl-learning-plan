# lab-givens2 — 2×2 Givens 消零（Woods Ch11 QR 积木）

QR 常用形式：

```
[x'] = [ c  s] [x]     c=x/r, s=y/r, r=√(x²+y²)
[y']   [-s  c] [y]  →  (r, 0)
```

c,s 为 Q15。TB 含 3-4-5 消零（`y'≈0`, `x'≈5000`）。完整 QR 流水/厂商实现见 `PLACEHOLDERS.md`。

```bash
cd woods-fpga-sp/lab-givens2 && make all
```
