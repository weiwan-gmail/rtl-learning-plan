# P2：同步 FIFO（iverilog）

本地练习，不依赖上游 fork。

## 文件

| 文件 | 说明 |
|------|------|
| `sync_fifo.v` | 同步环形 FIFO；参数 `WIDTH`/`DEPTH`（默认 8/8）；`wr_en`/`rd_en`/`din`/`dout`/`full`/`empty`/`count`；满写忽略、空读忽略 |
| `tb_sync_fifo.v` | 定向填满/排空、满写/空读、同时读写；2000 拍随机 + 软件队列 golden；`$fatal` |
| `Makefile` | `make fifo` / `make all` |

## 运行

```bash
cd /workspace/rtl-learning-plan/p2-sync-fifo
make all          # exit 0 才算过
make fifo         # 同 all
```

需要：`iverilog` + `vvp`（Verilog-2005）。

## 断言要点

- `fill_full` / `drain_empty`：深度填满再排空，dout 顺序 = 入队顺序
- `wr_full_ignored` / `rd_empty_ignored`：满写、空读不改 count、不破坏数据
- `count_vs_golden` / `dout_order`：随机流量下与软件队列一致
- `full_and_empty`：禁止同时断言（DEPTH>0）

成功打印 `PASS directed ...`、`PASS random ...`、`PASS tb_sync_fifo ...`，最后 `ALL PASS`。
