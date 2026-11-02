# P12 / A5：SymbiYosys 形式化（复用 P2 sync_fifo）

对已有 **P2** 同步 FIFO 做最小但真实的形式化证明（BMC + cover），不改 DUT、无板级、无 Vivado。

## 文件

| 文件 | 说明 |
|------|------|
| `fifo_props.v` | 形式化包装：实例化 `sync_fifo`（WIDTH=2, DEPTH=4）+ `assume`/`assert`/`cover` |
| `fifo_formal.sby` | SymbiYosys 配置（`bmc` + `cover`；引擎 `smtbmc z3`） |
| `Makefile` | `make all` → formal + cover + `PASS_EVIDENCE.txt` |
| `PASS_EVIDENCE.txt` | 一次绿跑摘录（工具版本 + PASS 行） |

DUT 路径：`../p2-sync-fifo/sync_fifo.v`（只读复用）。

## 证明的属性

在 **assume**「复位后不写满、不读空」下：

1. **互斥：** `!(full && empty)`
2. **一致性：** `count <= DEPTH`，`empty ↔ (count==0)`，`full ↔ (count==DEPTH)`
3. **无溢出/下溢：** `count` 随 `wr_en`/`rd_en` 精确 ±1 或保持（不环绕）
4. **Cover：** 可达 `full`；可达「曾经 full 后回到 empty」

## 依赖

| 工具 | 本机来源 | 备注 |
|------|----------|------|
| `yosys` | Debian `apt install yosys yosys-abc` | 需 `read_verilog -formal` |
| `sby` (SymbiYosys) | 从 [YosysHQ/sby](https://github.com/YosysHQ/sby) `sudo make install` | 安装到 `/usr/local/bin/sby` |
| `z3` | Debian `apt install z3` | `smtbmc` 后端 |
| `make`、`rg`（写证据用） | 系统包 | |

可选：OSS CAD Suite 一站式也可，但本 lab 按 apt + 上游 sby 文档化。

## 运行

```bash
cd p12-fifo-formal && make all
```

成功：退出码 0，出现 `DONE (PASS`、`Status: passed`、末行 `ALL PASS`；目录内有 `fifo_formal_bmc/PASS`、`fifo_formal_cover/PASS`。

```bash
make formal   # 仅 BMC
make cover    # 仅 cover
make versions # 打印 yosys/sby/z3
make clean
```

## 验收

- `make all` exit 0
- BMC depth 16 对上述 assert **PASS**
- cover 触达 full / empty-after-full
