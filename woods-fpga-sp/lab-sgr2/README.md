# lab-sgr2 — Squared / 未归一化 Givens 步（Woods Ch11 SGR 积木）

相对 `lab-givens2`（需要 `c=a/r,s=b/r` 与开方/除法），本步用

```
[x'] = [ a  b] [x]     (x,y)=(a,b) ⇒ (a²+b², 0)
[y']   [-b  a] [y]
```

**无 sqrt、无除法**，输出 `r2=a²+b²`。体现 SGR「平方三角化」动机。多抽头 QR-RLS 阵列仍见 PLACEHOLDER。

```bash
cd woods-fpga-sp/lab-sgr2 && make all
```
