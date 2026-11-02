# N7 · NPTEL 选讲清单（免费）

**课程：** *Mapping Signal Processing Algorithms to Architectures*  
**课程 ID：** `108106149`（NOC19-EE70）  
**讲师：** Prof. Nitin Chandrachoodan · IIT Madras  
**性质：** **阅读 / 选讲指南**（不是仿真 lab；本目录无 DUT）

面向 Wei：你已走完 RISC-V 阶梯（tinyriscv→SERV）以及本仓 **P1–P7**（counter/add、FIFO、FIR/NCO、VGA、tiny-gpu matadd、PWM、CIC N=2 R=4）。本清单只挑「DSP 算法 → RTL/FPGA 架构」相关讲次，跳过你已在实验室练过的纯数字基础，以及 Vivado-HLS / 软件编译 / NoC 深挖等与当前 Verilator/iverilog 路径不对齐的内容。

## 免费怎么看

| 入口 | URL |
|------|-----|
| NPTEL 课程页 | https://nptel.ac.in/courses/108106149 |
| Archive（周次/视频/作业分栏） | https://archive.nptel.ac.in/courses/108/106/108106149/ |
| YouTube 播放列表（NPTEL-NOC IITM） | https://www.youtube.com/playlist?list=PLyqSpQzTE6M8XDxxMl4SNFiB6_U4kII8Z |
| 简介片 | https://www.youtube.com/watch?v=GlbJxX130iE |
| 讲次标题镜像（Digimat） | http://www.digimat.in/nptel/courses/video/108106149/108106149.html |

不必报名考试、不必买 MathWorks / Woods 付费内容。Archive 里「Video」与「Assignments」分开；本指南只指向 **Video** 讲次。

## 先修（本仓已覆盖）

- 同步 FIFO、定点 FIR/NCO、CIC 抽取、PWM、VGA timing、小型并行 matadd → 对应课程中的流式数据、MAC/流水线、资源复用、片上通信直觉。
- 数字逻辑与时序基础 → 可跳过 Week 1 多数复习讲。

## 怎么用本清单

1. 打开 [`LECTURE_PICKS.md`](LECTURE_PICKS.md)，按 **必看 → 选看** 顺序看；**可跳** 主题整块略过即可。
2. 每看一讲，对照本仓对应目录（如 `p3-fir-nco/`、`p7-cic/`）想一句：「若重写 DUT，架构会怎么变？」
3. 不要整课 103 讲刷完；目标是建立 **算法图 → 折叠/流水线/并行 RTL** 的词汇，而不是拿证书。
4. R1 MathWorks、R2 Woods 书仍为可选付费补强，**本 N7 路径不购买**。

## 本目录文件

| 文件 | 说明 |
|------|------|
| `README.md` | 本简介 |
| `LECTURE_PICKS.md` | 选讲表（核心交付） |
| `PASS_EVIDENCE.txt` | 来源 URL 与「非仿真 lab」说明 |
