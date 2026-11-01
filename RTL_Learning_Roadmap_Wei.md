# RTL 学习路线图（Verilator / iverilog 仿真友好）
**学习者：** Wei（中文）  
**已有阶梯：** tinyriscv → picorv32 → FemtoRV/`learn-fpga` → darkriscv → SERV  
**执行状态（2026-11-02 Asia/Shanghai）：** P1–P6 **DONE**（本地仿真绿 + 已 push）；**N5 PWM** 已落地为 **P6**；RISC-V 阶梯（tinyriscv→…→SERV）**DONE**。  
**产出性质：** PLAN + 已落地练习树（`p1`–`p6`）；后续 unpaid 工作仍按 PLAN 节奏推进，不强制一次开多个大核。  
**研究日 / 修订：** 2026-11-02（Asia/Shanghai）— P6/N5 PWM 落地；P1–P6 + RISC-V 阶梯 DONE；队列 N1–N7、§7 仍有效  
**仿真工具偏好：** Verilator（大设计 / C++ cosim）+ iverilog（小 DUT / 快速自检）+ GTKWave

---

## 0. 使用说明与边界

- **可并行：** 下列「经典 FPGA/RTL 基础」与 **Track B（DSP→SDR）**、**Track C（Graphics）** 多数可与现有 RISC-V fork 阶梯并行；**Track A** 与现有核解读强耦合，建议穿插。
- **仿真优先：** 每条 topic 都给出可在开源仿真器上跑的 DUT + 可观察验收标准。
- **引用原则：** 只列可核验的真实书籍/仓库/URL；不编造章节号以外的虚构文献。商业书注明「需购书/馆藏」，免费书给出官方入口。
- **避开：** Vivado-only IP、封闭 Soft IP、需付费仿真器才能复现的作业包。

---

## 1. Topic Ladder（主题阶梯）

### 1.1 Beginner 入门（Difficulty 1–2）

#### B1. Verilog/SystemVerilog 语法与组合/时序逻辑  
**中文名：** Verilog 基础与组合/时序电路  
**英文名：** Verilog Fundamentals — Combinational & Sequential Logic  
**Why：** 后续一切 RTL 的语言底座；避免「能抄核但不会写 TB」。  
**Difficulty：** 2  
**Repos：**
- ZipCPU 入门课：https://zipcpu.com/tutorial/ （Verilator + GTKWave + formal 入门）
- HDLBits 在线习题：https://hdlbits.01xz.net/ （即时仿真反馈）
- ShawnHymel `introduction-to-fpga`：https://github.com/ShawnHymel/introduction-to-fpga （0BSD；Part 3–7）
- 教材：Sarah L. Harris & David Money Harris, *Digital Design and Computer Architecture: RISC-V Edition*（Elsevier）配套站 https://pages.hmc.edu/harris/ddca/ddcarv.html （免费课件/视频/部分 HDL；正文需购书或馆藏）
**What to simulate：** DUT=`adder`/`counter`/`mux`；TB 目标：自检向量全过 + GTKWave 核对进位/溢出沿。  
**Est.：** 3–5 天（每天 2–3h）  
**Depends on：** 无（或与 tinyriscv 源码对照阅读并行）

#### B2. 可综合风格与 Testbench / 自检断言  
**中文名：** 可综合 RTL 风格与自检 Testbench  
**英文名：** Synthesizable RTL Style & Self-Checking Testbenches  
**Why：** 仿真绿不等于可综合；自检 TB 是 Verilator/iverilog 工作流核心。  
**Difficulty：** 2  
**Repos：**
- SiliconWit FPGA/Verilog 课（Lesson 1–2 思路）：https://siliconwit.com/education/fpga-digital-design-verilog/
- SSCS OSE Digital（iverilog/Verilator/Yosys 推荐）：https://sscs-ose.github.io/digital/
- Pong P. Chu, *FPGA Prototyping by Verilog Examples*（Wiley，2008）— 经典「例程+TB」写法（商业书；课程讲义常见）
**What to simulate：** DUT=`uart_tx` 或 `pwm`；TB：发固定字节流，用 `$display`/`assert` 对齐期望边沿计数。  
**Est.：** 2–4 天  
**Depends on：** B1

