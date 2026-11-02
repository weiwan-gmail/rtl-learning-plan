# CHAPTER_MAP — NPTEL 108105157 VLSI Signal Processing

课程：Prof. Mrityunjoy Chakraborty, IIT Kharagpur. Lectures L1–L39 (Digimat).  
官方：https://nptel.ac.in/courses/108105157

| Week | Lectures | 主题 | 处理 | 路径 | 状态 |
|------|----------|------|------|------|------|
| 1 | L1–L5 | SFG / DFG / DG, critical path | RTL + assign | `lab-fir-transpose/` `assign-w1/` | DONE |
| 1 | — | FIR 基线 | reuse | `../p3-fir-nco/` | reuse |
| 2 | L6–L10 | retiming, loop/iteration bound, LMS intro | assign + reuse | `assign-w2/` `../woods-fpga-sp/lab-lms/` | DONE |
| 3 | L8–L12 | cutset retiming, pipelined DSP, LMS/DLMS | RTL | `lab-iir-retime/` `lab-dlms/` `assign-w3/` | DONE |
| 4 | L13–L20 | unfolding, IB, bit/digit/word serial | assign | `assign-w4/` `assign-w5/` (unfold Qs) | DONE |
| 5 | L21–L25, L29–L31 | folding intro, polyphase, 2/3-par FIR | RTL | `lab-fir-2par/` `lab-fir-3par/` `assign-w5/` | DONE |
| 6 | L21–L23 | folding biquad / lattice | RTL + assign | `lab-biquad-fold/` `assign-w6/` | DONE |
| 6 | — | DF-I biquad 基线 | reuse | `../woods-fpga-sp/lab-biquad/` | reuse |
| 7 | L24–L31, L32–L35 | lifetime, 3-par, 2's complement, CSD, CSA | RTL + assign | `lab-csd-mul/` `lab-baugh-wooley/` `assign-w7/` | DONE |
| 8 | L36–L39 | bit-serial, Baugh-Wooley, DA, look-ahead | RTL + assign | `lab-bitserial-fir/` `lab-lookahead-iir/` `assign-w8/` | DONE |
| 8 | — | DA FIR | reuse | `../woods-fpga-sp/lab-da-fir/` `lab-da-fir-signed/` | reuse |
| 8 | — | 乘法器阵列 | reuse | `../woods-fpga-sp/lab-arith/` | reuse |
| 3 | — | combo vs pipelined FIR | reuse | `../woods-fpga-sp/lab-retiming-fir/` | reuse |

新 lab 均 **自包含**（小 DUT 拷贝，不依赖 `../../` 才能 `make`）。

## 作业 → 检查器（Accepted Answers 来自课程 PDF）

| 作业 | 可恢复数字答案 | OCR_GAP |
|------|----------------|---------|
| A1 | Q1 (c) CP 不变; Q2 (b) dim=3; Q3 (c) 1mul+1add; Q4 (a) 4add+1mul; Q5 (b) | 无（图已辨认：转置线性相位） |
| A2 | Q1 (c); Q2 (d) 4T; Q3 (a); Q4 (b); Q5 (d); Q6 (d) 4T; Q7 (b) 0; Q8 (c) dim=4 | 无（Figure 1 已重建） |
| A3 | Q1 (b) 30; Q2 (c) invalid; Q3 (b) 25; Q4 (c) 3; Q5 (b) 3T; Q6 (d) 0 | 无 |
| A4 | Q1 (b) 10; Q2 (a) 2; Q3 (c) 30; Q4 (b) 25; Q5 (d) 25; Q6 (b) | WDF 内部节点按数字反推（见 PLACEHOLDERS） |
| A5 | Q1 (c); Q2 (c); Q3 (b) w<J; Q4 (b) J; Q5 (c) 60; Q6 (c) 40; Q7 (c) 40 | 无 |
| A6 | Q1 (b); Q2 (c) digit size **3**; Q3 (c) 6 neg; Q4 (c) −3; Q5 (d); Q6 (c) | lattice `M1→A2` 边未计入 |
| A7 | Q1 (a) 7; Q2 (b) 8; Q3 (a) 10u(n); Q4 (c); Q5 (c) 100T01; Q6 (b) | 无 |
| A8 | Q1 (c); Q2 (c); Q3 (c) Wn+3; Q4 (a) 2; Q5 (b) T0T01; Q6 (d) | 无 |

## 计数

| 类别 | 数量 |
|------|------|
| 新 RTL lab | **10** |
| assign-wN 检查器 | **8** |
| reuse woods / p3 | 文档链接，DUT 已拷或独立实现 |
| PLACEHOLDER | Vivado/HLS only |
