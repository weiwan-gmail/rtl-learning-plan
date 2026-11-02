# lab-iir1 — 一阶 IIR（Woods Ch2 §2.4.2）

Direct-Form 风格一阶递归：

\[
y[n] = (B_0 x[n] + B_1 x[n-1] + A_1 y[n-1]) \gg \mathrm{SHIFT}
\]

默认 `B0=B1=A1=1, SHIFT=1` → 简单低通/泄漏平均（整数友好，便于 bit-exact）。

## 文件

| 文件 | 说明 |
|------|------|
| `iir1.v` | 流式 IIR；LATENCY=1 |
| `tb_iir1.v` | bit-exact 自检 |
| `check_iir1.py` | Python golden |
| `Makefile` | `make all` |

## 运行

```bash
cd woods-fpga-sp/lab-iir1 && make all
```

与 `../../p3-fir-nco`（FIR）对照：FIR 无递归；IIR 用输出反馈换更短抽头（书 §2.4）。