#### B3. FSM（Moore/Mealy）与协议解码  
**中文名：** 有限状态机与简单协议  
**英文名：** Finite-State Machines & Simple Protocol Decoders  
**Why：** UART/SPI/总线从设备/像素流水线的控制骨架。  
**Difficulty：** 2  
**Repos：**
- ZipCPU Tutorial Lesson 3（LED Walker FSM）：https://zipcpu.com/tutorial/
- ShawnHymel Part 5 FSM：https://github.com/ShawnHymel/introduction-to-fpga
**What to simulate：** DUT=`traffic_light` 或 `uart_rx` FSM；TB：非法序列应停在 error 态；合法序列输出字节与 golden 一致。  
**Est.：** 2–3 天  
**Depends on：** B1–B2

#### B4. 存储器、FIFO、双触发器同步  
**中文名：** BRAM / FIFO / 亚稳态与跨时钟入门  
**英文名：** Memory, FIFO, 2FF Synchronizers & CDC Intro  
**Why：** 缓存、外设、DSP 流、GPU 帧缓冲都依赖；CDC 是仿真里最易「假绿」的坑。  
**Difficulty：** 3（偏 Beginner→Intermediate 交界）  
**Repos：**
- ZipCPU Lessons 7–10（debounce / BRAM / UART RX / FIFO）：https://zipcpu.com/tutorial/
- ShawnHymel Part 8–10（BRAM / PLL 概念 / FIFO）：https://github.com/ShawnHymel/introduction-to-fpga
**What to simulate：** DUT=`sync_fifo`；TB：随机 push/pop，检查 empty/full 断言 + 数据顺序 golden 向量。  
**Est.：** 3–5 天  
**Depends on：** B2–B3

#### B5. 固定点算术与位宽规划  
**中文名：** 定点数与位宽/饱和  
**英文名：** Fixed-Point Arithmetic & Bit-Growth Planning  
**Why：** DSP/SDR/图形插值都用定点；位宽爆了仿真仍「看起来对」。  
**Difficulty：** 2  
**Repos：**
- Steven W. Smith, *The Scientist and Engineer's Guide to Digital Signal Processing*（**全书免费官方站**）：https://www.dspguide.com/ 或 https://e.dspguide.com/ （Ch.1–5 概念即可）
- ZipCPU「Simple FIR」：https://zipcpu.com/dsp/2017/08/19/simple-filter.html
**What to simulate：** DUT=`q15_mul_sat`；TB：边界用例（±1.0、溢出）与 C 参考模型 bit-exact 或容差比较。  
**Est.：** 1–2 天  
**Depends on：** B1

---

### 1.2 Intermediate 中级（Difficulty 3–4）

#### I1. 总线从设备：Wishbone / 简易 MMIO  
**中文名：** Wishbone / 简易外设总线  
**英文名：** Wishbone Slave & MMIO Peripherals  
**Why：** 把 UART/定时器/寄存器接到 RISC-V SoC 的必经之路（与 tinyriscv/picorv32 外设对照）。  
**Difficulty：** 3  
**Repos：**
- ZipCPU Tutorial Lesson 4–6（Wishbone slave → UART TX）：https://zipcpu.com/tutorial/
- 对照：tinyriscv 外设（Gitee）：https://gitee.com/liangkangnan/tinyriscv  
- picorv32：https://github.com/YosysHQ/picorv32 （ISC）
**What to simulate：** DUT=`wb_led_slave`；TB：写寄存器点亮模式位，读回一致；超时未 ACK 失败。  
**Est.：** 3–5 天  
**Depends on：** B3–B4；可与现有 RISC-V 阶梯并行对照

