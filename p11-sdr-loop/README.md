# P11 / Track B：SDR 教学环回（NCO → FIR → CIC）

把已有 **P3** NCO/FIR 与 **P7** CIC 串成最小 **TX→（基带处理）→RX 抽取** 仿真链。  
教学用 loopback，**不是**完整 QPSK modem；无板级、无 Vivado、无 MathWorks IP。

## 链路（一行）

`NCO 锯齿音 / DC 注入 → fir4 (H=[1,2,2,1]) → cic_decim (N=2,R=4,M=1) → dout`

## 文件

| 文件 | 说明 |
|------|------|
| `sdr_loop.v` | 顶层：实例化 `nco` + `fir4` + `cic_decim`；`src_is_dc` 选 DC 或 NCO |
| `tb_sdr_loop.v` | 自检：样本域整数 golden **bit-exact**；打印 DC settle / tone RMSE/SNR |
| `check_sdr_loop.py` | 独立 Python 链模型（DC 增益 + tone 自洽） |
| `Makefile` | 复用 `../p3-fir-nco/{nco,fir4}.v`、`../p7-cic/cic_decim.v`（不复制 RTL） |
| `PASS_EVIDENCE.txt` | 一次绿跑摘录 |

## 参数 / 增益

| 项 | 值 |
|----|-----|
| FIR | H=[1,2,2,1]，SHIFT=0，LATENCY=1；DC 稳态增益 `sum(H)=6` |
| CIC | N=2,R=4,M=1；增益 `(R·M)^N=16`；OUT_W=20 |
| 整链 DC | 稳态 `dout = A · 6 · 16 = 96A` |
| NCO | 相位累加锯齿 MSB（无正弦 LUT；与 P3 相同教学 stub） |

## 运行

```bash
cd p11-sdr-loop && make all
```

需要：`iverilog` + `vvp`，`python3`。成功末行含 `PASS sdr_loop ...`、`PASS check_sdr_loop.py`、`ALL PASS`。

## 验收

- DC 用例：末段输出 = `A*sum(H)*(R*M)^N`；整段与 golden **bit-exact**
- Tone 用例：`METRIC RMSE=0 SNR_dB=999`（999=+∞ / bit-exact）
- `make all` 退出码 0
