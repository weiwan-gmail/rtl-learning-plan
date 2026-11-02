# P10：VGA 时序 + 三角形帧缓冲（P4 × P8）

把 **P8** `tri_raster`（64×48 edge-function FB）接到 **P4** `vga_timing`（640×480@60）。  
策略：**最近邻放大**（SCALE=10，因 640/64=10、480/48=10）；可见区 RGB 来自 FB，消隐为黑。仿真 only（iverilog），无板级 / 无 Vivado。

## 文件

| 文件 | 说明 |
|------|------|
| `vga_tri.v` | 顶层：实例化 `vga_timing` + `tri_raster`；`de` 时 `fb(x/10,y/10)` → 白/黑 |
| `tb_vga_tri.v` | 自检：填 P8 case1 三角 → h/vsync 周期与脉宽 → 整帧 active 与 golden bit-exact → `frame.ppm` |
| `Makefile` | 复用 `../p4-vga/vga_timing.v`、`../p8-tri-raster/tri_raster.v`（不复制 RTL） |
| `PASS_EVIDENCE.txt` | 一次绿跑摘录 |

## 时序 / 缩放

| 项 | 值 |
|----|----|
| VGA | H=800（640+16+96+48），V=525（480+10+2+33）；帧时钟 420000 |
| FB | 64×48，1-bit |
| 映射 | `fb_x = x/10`，`fb_y = y/10`；白像素数 = `filled_fb × 100` |

三角形顶点（与 P8 case1 相同，CCW）：`(10,5) (50,8) (28,40)` → golden 填 **676** FB 像素 → VGA 可见白像素 **67600**。

## 运行

```bash
cd p10-vga-tri && make all
```

需要：`iverilog` + `vvp`。成功末行含 `PASS vga_tri sync+pixels bit-exact` 与 `ALL PASS`。可选产物 `frame.ppm`（64×48，由 VGA 采样各 FB 格中心写成，gitignore）。

## 验收

- `hsync` 周期=800、脉宽=96；`vsync` 周期=420000、脉宽=2 行
- 一整帧 active 区 RGB 与 edge-function golden **逐像素一致**
- `active_white_pixels == 676*10*10`
- `frame.ppm` 写出成功（eyeball）
