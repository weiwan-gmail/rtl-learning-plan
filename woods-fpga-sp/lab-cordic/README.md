# lab-cordic — 圆形旋转模式 CORDIC（Woods Ch3 §3.4.4）

教学 DUT：16 次迭代的 **circular rotation** CORDIC（Volder 统一迭代，见书 Eq. 3.18 / Table 3.7）。

## 文件

| 文件 | 说明 |
|------|------|
| `cordic_rotate.v` | 迭代 CORDIC；`start` 装载 → `done` 脉冲出结果 |
| `tb_cordic_rotate.v` | iverilog bit-exact vs 同 atan 表整数 golden |
| `check_cordic.py` | Python 同模型互校 |
| `Makefile` | `make all` |

## 定标

- `x,y`：有符号 16-bit；角度 `z`：**Q1.13**（弧度 × 2¹³）
- `atan(2^-i)` LUT 与 Python `ATAN_Q13` 完全一致
- **不补偿** CORDIC 增益 ≈1.64676；若要单位增益，输入 `x` 先乘 ≈0.607253（本 TB 用 9949 ≈ 0.607253×16384）

## 运行

```bash
cd woods-fpga-sp/lab-cordic && make all
```

成功末行：`PASS cordic_rotate` / `PASS check_cordic.py` / `ALL PASS`。
