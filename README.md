# RTL 学习阶梯（P1–P12）

Wei 的 Verilator / iverilog 动手练习树。路线说明见 [`RTL_Learning_Roadmap_Wei.md`](RTL_Learning_Roadmap_Wei.md)。

- **进度：** P1–P12 已完成（本地绿 + 已 push）；**N5 PWM → P6**、**N6 CIC → P7**、**Track C I6 → P8** 三角形光栅、**I7 → P9** tiny-gpu **matmul**、**I5×I6 → P10** VGA+三角 FB、**Track B A3-lite → P11** SDR 环回（NCO→FIR→CIC）、**A5 → P12** SymbiYosys FIFO formal 已落地。RISC-V 阶梯已完成；**N7** = 免费 NPTEL 选讲清单（DONE）→ [`n7-nptel-mapping-sp/`](n7-nptel-mapping-sp/)。**R2/Woods** 书 → RTL 仿真 Batch 1–4（DONE，RTL 课轨完成）→ [`woods-fpga-sp/`](woods-fpga-sp/)（17 labs：…+sqrt/LNS/SGR；Vivado/HLS PLACEHOLDER）。**NPTEL 108105157 VLSI Signal Processing** → [`nptel-vlsi-sp/`](nptel-vlsi-sp/)（10 RTL labs + 8 周作业检查器）。其余练习队列与中高级补强见路线图「接着要做的练习队列」与 **§7**。

## 阶梯

