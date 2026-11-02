# PLACEHOLDERS — 不适合 iverilog/Verilator 纯 RTL 仿真的章节

| 项 | 书中位置 | 原因 | stub |
|----|----------|------|------|
| 厂商 FPGA 架构细节（Stratix/Ultrascale/Zynq/…） | Ch5 | 依赖数据手册与厂商原语，非可移植 RTL | `ch05-vendor-fpga/PLACEHOLDER.md` |
| Vivado HLS / C→RTL | Ch7 §7.3 | 需 Xilinx Vivado；本仓库工具链为 iverilog | `ch07-hls-vivado/PLACEHOLDER.md` |
| Altera SDK for OpenCL | Ch7 §7.5 | 需 Intel/Altera OpenCL 工具链 | 同上 |
| Catapult / Impulse-C / LegUp 等 HLS | Ch7 §7.6 | 外部商业/研究 HLS | 同上 |
| MADF / 模型驱动加速器综合 | Ch10 | 需专用数据流工具链与综合流程 | `ch10-model-based/PLACEHOLDER.md` |
| QR-RLS 自适应波束形成完整阵列 | Ch11 | 体量大；**积木已做** `lab-givens2/`；完整阵列仍 stub | `ch11-beamformer-qr/PLACEHOLDER.md` |
| IPPro 软核 / k-means 大数据加速 | Ch12 | 软核+系统级，超出单模块 sim 范围 | `ch12-bigdata-softproc/PLACEHOLDER.md` |
| 动态电压缩放 / 工艺相关功耗 | Ch13 部分 | 需厂商功耗模型与布局后仿真 | （教程-only，无 stub 目录） |

**原则：** 占位符只说明「为何不做」与「若要做应长什么样」；不提交空壳 Vivado 工程，也不复制专有 IP。
