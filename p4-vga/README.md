# P4：VGA 时序 + 色条

本地最小实现（640×480@60 经典时序）。不依赖 Project F / ZipCPU vgasim 源码；无 Vivado；无 SDL（验收靠 h/vsync 周期与 RGB assert）。

## 文件

| 文件 | 说明 |
|------|------|
| `vga_timing.v` | 行/场计数 → `hsync`/`vsync`（低有效）/`de`/`x`/`y` |
| `vga_bars.v` | 可见区 8 色条（白黄青绿品红红蓝黑） |
| `tb_vga.v` | 自检：行场周期、脉宽、active 像素/行数、色条采样 |
| `Makefile` | `make vga` / `make all` |

## 时序参数（像素时钟抽象，由 TB 驱动 `clk`）

| 段 | 水平 H | 垂直 V |
|----|--------|--------|
| 可见 | 640 | 480 |
| 前肩 FP | 16 | 10 |
| 同步 SYNC | 96 | 2 |
| 后肩 BP | 48 | 33 |
| **总计** | **800** | **525** |

- `H_SYNC` 起止：656..751（相对行内计数 0..799）
- `V_SYNC` 起止：490..491（相对场内行 0..524）
- 帧时钟数：`800 × 525 = 420000`

## 运行

```bash
cd /workspace/rtl-learning-plan/p4-vga
make all    # 非 0 即失败
make vga
```

需要：`iverilog` + `vvp`。SDL/Verilator 窗口为可选，本目录未启用。

## 验收

- `hsync` 周期 = 800；脉宽 = 96
- `vsync` 周期 = 420000；脉宽 = 2 行
- 每可见行 `de` 连续 640 像素；每帧 480 可见行
- 色条中心 RGB 与期望一致；消隐区 RGB=0
- 成功末行：`PASS vga_timing+vga_bars`，然后 `ALL PASS`
