# lab-div-nr — 无符号恢复式除法（Woods Ch3）

16÷16 restoring divider：`quot = numer/denom`，`rem = numer%denom`。  
目录名保留 `nr`（与非恢复式同属书中算术章节）；实现为 **restoring**（更易 bit-exact）。`denom=0` 置 `div_by_zero`。

```bash
cd woods-fpga-sp/lab-div-nr && make all
```