#### I2. 流水线 CPU 微结构：冒险、前递、停顿  
**中文名：** 流水线冒险 / 前递 / Stall  
**英文名：** Pipelined CPU — Hazards, Forwarding, Stalling  
**Why：** 「深挖 CPU」核心；把 FemtoRV/darkriscv 读懂而不是只跑。  
**Difficulty：** 4  
**Repos：**
- Harris & Harris, *DDCA RISC-V Edition* **Ch.7**（单周期→多周期→五级流水；配套 PDF 示例：https://pages.hmc.edu/harris/class/e85/DDCArv_Ch7.pdf ）
- Patterson & Hennessy, *Computer Organization and Design: RISC-V Edition* Ch.4（商业书；部分高校课程 PDF 流传，以馆藏/正版为准）
- BrunoLevy `learn-fpga` / FemtoRV：https://github.com/BrunoLevy/learn-fpga
- darkriscv：https://github.com/darklife/darkriscv
**What to simulate：** DUT=自研或裁剪的 5-stage RV32I 子集；TB：hazard 汇编程序（load-use、branch）与 Spike/参考模型 PC/寄存器 trace 对齐，或 Verilator C cosim 对比。  
**Est.：** 1–3 周  
**Depends on：** B1–B4 + 已有 tinyriscv/FemtoRV 阅读

#### I3. Cache / 存储层次入门  
**中文名：** Cache 与存储层次  
**英文名：** Caches & Memory Hierarchy Intro  
**Why：** 真实性能与「核跑通」差距的主因；Wally/工业核必备。  
**Difficulty：** 4  
**Repos：**
- Harris & Harris *DDCA RISC-V* Ch.8（cache/VM 概述；配套站同上）
- openhwgroup/cvw（CORE-V Wally）：https://github.com/openhwgroup/cvw （Apache-2.0 WITH SHL-2.1；Verilator 回归）
**What to simulate：** DUT=`direct_mapped_cache`（小规模）；TB：地址序列 miss/hit 计数与 golden 模型一致。  
**Est.：** 1–2 周  
**Depends on：** I2

#### I4. DSP 积木：NCO / FIR / CIC  
**中文名：** NCO、FIR、CIC 数字滤波器  
**英文名：** NCO, FIR, and CIC Building Blocks  
**Why：** SDR 前端与音频/传感处理的硬核积木；适合 Verilator + NumPy/C 黄金模型。  
**Difficulty：** 3  
**Repos：**
- ZipCPU NCO：https://zipcpu.com/dsp/2017/12/09/nco.html
- ZipCPU FIR 系列：https://zipcpu.com/dsp/2017/08/19/simple-filter.html 、https://zipcpu.com/dsp/2017/09/29/cheaper-fast-fir.html
- ZipCPU/dspfilters：https://github.com/ZipCPU/dspfilters （演示滤波器集合；注意许可证见 §4）
- Smith *DSP Guide*（免费）卷积/滤波章节：https://www.dspguide.com/
- Uwe Meyer-Baese, *Digital Signal Processing with Field Programmable Gate Arrays*（Springer）配套 Verilog：https://github.com/uwemeyerbaese/DSP_with_FPGAs_ed4 （**注意：** 大量例程面向 Vivado 工程；优先抽纯 RTL 在 iverilog/Verilator 跑，避开 Xilinx IP）
**What to simulate：** DUT=`fir_tap4` 或 `nco`；TB：已知正弦输入 → 频谱/采样序列与 C/NumPy 参考 SNR 或 bit-exact 对比。  
**Est.：** 1–2 周  
**Depends on：** B5；可与 RISC-V 阶梯并行

#### I5. VGA / 时序视频与帧缓冲  
**中文名：** VGA 时序与 Framebuffer  
**英文名：** VGA Timing & Framebuffers  
**Why：** DIY GPU 的显示后端；Verilator+SDL 可「看见」像素。  
**Difficulty：** 3  
**Repos：**
- Project F *Beginning FPGA Graphics*：https://projectf.io/posts/fpga-graphics/
- Verilator + SDL 仿真：https://projectf.io/posts/verilog-sim-verilator-sdl/
- 代码：https://github.com/projf/projf-explore （MIT）`graphics/fpga-graphics`
- ZipCPU/vgasim：https://github.com/ZipCPU/vgasim （VGA/framebuffer 仿真辅助）
**What to simulate：** DUT=`vga_timing` + 色条/`square`；验收：Verilator+SDL 窗口出现预期图案，或对 `rgb`/`hsync`/`vsync` 做行场计数 assert。  
**Est.：** 3–7 天  
**Depends on：** B3–B4；与 Track A 可并行

