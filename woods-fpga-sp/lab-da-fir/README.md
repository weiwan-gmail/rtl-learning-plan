# lab-da-fir — 分布式算法 FIR（Woods Ch6 §6.5）

固定系数 **H=[1,2,2,1]** 的 4 抽头 FIR，用 **Distributed Arithmetic**：按 bit-slice 查 LUT 再移位累加（Peled–Liu / White），适合 LUT 丰富的 FPGA。

## 文件

| 文件 | 说明 |
|------|------|
| `da_fir4.v` | 位串行 DA；收样后 8 拍累加 |
| `tb_da_fir4.v` | bit-exact vs MAC golden |
| `check_da_fir4.py` | DA ≡ MAC 互证 |
| `Makefile` | `make all` |

## 要点

- 输入用 `din[7:0]` **无符号 8-bit**（教学简化；书中 2's complement DA 可后续扩展）
- LUT：`addr={x0[b],x1[b],x2[b],x3[b]}` → 对应系数和
- 与 `../../p3-fir-nco` 并行 MAC FIR 对照：同一组系数，实现结构不同

## 运行

```bash
cd woods-fpga-sp/lab-da-fir && make all
```
