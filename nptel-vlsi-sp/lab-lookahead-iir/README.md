# lab-lookahead-iir — clustered look-ahead 一阶 IIR（Week 8）

原式 \(y[n]=x[n]+y[n-1]\)（积分器）。两步 look-ahead：

\[
y[n]=x[n]+x[n-1]+y[n-2]
\]

循环里有 **2 个延迟**，可在 \(x[n]+x[n-1]\) 上插流水线而不降低采样率。一阶 scattered 与 clustered 相同。

| 模块 | 延迟 | 说明 |
|------|------|------|
| `iir_plain.v` | 1 | 原式，每周期 1 样本 |
| `iir_lookahead.v` | 1 | look-ahead 组合，与原式 bit-exact 流式 |
| `iir_la_pipe.v` | 2 | 前向加法流水；TB 隔拍送样 |

```bash
cd nptel-vlsi-sp/lab-lookahead-iir && make all
```
