# P8 / I6：三角形光栅化（edge-function）

Track C **I6** 练习：把 **一个** 三角形写入小帧缓冲，与整数 / Python golden **逐像素一致**。接在 P4 VGA 之后。

## 参数

| 参数 | 默认 | 说明 |
|------|------|------|
| `W` × `H` | 64 × 48 | 帧缓冲分辨率 |
| `CORD_W` | 8 | 顶点坐标位宽（可越界，扫描时裁剪到 FB） |
| `COLOR_W` | 1 | 像素位宽（本 lab 填 1） |
| `E_W` | 20 | 有符号边函数 / 面积位宽 |

算法：整数 **edge function**  
`E(a→b,p)=(p.x−a.x)(b.y−a.y)−(p.y−a.y)(b.x−a.x)`。  
面积 `area=E(v0→v1,v2)`：`area>0` 时三点同号 `E≥0` 填入；`area<0` 时同号 `E≤0`；`area==0`（退化）不填。

## 文件

| 文件 | 说明 |
|------|------|
| `tri_raster.v` | DUT：CLEAR → SCAN → DONE；异步 `rd_data` |
| `tb_tri_raster.v` | 自检：CCW / CW / 退化 / 半屏外裁剪；失败 `$fatal`；写 `tri_case*.ppm` |
| `check_tri.py` | 独立 Python 模型；有 PPM 时与 TB 输出比对 |
| `Makefile` | `make tri` / `make all` |

## 运行

```bash
cd p8-tri-raster && make all
```

成功末行：`PASS tri_raster bit-exact ...`、`PASS check_tri.py ...`、`ALL PASS`。