#### I6. 简易光栅 / 三角形填充（软件图形硬件化）  
**中文名：** 三角形光栅化入门  
**英文名：** Triangle Rasterization Basics  
**Why：** 从「显示色条」迈向「画几何」；GPU 管线前端。  
**Difficulty：** 4  
**Repos：**
- Project F graphics 更深章节（同 `projf-explore`）
- 小型参考：`simpleGPUCore`：https://github.com/mjkkirschner/simpleGPUCore （参考用；依赖评估后再仿真）
**What to simulate：** DUT=`fill_rect` 或最小 `tri_raster`；TB：写入 framebuffer 后 dump PPM/原始帧，与 CPU 参考渲染逐像素或哈希比对。  
**Est.：** 1–2 周  
**Depends on：** I5、B5

#### I7. SIMT / 最小 GPGPU 执行模型  
**中文名：** SIMT 与最小教学 GPU  
**英文名：** SIMT Mini-GPU (Educational)  
**Why：** 理解现代加速器「一指令多线程」；与 CPU 流水线对照。  
**Difficulty：** 4  
**Repos：**
- adam-maj/tiny-gpu：https://github.com/adam-maj/tiny-gpu （教学向；iverilog + cocotb；`make test_matadd` / `test_matmul`）
- （可选进阶）NyuziProcessor：https://github.com/jbush001/NyuziProcessor （Apache-2.0；SystemVerilog + Verilator；体量大）
**What to simulate：** DUT=tiny-gpu 顶层；TB：官方 matadd/matmul kernel 仿真绿 + 执行 trace/结果存储器与期望矩阵一致。  
**Est.：** 1–2 周（tiny-gpu）；Nyuzi 另计数周  
**Depends on：** I2 基础 + B4；与 Track A 中后期并行更佳

---

### 1.3 Advanced 高级（Difficulty 4–5）

#### A1. 工业/完整教学 SoC：流水线扩展、分支预测、特权态  
**中文名：** 完整 RISC-V SoC 微结构深潜  
**英文名：** Full RISC-V SoC Microarchitecture Deep Dive  
**Why：** 从「能跑 RV32I」到「理解缓存、预测、特权、Linux 可启动路径」。  
**Difficulty：** 5  
**Repos：**
- RVfpga（Imagination University Programme，注册免费领取教材/实验；含 Verilator 仿真路径）：https://www.imaginationtech.com/university/teaching-materials/
- Linux Foundation edX 课 *Computer Architecture with an Industrial RISC-V Core [RVfpga]*（LFD119x）：https://training.linuxfoundation.org/training/computer-architecture-with-an-industrial-riscv-core-rvfpga-lfd119x/
- 仿真插件参考：https://github.com/artecs-group/RVfpga-sim-addons
- Wally / cvw 教材路线（*RISC-V System-on-Chip Design*，Harris 等，Morgan Kaufmann 2025 路线）：https://github.com/openhwgroup/cvw
**What to simulate：** 官方 Verilator 回归 / RVfpga-Pipeline 可视化；自改：加一条自定义指令或改分支预测器，用性能计数器前后对比。  
**Est.：** 4–8 周  
**Depends on：** I2–I3 + 完成现有 RISC-V fork 阶梯大部分

#### A2. 位串行 / 极限面积核（SERV）对照  
**中文名：** 位串行 CPU（SERV）与面积权衡  
**英文名：** Bit-Serial CPU (SERV) & Area Tradeoffs  
**Why：** 同一 ISA，完全不同微结构；加深「实现≠架构」理解。  
**Difficulty：** 4  
**Repos：**
- olofk/serv：https://github.com/olofk/serv （ISC；FuseSoC + Verilator）
**What to simulate：** SERV 官方测试；对照 picorv32 同基准程序周期数（性能/面积定性笔记）。  
**Est.：** 3–7 天  
**Depends on：** 已有 SERV 阅读计划；I2 有助于对照

