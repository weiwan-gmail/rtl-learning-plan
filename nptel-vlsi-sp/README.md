# NPTEL 108105157 · VLSI Signal Processing — RTL 仿真教程

把 Prof. Mrityunjoy Chakraborty（IIT Kharagpur）课程里能仿真的例子和作业，落成 **iverilog** lab 与 **Python DFG 检查器**。纯选择题里的图只要 OCR/PDF 能读出数字，就写成可 `make` 变绿的断言，而不是散文笔记。

- **课程：** https://nptel.ac.in/courses/108105157
- **讲次索引（L1–L39）：** http://www.digimat.in/nptel/courses/video/108105157/108105157.html
- **Archive：** https://archive.nptel.ac.in/courses/108/105/108105157/

## 怎么用

```bash
cd nptel-vlsi-sp && make all
```

依赖：`iverilog`、`vvp`、`python3`（标准库即可，无需 numpy）。

| 文档 | 用途 |
|------|------|
| [`CHAPTER_MAP.md`](CHAPTER_MAP.md) | 周次/讲次 → lab / assign / reuse / OCR_GAP |
| [`PLACEHOLDERS.md`](PLACEHOLDERS.md) | Vivado/HLS 与图损坏说明 |
| [`NEXT.md`](NEXT.md) | 可选后续 |
| [`assignments/ASSIGNMENTS_OCR.md`](assignments/ASSIGNMENTS_OCR.md) | 清理后的 Week1–8 题目 + Accepted Answers |
| `lab-*/` | RTL，绿灯 `PASS …` |
| `assign-w*/` | 作业图的 DFG/寿命/多相检查器 |

作业扫描 PDF **不入库**（根目录 `.gitignore` 的 `*.pdf`）。需要原图时放 `../refs/` 本地即可。

## Lab 一览

| lab | 主题 | 课内锚点 |
|-----|------|----------|
| `lab-fir-transpose/` | 线性相位直接型 vs 转置 FIR | L1–L3, A1 Q3–4 |
| `lab-iir-retime/` | 一阶 IIR 组合 vs 前向流水 | L8–L9 |
| `lab-dlms/` | LMS vs Delayed-LMS | L10–L12, A5 Q1–2 |
| `lab-fir-2par/` | 2-parallel / 多相 FIR | L29–L30 |
| `lab-fir-3par/` | 3-parallel FIR | L31 |
| `lab-biquad-fold/` | 全并行 vs 折叠因子 5 的 biquad | L21–L22 |
| `lab-bitserial-fir/` | \(y=-3x(n)+3x(n-1)\) 比特串行 | L37, A8 Q3 |
| `lab-baugh-wooley/` | 有符号 Baugh–Wooley 8×8 | L38, A7 Q6 |
| `lab-csd-mul/` | CSD 常系数 29 与 −19 | A7 Q5, A8 Q5 |
| `lab-lookahead-iir/` | clustered look-ahead 积分器 | Week 8 |

每个 lab 的 `make all` 打印清晰 `PASS …`；顶层 `make all` 任一失败即非零退出。

## 复用（链接，不整棵复制）

| 主题 | 已有树 |
|------|--------|
| FIR 基线 | [`../p3-fir-nco/`](../p3-fir-nco/) |
| combo vs 流水 FIR | [`../woods-fpga-sp/lab-retiming-fir/`](../woods-fpga-sp/lab-retiming-fir/) |
| DF-I biquad | [`../woods-fpga-sp/lab-biquad/`](../woods-fpga-sp/lab-biquad/) |
| 2-tap LMS | [`../woods-fpga-sp/lab-lms/`](../woods-fpga-sp/lab-lms/) |
| DA FIR | [`../woods-fpga-sp/lab-da-fir/`](../woods-fpga-sp/lab-da-fir/) |
| 乘法器 | [`../woods-fpga-sp/lab-arith/`](../woods-fpga-sp/lab-arith/) |

本目录 DUT 自包含，因此 `cd nptel-vlsi-sp && make all` 不依赖相对 DUT 路径。

## PLACEHOLDER

没有 Vivado/HLS 实验。不要把「没跑过的布局后时序」写成 PASS。细节见 `PLACEHOLDERS.md`。

## 许可

教程与原创 RTL 为仓库练习代码。课程视频/作业图版权归 NPTEL / IIT Kharagpur；此处只做教学性重述与独立实现，**不**复制 PDF 页面。
