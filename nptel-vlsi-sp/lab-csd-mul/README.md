# lab-csd-mul — CSD 常系数乘法（A7 Q5，A8 Q5）

| 常数 | CSD | 移位加减 |
|------|-----|----------|
| 29 | `100T01` | `(x<<5)-(x<<2)+x` |
| −19 | `T0T01` | `-(x<<4)-(x<<2)+x` |

TB 对照 `x*k` bit-exact。

```bash
cd nptel-vlsi-sp/lab-csd-mul && make all
```
