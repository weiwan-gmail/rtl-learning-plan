# lab-fir-3par — 3 并行 FIR（L31）

3 抽头 `H=[1,2,1]`。每个周期吃 3 个样本、吐 3 个输出，与串行 golden **bit-exact**。

课程 L31 的硬件高效 3-parallel 用 `(h0+h1+h2)` 类恒等式少乘；本 DUT 用直接多相式，数值相同。

```bash
cd nptel-vlsi-sp/lab-fir-3par && make all
```
