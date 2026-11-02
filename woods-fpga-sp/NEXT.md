# NEXT — Woods FPGA SP 后续

## RTL 仿真课轨：**完成**（Batch 1–4）

可 iverilog 绿灯的章节积木已齐；仅余 PLACEHOLDER / 可选包装。

### 已交付批次（摘要）

| Batch | 内容 |
|-------|------|
| 1 | CORDIC rotate、IIR1、DA-FIR、FFT8、LMS |
| 2 | CLA/array、CORDIC vector、RCM、biquad、signed DA、retiming、Givens2 |
| 3 | RLS1、restoring div、RNS(5,7) |
| 4 | sqrt16、LNS mul、SGR step（无 sqrt 消零积木） |

### 不再作为 RTL 待办

8. ~~Verilator + cocotb~~ — **可选**，非课轨阻塞  
11. 厂商 / Vivado / HLS — **保持** `PLACEHOLDERS.md`（不扩成假 lab）  
12. 完整多抽头 QR-RLS 阵列 — **PLACEHOLDER**；积木已有 `lab-givens2` + `lab-sgr2` + `lab-rls1`

跑全套：`cd woods-fpga-sp && make all`
