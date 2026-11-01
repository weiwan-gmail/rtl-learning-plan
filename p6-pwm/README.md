# P6：PWM（counter-compare）

自写 PWM 发生器，**counter-compare** 风格（非 phase-acc）。无 Vivado / 无上游核。

## 端口

| 信号 | 方向 | 说明 |
|------|------|------|
| `clk` / `rst` | in | 时钟、同步复位 |
| `period[W-1:0]` | in | 周期（时钟数，0 当作 1） |
| `duty[W-1:0]` | in | 高电平时钟数；0=常低；≥period=常高 |
| `pwm_out` | out | PWM 输出 |

计数器 `0 .. period-1` 循环；`pwm_out = (cnt < duty)`（寄存）。

## 文件

| 文件 | 说明 |
|------|------|
| `pwm.v` | DUT |
| `tb_pwm.v` | 自检：周期 / 占空高时 / 边沿；失败 `$fatal` |
| `Makefile` | `make pwm` / `make all` |

## 运行

```bash
cd p6-pwm && make all
```

成功末行：`PASS pwm` 与 `ALL PASS`。
