# lab-fft8 — 8 点基-2 DIT FFT（Woods Ch2 §2.3.2 / Fig 2.5）

定点 radix-2 **DIT**：自然序输入 → bit-reverse 存放 → 3 级×4 butterfly → 自然序输出。

## 文件

| 文件 | 说明 |
|------|------|
| `fft8.v` | 多周期 FFT；`in_ready`/`out_valid`/`done` |
| `tb_fft8.v` | 4 组向量 bit-exact |
| `check_fft8.py` | 同 Q15 旋转因子 / `>>>1` 缩放模型 |
| `Makefile` | `make all` |

## 定标

- 数据：signed 16-bit；旋转因子 **Q15**（`cos(π/4)=23170`）
- 每个 butterfly 输出 **算术右移 1**（三级共 /8），抑制位宽增长
- 复数乘：先 32-bit 乘加再 `>>>15`（与 TB/Python 一致）

## 运行

```bash
cd woods-fpga-sp/lab-fft8 && make all
```
