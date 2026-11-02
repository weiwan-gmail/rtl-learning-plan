# lab-baugh-wooley — 有符号 Baugh–Wooley 乘法器（L38，A7 Q6）

8×8 → 16 有符号阵列：最后一行/列部分积取反（角点 `a[7]&b[7]` 不取反），再在 bit **n=8** 与 bit **2n−1=15** 加 1（校正向量 `16'h8100`）。
相对 Horner 进位涟波乘法器的优点（课程）：中间部分积加法无溢出问题。

TB 对照 `$signed(a)*$signed(b)`。

```bash
cd nptel-vlsi-sp/lab-baugh-wooley && make all
```