| 目录 | 内容 | 跑法 |
|------|------|------|
| `p1-counter-add/` | 8-bit 计数器 + 32-bit 加法器 | `cd p1-counter-add && make all` |
| `p2-sync-fifo/` | 同步 FIFO | `cd p2-sync-fifo && make all` |
| `p3-fir-nco/` | FIR4 + NCO | `cd p3-fir-nco && make all` |
| `p4-vga/` | VGA timing + color bars | `cd p4-vga && make all` |
| `p5-tiny-gpu/` | 上游 [adam-maj/tiny-gpu](https://github.com/adam-maj/tiny-gpu) matadd（子模块） | 见下 |
| `p6-pwm/` | PWM（counter-compare）自检 | `cd p6-pwm && make all` |
| `p7-cic/` | CIC 抽取（N=2,R=4,M=1）bit-exact | `cd p7-cic && make all` |
| `p8-tri-raster/` | 三角形光栅（edge-function，64×48） | `cd p8-tri-raster && make all` |
| `p9-tinygpu-matmul/` | tiny-gpu **2×2 matmul**（复用 P5 子模块；I7） | `cd p9-tinygpu-matmul && make all` |
| `p10-vga-tri/` | P4 VGA 时序 + P8 三角 FB（NN×10） | `cd p10-vga-tri && make all` |
| `p11-sdr-loop/` | Track B：NCO→FIR→CIC 教学环回 | `cd p11-sdr-loop && make all` |
| `p12-fifo-formal/` | A5：SymbiYosys formal（复用 P2 FIFO） | `cd p12-fifo-formal && make all` |
| `woods-fpga-sp/` | Woods FPGA SP 书 → RTL labs（Batch 1–4，17 labs，课轨完成） | `cd woods-fpga-sp && make all` |
| `nptel-vlsi-sp/` | NPTEL 108105157 VLSI SP（Chakraborty）→ 10 RTL labs + Week1–8 作业检查器 | `cd nptel-vlsi-sp && make all` |
| `verilator-wrap/` | **Optional** Verilator C++ TBs (separate trees; original `make` unchanged) | `cd verilator-wrap && make all` |
| `cocotb-wrap/` | **Optional** cocotb+Verilator (LMS/CORDIC/DA/FIR random goldens only) | `cd cocotb-wrap && make venv && make all` |
| `cmake-system/` | **Optional** CMake + 系统 Verilator（无 Conan；全 wrap 矩阵 sim / sim-fail） | `cmake -S cmake-system -B build-system && cmake --build build-system --target sim` |
| `cmake-conan/` | **Optional** CMake + Conan 2 本地 Verilator recipe（withlimon / 系统 kit） | 见 [`cmake-conan/README.md`](cmake-conan/README.md) |

依赖：`iverilog`（P1–P11）、`make`、`python3`（P3/P7/P8/P11）。P5/P9 另需 `sv2v`、`python3-venv`、`cocotb<2`、`libpython`。**P12** 另需 `yosys`、`sby`（SymbiYosys）、`z3`（见 `p12-fifo-formal/README.md`）。

## P5 快速开始

```bash
git clone --recurse-submodules https://github.com/weiwan-gmail/rtl-learning-plan.git
cd rtl-learning-plan/p5-tiny-gpu
# 若已 clone 未带子模块：
#   git submodule update --init
./run_matadd.sh
```

脚本会在 `tiny-gpu/` 子模块内建 `.venv` 并跑 `make test_matadd`。通过证据见 `p5-tiny-gpu/PASS_EVIDENCE.txt`。

## P6 快速开始

```bash
cd rtl-learning-plan/p6-pwm && make all
```

通过证据见 `p6-pwm/PASS_EVIDENCE.txt` / `sim_log.txt`。

## P7 / N6 快速开始

```bash
cd rtl-learning-plan/p7-cic && make all
```

通过证据见 `p7-cic/PASS_EVIDENCE.txt` / `sim_log.txt`（bit-exact）。


## P8 / I6 快速开始

```bash
cd rtl-learning-plan/p8-tri-raster && make all
```

通过证据见 `p8-tri-raster/PASS_EVIDENCE.txt`（edge-function，与 Python golden 逐像素一致）。


## P9 / I7 快速开始

```bash
git submodule update --init
cd rtl-learning-plan/p9-tinygpu-matmul
make all
```

复用 `p5-tiny-gpu/tiny-gpu` 子模块跑官方 `make test_matmul`（2×2）。通过证据见 `p9-tinygpu-matmul/PASS_EVIDENCE.txt`。

## P10 / I5×I6 快速开始

```bash
cd rtl-learning-plan/p10-vga-tri && make all
```

复用 `p4-vga/vga_timing.v` + `p8-tri-raster/tri_raster.v`；640×480 时序下最近邻放大 64×48 FB。通过证据见 `p10-vga-tri/PASS_EVIDENCE.txt`。

## P11 / Track B 快速开始

```bash
cd rtl-learning-plan/p11-sdr-loop && make all
```

复用 `p3-fir-nco/{nco,fir4}.v` + `p7-cic/cic_decim.v`：NCO/DC → FIR → CIC 抽取；DC settle + tone RMSE/SNR bit-exact。通过证据见 `p11-sdr-loop/PASS_EVIDENCE.txt`。

## P12 / A5 快速开始

```bash
cd rtl-learning-plan/p12-fifo-formal && make all
```

复用 `p2-sync-fifo/sync_fifo.v`；SymbiYosys BMC+cover（`smtbmc z3`）证明 empty/full 互斥、count 一致、assume 下无溢出/下溢。依赖与安装见 `p12-fifo-formal/README.md`。通过证据见 `p12-fifo-formal/PASS_EVIDENCE.txt`。


## Woods / R2 快速开始

```bash
cd rtl-learning-plan/woods-fpga-sp && make all
```

章映射 / 占位符 / 后续批次：[`woods-fpga-sp/CHAPTER_MAP.md`](woods-fpga-sp/CHAPTER_MAP.md)、[`PLACEHOLDERS.md`](woods-fpga-sp/PLACEHOLDERS.md)、[`NEXT.md`](woods-fpga-sp/NEXT.md)。PDF 仅本地 `refs/`（gitignore），课程镜像 URL 见该目录 README。

## NPTEL 108105157 / VLSI SP 快速开始

```bash
cd rtl-learning-plan/nptel-vlsi-sp && make all
```

Chakraborty *VLSI Signal Processing*（L1–L39）→ 转置 FIR、IIR 重定时、DLMS、2/3-parallel FIR、折叠 biquad、比特串行 FIR、Baugh–Wooley、CSD、look-ahead IIR，外加 Week1–8 作业的 DFG/寿命检查器。映射见 [`nptel-vlsi-sp/CHAPTER_MAP.md`](nptel-vlsi-sp/CHAPTER_MAP.md)。未跑 Vivado。

## Optional Verilator / cocotb wraps

Separate trees — they do **not** change `cd <lab> && make` / `nptel-vlsi-sp` / `woods-fpga-sp` `make all`.

- [`verilator-wrap/`](verilator-wrap/) — C++ TBs for all 10 NPTEL RTL labs, 6 Woods labs, plus P3/P7/P11. PASS: `cd verilator-wrap && make all`. Evidence: [`verilator-wrap/PASS_EVIDENCE.md`](verilator-wrap/PASS_EVIDENCE.md).
- [`cocotb-wrap/`](cocotb-wrap/) — extra randomized Python goldens (LMS, DLMS, CORDIC, DA FIR, P3 FIR). PASS: `cd cocotb-wrap && make venv && make all`.

Windows (PC2023) uses the [withlimon/verilator-windows](https://github.com/withlimon/verilator-windows) build/layout (not a random unofficial drop) and **`verilator_bin.exe`** — not the extensionless Perl `verilator` (Explorer/CMD “Open with…”). See [`verilator-wrap/WINDOWS.md`](verilator-wrap/WINDOWS.md). Linux/mac: ordinary `verilator`.

## Optional CMake dual-tree（Make 路径不动）

与 [protosim-apb](https://github.com/weiwan-gmail/protosim-apb) 相同的 `cmake-system/` + `cmake-conan/` 布局；共用 [`cmake/RtlLabSim.cmake`](cmake/RtlLabSim.cmake) / [`cmake/PreferUnixGcc.cmake`](cmake/PreferUnixGcc.cmake) / [`cmake/labs.cmake`](cmake/labs.cmake)。编的是 **全部 19 个 verilator-wrap lab**（加 `sim-fail`），DUT 仍走原 lab 相对路径。添加 lab = `labs.cmake` 一行，两个 `CMakeLists.txt` 保持薄封装。`sim-fail` 为 inject-and-catch（故意写错 CSD golden，runner 只有抓到 `FAIL` 才算过）。**cocotb 仍仅 Make。** Woods 未 wrap 的 lab 仍仅 iverilog，见 [`verilator-wrap/SCOPE.md`](verilator-wrap/SCOPE.md)。

```bash
# 系统 Verilator（Linux VM 已证明）
cmake -S cmake-system -B build-system -DCMAKE_BUILD_TYPE=Release
cmake --build build-system --target sim
cmake --build build-system --target sim-fail
```

Windows PC2023（worker `D:\CursorWorker`，Conan 2.34 + withlimon `verilator_bin.exe`）：[`cmake-system/WINDOWS.md`](cmake-system/WINDOWS.md) 与 `cmake-system/build_sim.ps1` / `cmake-conan/build_sim.ps1`。

## 许可

P1–P4、P6–P8、P10–P12 为练习代码。P5/P9 上游 RTL 属 [adam-maj/tiny-gpu](https://github.com/adam-maj/tiny-gpu)（以该仓库 LICENSE 为准）；本仓库仅保留包装脚本与证据，不 vendoring 上游源码。P9 复用 P5 子模块，不二次 clone。
