# RTL 学习阶梯（P1–P7）

Wei 的 Verilator / iverilog 动手练习树。路线说明见 [`RTL_Learning_Roadmap_Wei.md`](RTL_Learning_Roadmap_Wei.md)。

- **进度：** P1–P7 已完成（本地绿 + 已 push）；**N5 PWM → P6**、**N6 CIC → P7** 已落地。RISC-V 阶梯已完成；**N7** = 免费 NPTEL 选讲清单（DONE）→ [`n7-nptel-mapping-sp/`](n7-nptel-mapping-sp/)。其余练习队列与中高级补强见路线图「接着要做的练习队列」与 **§7**。

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

依赖：`iverilog`（P1–P7）、`make`、`python3`（P3/P7）。P5 另需 `sv2v`、`python3-venv`、`cocotb<2`、`libpython`。

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

## 许可

P1–P4、P6–P7 为练习代码。P5 上游 RTL 属 [adam-maj/tiny-gpu](https://github.com/adam-maj/tiny-gpu)（以该仓库 LICENSE 为准）；本仓库仅保留包装脚本与证据，不 vendoring 上游源码。