#### A3. SDR 链路：调制/解调闭环仿真  
**中文名：** 软件定义无线电闭环（AM/FM/QPSK）  
**英文名：** SDR Loopback — AM/FM/QPSK TX↔RX  
**Why：** 把 NCO/FIR/CIC 串成系统；强调采样率、时钟使能、流控。  
**Difficulty：** 5  
**Repos：**
- ZipCPU/sdr：https://github.com/ZipCPU/sdr （AM/FM/QPSK TX/RX；仿真可把 TX 环回 RX；**依赖 AutoFPGA**，见 §4）
- （生态更重）enjoy-digital/litedsp：https://github.com/enjoy-digital/litedsp （Migen/LiteX；NumPy golden + Verilator；**重依赖**）
**What to simulate：** 优先拆出单模块（如 CIC/NCO）用 Verilator；整链：`main_tb -d` 出 VCD，检查解调音频/比特流与激励相关（无信道模型时至少环回一致）。  
**Est.：** 2–4 周（模块先行）→ 整链更长  
**Depends on：** I4、B4；与 Track A 可并行

#### A4. 图形管线进阶 / 教学 GPU 渲染  
**中文名：** 变换·光照·纹理·深度缓冲（教学级）  
**英文名：** T&L, Texturing, Z-Buffer (Teaching GPU)  
**Why：** DIY GPU 完整故事线；ASIC/FPGA 均可参考。  
**Difficulty：** 5  
**Repos：**
- TinyGPU v2（光栅+纹理+Z，TinyTapeout/Basys3）：https://github.com/pongsagon/tt_um_pongsagon_tinygpu_v2 （Apache-2.0）
- Nyuzi（GPGPU+编译器+仿真）：https://github.com/jbush001/NyuziProcessor
**What to simulate：** 官方 cocotb/Verilator 测试；验收：渲染帧或 sceneview 与参考图/哈希一致（按仓库自带流程）。  
**Est.：** 3–6 周  
**Depends on：** I5–I7

#### A5. 形式化验证入门（可选增强）  
**中文名：** SymbiYosys / 形式化属性  
**英文名：** Formal Verification with SymbiYosys  
**Why：** FIFO/总线协议用形式化比随机 TB 更强；ZipCPU 工具链一脉相承。  
**Difficulty：** 4  
**Repos：**
- ZipCPU Tutorial（formal 贯穿）：https://zipcpu.com/tutorial/
- dspfilters `bench/formal`：https://github.com/ZipCPU/dspfilters
**What to simulate：** DUT=`fifo` 的 `assume`/`assert` 证明无溢出/无丢样；SymbiYosys PASS。  
**Est.：** 1–2 周  
**Depends on：** B4、I1

---

## 2. 三条 Track 序列（可与 RISC-V fork 阶梯并行标注）

### Track A — CPU 微结构深潜（Deep CPU）
| 顺序 | Topics | 与现有 RISC-V 阶梯关系 |
|------|--------|------------------------|
| A-1 | B1–B4 补齐 TB/FIFO/FSM（若缺口） | **并行**于 tinyriscv/picorv32 阅读 |
| A-2 | I1 Wishbone/MMIO | **并行**：给 tinyriscv 外设写对照 TB |
| A-3 | I2 流水线冒险 | **串入**：FemtoRV / darkriscv 精读阶段 |
| A-4 | A2 SERV 对照 | **对齐**阶梯末端 SERV |
| A-5 | I3 Cache | **在后**：picorv32 之后、Wally/RVfpga 之前 |
| A-6 | A1 RVfpga / Wally | **收官深潜**（阶梯完成后） |

**并行提示：** 在跑 FemtoRV/`learn-fpga` 实验的同时做 B4/I1；不要并行开两个「大核改流水线」任务。

### Track B — DSP → SDR
| 顺序 | Topics | 与现有 RISC-V 阶梯关系 |
|------|--------|------------------------|
| B-1 | B5 定点 | **高度可并行**（几乎不依赖 CPU） |
| B-2 | I4 NCO/FIR/CIC | **高度可并行** |
| B-3 | A5 formal（可选，先 FIFO/FIR） | **可并行** |
| B-4 | A3 SDR 环回（先拆模块再整链） | **可并行**；整链避开与大核仿真抢机器时间 |

