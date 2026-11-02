# lab-biquad-fold — 全并行 vs 折叠 biquad（L21–L22）

Direct-Form I，Q15 系数与 `woods-fpga-sp/lab-biquad/` 相同。

| 模块 | 折叠因子 | 每样本周期 |
|------|----------|------------|
| `biquad_par.v` | 1（5 个乘并行） | 1 |
| `biquad_fold.v` | **5**（1 个乘 + 1 个加时分复用） | 5 |

输出样本 **bit-exact**。折叠公式见 `assign-w6/`。

```bash
cd nptel-vlsi-sp/lab-biquad-fold && make all
```
