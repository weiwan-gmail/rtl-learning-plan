# P3：fir4（+ 可选 nco）— 定点流式 FIR

本地最小实现，不依赖 ZipCPU / Vivado IP。

## 文件

| 文件 | 说明 |
|------|------|
| `fir4.v` | 4 抽头流式 FIR；`in_valid`/`din[15:0]` → `out_valid`/`dout[15:0]` |
| `tb_fir4.v` | iverilog 自检：与同系数整数 golden **bit-exact**；打印 RMSE/SNR |
| `nco.v` | 可选：相位累加 NCO（锯齿 MSB，无正弦 LUT） |
| `tb_nco.v` | NCO bit-exact 自检 |
| `check_fir4.py` | NumPy 双模型互校（系数/饱和一致性） |
| `Makefile` | `make fir` / `make nco` / `make all` |

## 系数与定标

- 默认抽头 **H = [1, 2, 2, 1]**（有符号 16-bit 整数，**Q0**，非 Q15）
- 累加：16×16 乘积之和（34-bit），再 `>>> SHIFT`（默认 0），再 **饱和到 signed 16**
- 参数：`H0..H3`、`SHIFT` 可改；改 TB / `check_fir4.py` 中同名常量以保持 bit-exact

## 流水线

- **LATENCY = 1**：在采样沿 N 捕获 `in_valid`/`din`，该沿后 `out_valid`/`dout` 更新（单级注册 MAC）
- `in_valid=0` 时抽头保持，`out_valid=0`，`dout` 保持

## 运行

```bash
cd /workspace/rtl-learning-plan/p3-fir-nco
make all          # fir + nco + numpy；非 0 即失败
make fir          # 仅 FIR
make nco          # 仅 NCO
make numpy_check  # 仅 Python
```

需要：`iverilog` + `vvp`，`python3` + `numpy`。

## 验收指标

- RTL ↔ TB 整数 golden：**bit-exact**（mismatches=0）
- 打印 `METRIC RMSE=0 SNR_dB=999`（999 表示 +∞ / bit-exact）
- 成功末行：`PASS fir4` / `PASS nco` / `PASS check_fir4.py`，最后 `ALL PASS`
