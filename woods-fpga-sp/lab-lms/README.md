# lab-lms — 2 抽头 LMS（Woods Ch2 §2.5.3）

Widrow–Hoff LMS 教学核：

\[
y = w_0 x_0 + w_1 x_1,\quad
e = d - y,\quad
w_i \leftarrow w_i + (e \cdot x_i)\gg\mathrm{MUSHIFT}
\]

默认 `MUSHIFT=5`（μ≈1/32）。TB 做系统辨识：植物 `d=2x+x_{n-1}`，权重应收敛到 ≈(2,1)。

## 文件

| 文件 | 说明 |
|------|------|
| `lms2.v` | 2-tap LMS；LATENCY=1 |
| `tb_lms2.v` | bit-exact + 收敛检查 |
| `check_lms2.py` | Python 同模型 |
| `Makefile` | `make all` |

## 注意

- 步长过大 / 输入过大易饱和发散——本 lab 刻意用小信号；改参数后请先跑 `check_lms2.py`
- 书中 RLS / QR / beamformer（Ch11）远更复杂 → 见 `PLACEHOLDER` / `NEXT.md`

## 运行

```bash
cd woods-fpga-sp/lab-lms && make all
```
