# lab-arith — 定点加法/乘法（Woods Ch3 §3.3）

| 模块 | 说明 |
|------|------|
| `cla_add16.v` | 16-bit **carry-lookahead** 加法（4×4-bit CLA 级联） |
| `array_mult8.v` | 8×8→16 **array** 风格部分积移位加 |
| `tb_arith.v` | 与位宽加/乘 golden bit-exact |
| `check_arith.py` | Python CLA 互校 |

```bash
cd woods-fpga-sp/lab-arith && make all
```

对照：书中强调 FPGA 上加法器结构与乘法器部分积；本 lab 不用厂商 DSP 原语。
