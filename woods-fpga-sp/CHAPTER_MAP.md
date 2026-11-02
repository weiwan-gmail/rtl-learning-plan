# CHAPTER_MAP — Woods FPGA SP 2nd ed.

| 章 | 主题 | 处理方式 | lab 路径 | 状态 |
|----|------|----------|----------|------|
| 1 | Introduction to FPGAs | 教程-only | （见本目录 README） | DONE（导读） |
| 2 | DSP Basics — FIR | reuse:p3 | `../p3-fir-nco/` | reuse |
| 2 | DSP Basics — IIR | RTL lab | `lab-iir1/` | DONE |
| 2 | DSP Basics — IIR biquad DF-I | RTL lab | `lab-biquad/` | DONE |
| 2 | DSP Basics — FFT | RTL lab | `lab-fft8/` | DONE |
| 2 | DSP Basics — LMS | RTL lab | `lab-lms/` | DONE |
| 2 | DSP Basics — RLS (1-tap) | RTL lab | `lab-rls1/` | DONE |
| 2 | DSP Basics — QR-RLS / SGR 阵列 | PLACEHOLDER（完整阵列） | `ch11-beamformer-qr/` | stub |
| 2 | DSP Basics — CIC 相关抽取 | reuse:p7 | `../p7-cic/` | reuse |
| 2 | DSP Basics — NCO/SDR 链 | reuse:p11 | `../p11-sdr-loop/` | reuse |
| 3 | Arithmetic — CLA / array mult | RTL lab | `lab-arith/` | DONE |
| 3 | Arithmetic — CORDIC rotate+vector | RTL lab | `lab-cordic/` | DONE |
| 3 | Arithmetic — restoring divider | RTL lab | `lab-div-nr/` | DONE |
| 3 | Arithmetic — RNS(5,7)+CRT | RTL lab | `lab-rns35/` | DONE |
| 3 | Arithmetic — LNS / 开方 | PLACEHOLDER / 可选 | — | NEXT |
| 4 | Technology Review | 教程-only | — | DONE（导读） |
| 5 | Current FPGA Technologies | PLACEHOLDER-vendor | `ch05-vendor-fpga/` | stub |
| 6 | FPGA Impl — DA FIR (unsigned) | RTL lab | `lab-da-fir/` | DONE |
| 6 | FPGA Impl — DA FIR (signed 2's) | RTL lab | `lab-da-fir-signed/` | DONE |
| 6 | FPGA Impl — RCM / MCM 常系数 | RTL lab | `lab-rcm/` | DONE |
| 7 | Synthesis Tools (Vivado/HLS/OpenCL) | PLACEHOLDER-Vivado/HLS | `ch07-hls-vivado/` | stub |
| 8 | Architecture — retiming FIR demo | RTL lab | `lab-retiming-fir/` | DONE |
| 9 | Complex DSP IP Core Design | PLACEHOLDER / 教程-only | — | stub-row |
| 10 | Model-Based Accelerator | PLACEHOLDER | `ch10-model-based/` | stub |
| 11 | Adaptive Beamformer / QR | PLACEHOLDER + 积木 | `ch11-beamformer-qr/` + `lab-givens2/` | stub+DONE |
| 11 | Givens 2×2 apply (QR 积木) | RTL lab | `lab-givens2/` | DONE |
| 12 | Big Data / Soft Processors | PLACEHOLDER | `ch12-bigdata-softproc/` | stub |
| 13 | Low-Power FPGA | 教程-only | — | DONE（导读） |
| 14 | Conclusions | 教程-only | — | DONE（导读） |
| — | FIFO formal（配套验证） | reuse:p12 | `../p12-fifo-formal/` | reuse |

## 计数摘要（Batch 1–3）

| 类别 | 数量 |
|------|------|
| 新 RTL lab（本目录绿灯） | **14**（Batch1–3；cordic 含 vector） |
| reuse 已有 pN | **4**（p3/p7/p11/p12） |
| PLACEHOLDER stub 目录 | **5**（ch05/07/10/11/12） |
| 教程-only / 导读行 | **若干**（Ch1/4/13/14 等） |
