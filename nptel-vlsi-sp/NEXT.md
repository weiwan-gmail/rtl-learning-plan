# NEXT — NPTEL 108105157 VLSI Signal Processing

RTL + 作业检查器本批已齐：`cd nptel-vlsi-sp && make all`。

## 可选后续（非阻塞）

- 硬件高效 2-/3-parallel 的乘法器减少恒等式（L30–L31）做成与直接多相对照的第二套 DUT
- Lattice folding 图中 M1→A2 交叉边：若找到更高清原图，把 `assign-w6` 的边表收成「无 OCR_GAP」
- Verilator + cocotb 包装（可选，非课轨）
- 完整 clustered vs scattered look-ahead 二阶 IIR（一阶二者相同，已覆盖）

Vivado / HLS：**不**做，见 `PLACEHOLDERS.md`。
