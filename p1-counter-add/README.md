# P1：自检计数器 / 加法器（iverilog）

本地练习，不依赖上游 fork。

## 文件

| 文件 | 说明 |
|------|------|
| `counter8.v` | 8 位同步复位 + enable 计数器；`FF+1 → 00` 自然回绕 |
| `add32.v` | 32 位加法；`sum`/`cout`（无符号进位）/`ovf`（有符号溢出） |
| `tb_counter8.v` | 复位、使能冻结、回绕、再复位；`$fatal` 断言 |
| `tb_add32.v` | 边界向量 + 2000 随机；核对 sum/cout/ovf |
| `Makefile` | `make counter` / `make add` / `make all` |

## 运行

```bash
cd /workspace/rtl-learning-plan/p1-counter-add
make all          # 两者都过才 exit 0
make counter      # 仅计数器
make add          # 仅加法器
```

需要：`iverilog` + `vvp`（Verilog-2005）。

## 断言要点

- **counter8**：`reset_hold`、`en_low_stall`、`count_up`、`wrap_ff_to_00`、`en_freeze`、`sync_rst`
- **add32**：`zero_zero`、`max_plus_1`（进位）、有符号正/负溢出、随机 bit-exact

成功时终端打印 `PASS tb_counter8 ...` 与 `PASS tb_add32 ...`，最后 `ALL PASS`。
