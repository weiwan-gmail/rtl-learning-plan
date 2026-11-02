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

### 与已有阶梯的复用（不要重复造轮子）

| 书中主题 | 复用 |
|----------|------|
| FIR / NCO | [`../p3-fir-nco/`](../p3-fir-nco/) |
| CIC | [`../p7-cic/`](../p7-cic/) |
| SDR 环回 NCO→FIR→CIC | [`../p11-sdr-loop/`](../p11-sdr-loop/) |
| FIFO formal | [`../p12-fifo-formal/`](../p12-fifo-formal/) |

### PLACEHOLDER 约定

目录内仅 `PLACEHOLDER.md`，写明：**不实现的原因**（依赖 Vivado HLS / Altera OpenCL SDK / 厂商专用 IP / 纯工艺综述等）以及若将来要做，应改成什么形态的纯 RTL。

## Batch 1 已交付 lab（本目录）

```bash
cd lab-cordic && make all   # Ch3 CORDIC rotate
cd lab-iir1   && make all   # Ch2 一阶 IIR
cd lab-da-fir && make all   # Ch6 Distributed Arithmetic FIR
cd lab-fft8   && make all   # Ch2 8-pt radix-2 FFT
cd lab-lms    && make all   # Ch2 2-tap LMS
```

依赖：`iverilog`、`vvp`、`python3`（无需 numpy）。

## 许可与版权

教程与原创 RTL 属本仓库练习代码。书中公式/图表版权归 Wiley / 作者；此处仅教学性重述与独立实现，**不**复制 PDF 正文。
