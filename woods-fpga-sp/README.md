# Woods *FPGA-based Implementation of Signal Processing Systems*（2nd ed.）— RTL 仿真教程

把 MIT 6.S965 教材 PDF 里适合 **iverilog / Verilator** 的 DSP/算术内容落成可跑 RTL lab；Vivado / HLS / 厂商 SDK / OpenCL 等流程用 **PLACEHOLDER** 占位，不假装能在本仓库仿真。

## 书目与课程

- **书：** Roger Woods, John McAllister, Gaye Lightbody, Ying Yi. *FPGA-based Implementation of Signal Processing Systems*, 2nd ed., Wiley, 2017. ISBN 9781119077954.
- **课程静态副本：** [https://rfsoc.mit.edu/6S965/_static/F25/textbooks/fpga_signal_processing.pdf](https://rfsoc.mit.edu/6S965/_static/F25/textbooks/fpga_signal_processing.pdf)
- **本地 refs（不入库）：** `../refs/fpga_signal_processing.pdf`、`../refs/fpga_sp.txt`（`*.pdf` 已 gitignore，请自行下载）。

## 怎么用

| 文档 | 用途 |
|------|------|
| [`CHAPTER_MAP.md`](CHAPTER_MAP.md) | 全书各章 → RTL lab / 教程-only / PLACEHOLDER / reuse |
| [`PLACEHOLDERS.md`](PLACEHOLDERS.md) | 延期项与原因 |
| [`NEXT.md`](NEXT.md) | 后续批次待做 RTL |
| `lab-*/` | 可 `make all` 的绿灯仿真 |
| `ch*-*/PLACEHOLDER.md` | 厂商/HLS/大架构 stub |

一键跑全部 lab：

```bash
cd woods-fpga-sp && make all
```

### 与已有阶梯的复用

| 书中主题 | 复用 |
|----------|------|
| FIR / NCO | [`../p3-fir-nco/`](../p3-fir-nco/) |
| CIC | [`../p7-cic/`](../p7-cic/) |
| SDR 环回 NCO→FIR→CIC | [`../p11-sdr-loop/`](../p11-sdr-loop/) |
| FIFO formal | [`../p12-fifo-formal/`](../p12-fifo-formal/) |

### PLACEHOLDER 约定

目录内仅 `PLACEHOLDER.md`，写明：**不实现的原因**以及若将来要做应改成什么形态的纯 RTL。

## Batch 1 lab

| lab | 主题 |
|-----|------|
| `lab-cordic/` | Ch3 CORDIC rotate（+ Batch2 vector） |
| `lab-iir1/` | Ch2 一阶 IIR |
| `lab-da-fir/` | Ch6 DA FIR（无符号） |
| `lab-fft8/` | Ch2 8-pt radix-2 FFT |
| `lab-lms/` | Ch2 2-tap LMS |

## Batch 2 lab

| lab | 主题 |
|-----|------|
| `lab-arith/` | Ch3 CLA-16 + array mult-8 |
| `lab-rcm/` | Ch6/3 RCM 常系数移位加减 |
| `lab-biquad/` | Ch2/5 DF-I biquad |
| `lab-da-fir-signed/` | Ch6 有符号 2's complement DA |
| `lab-retiming-fir/` | Ch8 combo vs pipelined FIR |
| `lab-givens2/` | Ch11 2×2 Givens 消零积木 |

依赖：`iverilog`、`vvp`、`python3`（无需 numpy）。

## 许可与版权

教程与原创 RTL 属本仓库练习代码。书中公式/图表版权归 Wiley / 作者；此处仅教学性重述与独立实现，**不**复制 PDF 正文。
