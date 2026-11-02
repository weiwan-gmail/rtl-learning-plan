# lab-retiming-fir — Retiming / 流水 FIR 对照（Woods Ch8）

同一 3-tap SFG：

| 模块 | 延迟 | 组合路径 |
|------|------|----------|
| `fir3_combo.v` | 1 | 3×mul + 2×add |
| `fir3_pipe.v` | 3 | 每级更短（mul → add → add） |

比特精确相同；书中 cut-set / retiming 动机：提高时钟，吞吐可更高。

```bash
cd woods-fpga-sp/lab-retiming-fir && make all
```