**并行提示：** Track B 是「第二战场」首选；建议每周固定 DSP 半日，与 fork 阅读交错。

### Track C — Graphics / DIY GPU
| 顺序 | Topics | 与现有 RISC-V 阶梯关系 |
|------|--------|------------------------|
| C-1 | I5 VGA + Project F Verilator/SDL | **高度可并行** |
| C-2 | I6 矩形/三角光栅 | **可并行** |
| C-3 | I7 tiny-gpu SIMT | **建议**在 I2 有一定基础后 |
| C-4 | A4 TinyGPU v2 / Nyuzi | **收官**；与 A1 二选一先做，避免双大项目 |

**并行提示：** I5 与 tinyriscv 阶段即可开；I7/A4 勿与 Wally/RVfpga 同时开工。

```
时间轴示意（概念）：
RISC-V forks:  [tinyriscv][picorv32][FemtoRV][darkriscv][SERV]
Track A:         B*  I1 ---- I2 -------- A2 -- I3 -- A1
Track B:         B5 ==== I4 ============== A3 =======
Track C:            I5 ==== I6 == I7 ========= A4 ===
```

---

## 3. 规划后优先执行的 5 个仿真小项目（由小到大）

> 验收统一口径：**Verilator 或 iverilog 退出码 0（绿）** + **至少一种可观察检查**。

| # | 项目 | DUT | 工具 | 验收（Acceptance） | 预估 | 依赖 |
|---|------|-----|------|-------------------|------|------|
| **P1** | 自检计数器/加法器 | `counter8` 或 `add32` | iverilog | 绿 + TB `$fatal` 断言覆盖溢出回绕；可选 GTKWave 目视一次 | 2–4h | B1 |
| **P2** | 同步 FIFO | `sync_fifo`（深度≥8） | iverilog 或 Verilator | 绿 + 随机流量下数据顺序 golden 向量一致 + `overflow/underflow` 永不触发 assert | 1–2 天 | B4 |
| **P3** | 4-tap FIR 或 NCO | `fir4` / `nco`（可自 ZipCPU 文章重写教学版） | Verilator + C/NumPy 参考 | 绿 + 输出与参考模型 RMSE/SNR 达标（或定点 bit-exact） | 2–4 天 | B5、I4 入门 |
| **P4** | VGA 色条 / Project F `square` | `vga_timing`+图案生成 | Verilator + SDL（按 Project F） | 绿 + 窗口可见正确色条/方块 **或** `hsync/vsync` 周期计数 assert 通过 | 1–3 天 | I5 |
| **P5** | tiny-gpu matadd | tiny-gpu 顶层 | iverilog + cocotb（官方 `make test_matadd`） | 绿 + 结果存储器与期望矩阵一致（仓库自带检查） | 2–5 天 | I7 入门；需 sv2v/cocotb |
| **P6** | PWM 发生器 | `pwm`（counter-compare） | iverilog | 绿 + `period`/`duty`/边沿 `$fatal` 自检；`PASS pwm` | 0.5–1 天 | B2；N5 落地 |

**执行顺序理由：** P1–P2 固化仿真纪律 → P3 打开 DSP 黄金模型习惯 → P4 打开「可视化」验收 → P5 第一次碰并行执行模型；全部不依赖 Vivado。

**P1–P6 状态：** 全部 **DONE**（本地 + 已 push；P6=`p6-pwm/` counter-compare）。下面是接着要做的练习队列。

### 接着要做的练习队列

