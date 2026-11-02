# lab-fir-transpose — 直接型 vs 转置 FIR（L1–L3，Assignment 1 Q3–4）

线性相位 4 抽头 `H=[1,2,2,1]`（Q0）：

| 模块 | 结构 | 关键路径直觉 |
|------|------|----------------|
| `fir_direct.v` | 延迟链 + 并行乘 + 加法树 | 1 mul + 若干 add |
| `fir_transpose.v` | x 广播到 4 个乘，加法器之间插 D | 1 mul + 1 add |

TB 证明 **bit-exact** 相同 `y[n]`。课程 Figure 1 是 7 抽头线性相位的转置型（4 个独立系数），CP = 1 mul + 1 add；再转置后 CP = 4 add + 1 mul —— 见 `assign-w1/`。

复用：`../../p3-fir-nco/`、`../../woods-fpga-sp/lab-retiming-fir/`（本 lab 自包含）。

```bash
cd nptel-vlsi-sp/lab-fir-transpose && make all
```
