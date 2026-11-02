# lab-dlms — LMS vs Delayed-LMS（L10–L12，A5 Q1–2）

同一 μ（`MUSHIFT=6`）、1 抽头（模块名仍 `lms2`/`dlms2` 以对齐 woods 习惯）：

- `lms2.v`：立即用 `e(n) x(n)` 更新（不能流水：误差反馈无延迟）
- `dlms2.v`：`D=1`，用 `e(n-1) x(n-1)` 更新（可插入流水寄存器）

植物 `d=3x`。两者 `w` 都应到 ≈3；DLMS 理论上更慢（A5 Q2），本 TB 用足够样本让两边都进容差。

复用：`../../woods-fpga-sp/lab-lms/`（本目录自包含副本）。

```bash
cd nptel-vlsi-sp/lab-dlms && make all
```