| # | 项目 | 说明 | 备注 |
|---|------|------|------|
| **N1** | picorv32 Verilator + 教程 | fork `develop`，按仓库/社区教程跑通仿真与自检 | RISC-V 阶梯 **下一步（进行中）** |
| **N2** | learn-fpga / FemtoRV 精读 + 仿真 | BrunoLevy `learn-fpga`：读文档、跑官方仿真路径 | N1 之后 |
| **N3** | darkriscv | 精读 + 仿真对照 | N2 之后 |
| **N4** | SERV | `olofk/serv` 官方测试；与 picorv32 周期数定性对照 | 阶梯末端 |
| **N5** | **PWM** 自检 DUT | 帖工作向需求；iverilog；**counter-compare**（已选）；`duty`/`period`/边沿 assert | **DONE → P6** |
| **N6** | 读 R3 选讲 + 自写小型 FFT **或** CIC 其一 | 加深 Track B；免费 NPTEL 选听即可 | 与 N1–N4 可交错 |
| **N7** | （可选付费）R1 MathWorks；并行读 R2 架构章 | 不阻塞开源练习队列 | 有预算再开 |

---

## 4. 许可证与重依赖注意事项

| 资源 | 许可（据公开仓库/站点） | 重依赖 / 规避点 |
|------|-------------------------|-----------------|
| ShawnHymel/introduction-to-fpga | 0BSD | 轻；教学友好 |
| YosysHQ/picorv32 | ISC | 开源友好 |
| olofk/serv | ISC | FuseSoC 推荐；Verilator OK |
| projf/projf-explore | MIT | Verilator + **libsdl2**（显示仿真） |
| openhwgroup/cvw (Wally) | Apache-2.0 WITH SHL-2.1 | Verilator；完整回归体积大 |
| jbush001/NyuziProcessor | Apache-2.0 | 自备工具链脚本；体量大 |
| adam-maj/tiny-gpu | 见仓库 LICENSE | **iverilog + cocotb + sv2v** |
| ZipCPU/dspfilters、ZipCPU/sdr、多数 ZipCPU RTL | **GPL/LGPL 系（以各仓为准）** | 衍生作品注意 copyleft；**sdr 需 AutoFPGA** |
| enjoy-digital/litedsp | LiteX 生态惯例（查仓内 LICENSE） | **Python/Migen/LiteX + Verilator**；非纯 Verilog 入门路径 |
| Meyer-Baese DSP_with_FPGAs_ed4 | 书配套代码 | 大量 **Vivado 工程**；只用纯 RTL 源、**避开 Xilinx DSP/IP 核** |
| RVfpga 教材包 | Imagination 教学许可（注册获取） | 按 IUP 条款使用；仿真可用 Verilator 路径 |
| Harris *DDCA* / Patterson *COD* / Lyons / Meyer-Baese 纸书 | 商业版权 | **不要传播盗版 PDF**；用官方配套站、馆藏或正版；Smith *DSP Guide* 为作者授权免费个人使用 |
| Pong Chu *FPGA Prototyping by Verilog Examples* | 商业书 | 同上；例程风格可学，勿依赖 Spartan-3 过时板级封闭流程 |

**明确避免：**
- Xilinx/Intel **封闭 IP**（FIR Compiler、DDR MIG 等）作为学习依赖  
- 「只能 Vivado 仿真才能过」的作业工程（可改为抽出 RTL + 自写 TB）  
- 未授权传播的版权 PDF 作为分发物（计划中只给**书名+作者+官方入口**）

**推荐轻量工具链（全程开源）：**  
`iverilog` / `verilator` + `gtkwave` + （综合可选）`yosys`/`nextpnr`；图形加 `libsdl2`；形式化可选 `sby`/SymbiYosys。

---

## 5. 经典教材 / 开放课程速查（真实引用）

