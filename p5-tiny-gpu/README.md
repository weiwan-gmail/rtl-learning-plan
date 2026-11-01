# P5：tiny-gpu matadd（iverilog + cocotb）

上游树以 **git submodule** 放在 `tiny-gpu/` → https://github.com/adam-maj/tiny-gpu.git（默认分支）。本目录只放包装与证据，不 vendor 上游源码 / `.venv`。

## 通过标准

- `./run_matadd.sh`（或子模块内 `make test_matadd`）exit 0
- cocotb：`TESTS=1 PASS=1 FAIL=0`
- 结果矩阵 C（data mem addr 16..23）== A+B
- 本机实测：`Completed in 178 cycles`；C=`[0,2,4,6,8,10,12,14]`（见 `PASS_EVIDENCE.txt`）

## 运行

```bash
# 仓库根目录已 clone 后：
git submodule update --init
cd p5-tiny-gpu
./run_matadd.sh
```

`run_matadd.sh` 会：

1. `cd tiny-gpu`
2. 若无 `.venv`：`python3 -m venv .venv && pip install 'cocotb<2'`
3. 设置 `PATH`（含 `~/bin` 的 `sv2v`）与 `LIBPYTHON_LOC`
4. 执行 `make test_matadd`

## 依赖

| 组件 | 说明 |
|------|------|
| iverilog 12 | |
| sv2v | 例如 `~/bin/sv2v`（zachjs/sv2v release） |
| cocotb 1.9.x | **勿用 2.x**（`--prefix` 已删，上游 Makefile 不兼容） |
| libpython3.x | 如 `apt install libpython3.13`；必要时设 `LIBPYTHON_LOC=...so.1.0` |

## 矩阵约定（官方 matadd）

- A @0..7 = `[0..7]`，B @8..15 = `[0..7]`，C @16..23 ← `C[i]=A[i]+B[i]`，`threads=8`

无 Vivado；P1–P4 未改。
