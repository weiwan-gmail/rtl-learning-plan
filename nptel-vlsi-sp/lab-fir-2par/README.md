# lab-fir-2par — 2 并行 / 多相 FIR（L29–L30）

`H=[1,2,2,1]`。串行 FIR 与偶/奇两路 2-parallel 在成对样本上 **bit-exact**。

硬件高效 2-parallel（减少乘法器，NPTEL L30）的代数拆分与本 DUT 等价；此处用直接多相方程便于对照 golden。

```bash
cd nptel-vlsi-sp/lab-fir-2par && make all
```
