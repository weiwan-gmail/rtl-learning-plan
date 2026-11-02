# lab-rls1 — 1-tap RLS（Woods Ch2）

遗忘因子 λ=1。权重 `w`、协方差 `P` 用 Q 格式（默认 scale=256）。  
激励 `d=3x` 时 `w→3`。除法在教学 DUT 里用 HDL `/`（截断向 0）；量产可换 `lab-div-nr` 序列除法器。完整 QR-RLS / SGR 阵列仍见 PLACEHOLDER。

```bash
cd woods-fpga-sp/lab-rls1 && make all
```
