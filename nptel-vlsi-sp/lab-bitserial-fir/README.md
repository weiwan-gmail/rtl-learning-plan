# lab-bitserial-fir — 比特串行 FIR（A8 Q3，L37）

\[
y(n) = -3\,x(n) + 3\,x(n-1)
\]

LSB-first；`×3 = x + (x<<1)`。三级寄存加法器 → **LSB of y 出现在 Wn+3**（课程 Accepted (c)）。

字长 `W=8`。TB 对照字串行 golden。

```bash
cd nptel-vlsi-sp/lab-bitserial-fir && make all
```