| 类型 | 书名/课程 | 作者/机构 | 获取 |
|------|-----------|-----------|------|
| 数字设计+CPU | *Digital Design and Computer Architecture: RISC-V Edition* | Sarah Harris, David Harris | 购书；配套 https://pages.hmc.edu/harris/ddca/ddcarv.html |
| 计组 | *Computer Organization and Design: RISC-V Edition* | Patterson, Hennessy | 购书/馆藏 |
| SoC 实践 | *RISC-V System-on-Chip Design* + Wally | Harris 等 / OpenHW | 书商；仓 https://github.com/openhwgroup/cvw |
| DSP（免费） | *The Scientist and Engineer's Guide to DSP* | Steven W. Smith | https://www.dspguide.com/ |
| DSP+FPGA | *Digital Signal Processing with Field Programmable Gate Arrays* | Uwe Meyer-Baese | Springer；代码 https://github.com/uwemeyerbaese/DSP_with_FPGAs_ed4 |
| DSP 经典 | *Understanding Digital Signal Processing* | Richard G. Lyons | 商业书（Pearson） |
| Verilog 例程 | *FPGA Prototyping by Verilog Examples* | Pong P. Chu | Wiley 商业书 |
| 工具课 | ZipCPU Verilog+Verilator+Formal Tutorial | Dan Gisselquist | https://zipcpu.com/tutorial/ |
| 工业核课 | RVfpga | Imagination / Digilent 生态 | https://www.imaginationtech.com/university/teaching-materials/ |
| 路线图仓 | FPGA-ASIC-Roadmap | m3y54m | https://github.com/m3y54m/FPGA-ASIC-Roadmap |
| 中文核 | tinyriscv | liangkangnan | https://gitee.com/liangkangnan/tinyriscv |

---

## 6. 建议的近期节奏（PLAN；P1–P6 已执行）

1. **已完成：** P1–P6 本地仿真绿并 push（含 N5→P6 PWM）；RISC-V 阶梯 DONE；工具链 `iverilog`/`verilator`/`gtkwave` 已可用。  
2. **接着执行：** RISC-V 阶梯与 **N5/P6** 已完成；队列侧重 **N6** Track B 加深（及可选 N7）；N1–N4 作复习/对照即可。  
3. **并行阅读：** FemtoRV/`learn-fpga` 文档 + Smith DSP Guide Ch.1–5；中高级补强见 **§7**（R3 优先，R1/R2 可选）。  
4. **Track 选择：** 若兴趣偏无线电 → 强化 Track B（N6/§7）；偏画面 → Track C 延伸；偏 CPU → 坚持 N1–N4 与现有 fork 对齐。  
5. **边界（本阶段仍适用）：** 练习目录本地新建即可；fork 仅限计划中的 RISC-V 阶梯（从 picorv32 起）；避开 Vivado-only 依赖「为了跑一个教学 FIR」。未付费的未来项保持 PLAN 语气，按需开 N7。

---

## 7. 中高级补强（来源：r/FPGA 2026-11 帖）

**帖子：** [Suggest worth it courses for intermediate to advanced FPGA (DSP/PWM/AI)?](https://www.reddit.com/r/FPGA/comments/1xkw9zt/suggest_worth_it_courses_for_intermediate_to/)（OP 问 DSP / PWM / AI on FPGA 课程；整理日 2026-11）

| ID | 项目 | 类型 | URL / 备注 |
|----|------|------|------------|
| **R1** | MathWorks *DSP for FPGAs* | 付费课 | https://www.mathworks.com/learn/training/dsp-for-fpgas.html — 帖内 DSP-on-FPGA 高频推荐 |
| **R2** | *FPGA-based Implementation of Signal Processing Systems* 2e（Woods, McAllister, Lightbody, Ying Yi） | 书 | 帖内 PDF 镜像：https://rfsoc.mit.edu/6S965/_static/F25/textbooks/fpga_signal_processing.pdf — **优先购书/馆藏**；镜像仅作参考 |
| **R3** | NPTEL *Mapping Signal Processing Algorithms to Architectures*（Nitin Chandrachoodan, IITM） | 免费课档案 | https://nptel.ac.in/courses/108106149 与 https://archive.nptel.ac.in/courses/108/106/108106149/ |
| **R4** | （降优先级）印度 PG cert / 再读一个 MTech | **Wei 跳过** | 帖内共识：更吃 **项目 + 应用深度**，不必再堆证书路径 |

**怎么用：** N6 优先吃 **R3** 选讲；有预算再开 **R1**，并行翻 **R2** 架构章。PWM 工作向缺口用 **N5** 自检 DUT 补，不依赖付费课。

---

*文档修订 — 2026-11-02 Asia/Shanghai — P1–P5 DONE；队列 N1–N7；§7 r/FPGA 补强*
