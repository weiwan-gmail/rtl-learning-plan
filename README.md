# RTL 学习阶梯（P1–P12）

Wei 的 Verilator / iverilog 动手练习树。路线说明见 [`RTL_Learning_Roadmap_Wei.md`](RTL_Learning_Roadmap_Wei.md)。

- **进度：** P1–P12 已完成（本地绿 + 已 push）；**N5 PWM → P6**、**N6 CIC → P7**、**Track C I6 → P8** 三角形光栅、**I7 → P9** tiny-gpu **matmul**、**I5×I6 → P10** VGA+三角 FB、**Track B A3-lite → P11** SDR 环回（NCO→FIR→CIC）、**A5 → P12** SymbiYosys FIFO formal 已落地。RISC-V 阶梯已完成；**N7** = 免费 NPTEL 选讲清单（DONE）→ [`n7-nptel-mapping-sp/`](n7-nptel-mapping-sp/)。**R2/Woods** 书 → RTL 仿真 Batch 1（DONE）→ [`woods-fpga-sp/`](woods-fpga-sp/)（CORDIC/IIR/DA-FIR/FFT8/LMS；Vivado/HLS 为 PLACEHOLDER）。其余练习队列与中高级补强见路线图「接着要做的练习队列」与 **§7**。

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
| `woods-fpga-sp/` | Woods FPGA SP 书 → RTL labs（Batch 1） | `cd woods-fpga-sp && make all` |

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

## 许可

P1–P4、P6–P8、P10–P12 为练习代码。P5/P9 上游 RTL 属 [adam-maj/tiny-gpu](https://github.com/adam-maj/tiny-gpu)（以该仓库 LICENSE 为准）；本仓库仅保留包装脚本与证据，不 vendoring 上游源码。P9 复用 P5 子模块，不二次 clone。
