# NEXT — 后续批次（Wei 继续）

按优先级建议：

1. **Ch3 定点加法器/乘法器教学 DUT**（carry-lookahead / array mult 对照）— 纯 RTL，易绿灯  
2. **Ch3 向量模式 CORDIC**（vectoring：给 (x,y) 求模角）— 扩 `lab-cordic`  
3. **Ch6 Reduced-Coefficient Multiplier (RCM)** 小例子（书 DCT 动机）  
4. **Ch2 二阶 IIR / Direct-Form II biquad** — 扩 `lab-iir1`  
5. **Ch2 有符号 DA FIR**（完整 2's complement DA，对齐书 Eq. 6.13+）  
6. **Ch8 retiming 小 demo**：同一 SFG 的未流水 vs cut-set 流水 FIR，对比吞吐（仍用 iverilog）  
7. **Ch11 极简 Givens/QR 2×2**（若精力够；否则保持 PLACEHOLDER）  
8. **Verilator + cocotb** 包装现有 lab（可选）

每完成一项：更新 `CHAPTER_MAP.md` 状态、补 `PASS_EVIDENCE.txt`、顶层 README 链过去。
