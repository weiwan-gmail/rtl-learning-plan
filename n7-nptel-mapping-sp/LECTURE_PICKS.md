# LECTURE_PICKS · NPTEL 108106149 选讲清单

**课程：** Mapping Signal Processing Algorithms to Architectures（Nitin Chandrachoodan / IIT Madras）  
**官方：** https://nptel.ac.in/courses/108106149 · https://archive.nptel.ac.in/courses/108/106/108106149/  
**播放列表：** https://www.youtube.com/playlist?list=PLyqSpQzTE6M8XDxxMl4SNFiB6_U4kII8Z  

讲次编号按公开讲次表（Digimat / archive 视频表，约 **L1–L103**）。Week 归属按 archive 周目录粗分，便于定位。

---

## A. 必看（8）

| 序号 | 建议周/讲次 | 原标题 (EN) | 一句话为什么看 | 与本仓对照 | 优先级 |
|------|-------------|-------------|----------------|------------|--------|
| 1 | W2 · L12 | Basic FIR filter | 把 FIR 从「公式」落到硬件数据通路词汇 | **P3** FIR | 必看 |
| 2 | W2 · L13 | Serial FIR filter architectures | 串行 MAC / 抽头复用：对照你写过的教学 FIR | **P3** FIR | 必看 |
| 3 | W2 · L16（可先扫 L15） | Dataflow Graphs（+ Block diagrams and SFGs） | SFG/DFG 是后续流水线、折叠、展开的共同语言 | **P3** / **P7** | 必看 |
| 4 | W2 · L17–L18 | Iteration period；FIR filter iteration period | 采样率/迭代界：理解吞吐上限，对照 CIC 抽取后速率 | **P3** FIR · **P7** CIC | 必看 |
| 5 | W3 · L28–L29 | Pipelining；Pipelining FIR filter | 前馈流水线如何抬 FIR 时钟/吞吐 | **P3** FIR | 必看 |
| 6 | W3 · L34–L35 | Retiming basic concept；Example and uses of retiming | 重定时 = RTL 时序收敛的算法视角 | **P3** / 任意流水线 DUT | 必看 |
| 7 | W4 · L41–L42、L44 | Example: Biquad filter；Hardware architecture；Complete biquad hardware | **折叠/资源共享** 把图变成有限加法器+多路复用的完整例子（可扫 L43） | IIR 架构（相对 P3 直推 FIR） | 必看 |
| 8 | W12 · L100 | Parallel implementation of FIR filters | 并行 FIR 与 L13 串行对照，扩展 P3 架构选项 | **P3** FIR | 必看 |

---

## B. 选看（6）

| 序号 | 建议周/讲次 | 原标题 (EN) | 一句话为什么看 | 与本仓对照 | 优先级 |
|------|-------------|-------------|----------------|------------|--------|
| 9 | W3 · L25 | Parallel architecture | 并行化总览，作为 L100 前的短垫 | **P3** | 选看 |
| 10 | W4 · L36 | Resource sharing: adder example | 加法器时分复用：FIR/CIC 里「少算子、多 mux」直觉 | **P3** / **P7** | 选看 |
| 11 | W12 · L99 | CORDIC algorithm | 无乘法器的旋转/三角：对照 NCO 的查表或旋转实现 | **P3** NCO | 选看 |
| 12 | W12 · L97–L98 | Systolic Arrays — Background；Examples | 规则阵列映射：日后做卷积/矩阵核的架构模板 | **P5** tiny-gpu 直觉 | 选看 |
| 13 | W12 · L101（可选接 L102） | Unfolding Transformation（+ Lookahead） | 展开/超前变换：提高并行度的图变换 | **P3** / **P7** 进阶 | 选看 |
| 14 | W9 · L85、L87（可扫 L86、L88） | On-chip communication basics；AXI bus handshaking | 片上手摇/总线：对照 FIFO ready/valid 思维 | **P2** FIFO · 未来 SoC | 选看 |

**额外可选短片（不计入上表核心 14）：** L103 *Introduction to GPUs and Matrix multiplication* — 与 **P5** matadd 对照；有兴趣再看。L92 *DMA and arbitration* — 做 CPU+加速器时再补。

---

## C. 可跳（主题清单 — 整块略过）

明确 **不要** 为刷完课而看这些（除非以后换 Vivado/HLS 或 NoC 课题）：

| 主题 | 大致讲次 | 为什么可跳 |
|------|----------|------------|
| 数字逻辑 / 时序功耗复习 | L2–L4 | 已在 P1–P6 与 RISC-V 阶梯练过 |
| 动机案例与多目标优化引言 | L5–L9 | 了解即可；不挡架构映射 |
| 浮点 / 科学计数深挖 | L10–L11 | 本仓定点路径为主 |
| 一般 IPB 约束推导长链 | L19–L24、L37–L40 | 保留 L17–L18 直觉即可 |
| ASAP/ALAP/ILP/列表/力导向调度理论 | L47–L66 | 偏 HLS/调度器；非手写 RTL 刚需 |
| Vivado HLS / 板级 / ILA / Microblaze / ELF 演示 | L45–L46、L57–L58、L67–L69、L78–L84、L89–L91 | 工具链与本仓 iverilog/Verilator 不对齐 |
| 软件编译、循环优化、软件流水线 | L70–L77 | 编译器侧；非 FPGA RTL 主线 |
| NoC 拓扑/路由/流控 | L93–L96 | 多核片上网络；当前不做 |
| 周作业 PDF | Archive → Assignments | 本路径是选讲，不交作业 |

---

## D. 建议观看顺序（压缩路径）

```
L12 → L13 → L15扫+L16 → L17–L18 → L28–L29 → L34–L35
    → L41–L42+L44 → L100
    →（选）L25 / L36 / L99 / L97–L98 / L101 / L85+L87
```

预计纯视频：**必看约 6–10 小时**（视倍速），选看再加若干小时。看完后若要动手，优先改 **P3** 为流水线/并行 FIR，或给 **P7** CIC 写清「迭代周期 vs 抽取率」注释——仍属本仓练习树，不必开新 Track C。

---

## E. 来源备注

- 讲次标题主要核自 Digimat 课程索引与 archive.nptel.ac.in 视频表（2019 NOC 档案）。
- Week 分组来自 archive 周目录与 onlinecourses 课程 layout 摘要；个别 DEMO 讲次在不同镜像上编号可能差 1，以 **标题** 为准。
- 本文件是 **选讲阅读指南**，不是仿真通过证据；仿真证据见各 `p*/PASS_EVIDENCE.txt`。
