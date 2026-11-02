# lab-iir-retime — 一阶 IIR：组合 vs 前向流水（L8–L9）

`y = (x + x_d + y_d) >> 1`（与 `woods-fpga-sp/lab-iir1/` 同一 Q 格式）。

| 模块 | 延迟 | 说明 |
|------|------|------|
| `iir1_combo.v` | 1 | 乘加全在一个周期（长关键路径） |
| `iir1_pipe.v` | 2 | 乘积寄存后再加（cut-set / 前向流水） |

TB **隔开采样**（每个样本后等 4 拍），因此递推用到的 `y[n-1]` 一致，bit-exact。
若每个时钟都送样本，递归环里多一拍会变成不同滤波器——那要把 look-ahead 见 `lab-lookahead-iir/`。

```bash
cd nptel-vlsi-sp/lab-iir-retime && make all
```
