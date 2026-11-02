# PLACEHOLDERS — 不适合 iverilog 纯 RTL 的项

本课程 8 周内容几乎都能落成 DFG 检查器或小 DUT。下列仅占位，不假装跑过 Vivado。

| 项 | 位置 | 原因 |
|----|------|------|
| FPGA 布局后时序 / 厂商原语 | 课程未强制 | 需 Vivado/Quartus；本仓库工具链为 iverilog |
| HLS 把 MATLAB/C 折成折叠结构 | 无 | 需 Vivado HLS |
| 作业 PDF 原图入库 | `refs/`（gitignore `*.pdf`） | 图像 PDF 大且有版权；已把 OCR 写进 `assignments/ASSIGNMENTS_OCR.md` |

**OCR_GAP（图损坏但检查器仍绿灯）：**

- Assignment 6 Figure 1 lattice：`M1→A2` 交叉边未计入折叠表（计入会得到 7 条负延迟边，与 Accepted 的 6 不符）。`D_F(M4→A3)=-3` 与 digit-size 公式不依赖该边。
- Assignment 4 WDF 内部节点按「每节 Tm+3Ta=5、两节级联 CP=10、IB=2」建模，与 Accepted 数字一致；个别加法器是否在关键路径上从图里无法 100% 辨认。

原则：占位符只说明「为何不做」；不提交空壳 Vivado 工程。
