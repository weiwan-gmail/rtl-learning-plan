# lab-lns-mul — LNS 乘法演示（Woods Ch3）

对 `a,b ∈ 1..32`：`log2` Q8 LUT 相加，再用指数尾数 LUT 还原 `≈ a·b`。  
教学点：乘法 → 对数域加法。与真值最大绝对误差 ≤ 2（见 `check_lns_mul.py`）；RTL↔golden bit-exact。

```bash
cd woods-fpga-sp/lab-lns-mul && make all
```
