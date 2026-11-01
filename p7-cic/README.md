# P7 / N6：CIC 抽取器（decimate-by-R）

自写 **2 级 CIC**（Cascaded Integrator-Comb），教学用；无 ZipCPU / 无 Xilinx IP。

## 参数

| 参数 | 默认 | 说明 |
|------|------|------|
| `N` | 2 | 积分/梳状级数 |
| `R` | 4 | 抽取比 |
| `M` | 1 | 差分延迟（本 RTL 固定 1） |
| `IN_W` | 16 | 输入位宽（有符号） |
| `OUT_W` | 20 | 输出位宽；`IN_W + N·log2(R·M)` |

增益：`(R·M)^N = 16`。

## 延迟

复位后每收满 **R** 个 `in_valid` 样本，在该时钟沿寄存器输出一拍：`out_valid` 与 `dout` 同拍有效。积分器同拍级联；梳状在 strobe 同拍级联后寄存。

## 文件

| 文件 | 说明 |
|------|------|
| `cic_decim.v` | DUT |
| `tb_cic_decim.v` | 自检：与整数 golden **bit-exact**；失败 `$fatal` |
| `check_cic.py` | 独立 Python 模型（DC 增益 + 长度） |
| `Makefile` | `make cic` / `make all` |

## 运行

```bash
cd p7-cic && make all
```

成功末行：`PASS cic_decim bit-exact ...`、`PASS check_cic.py ...`、`ALL PASS`。
