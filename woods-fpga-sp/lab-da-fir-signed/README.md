# lab-da-fir-signed — 有符号 DA FIR（Woods Ch6 Eq.6.13+）

8-bit 2's complement 输入；比特串行 DA：LSB..bit6 正向累加，**符号位 bit7 减去** LUT×2⁷。

```bash
cd woods-fpga-sp/lab-da-fir-signed && make all
```
