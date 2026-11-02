# P9 / I7：tiny-gpu matmul（2×2 SIMT）

在 P5 matadd 之上加深 **SIMT**：跑上游 [adam-maj/tiny-gpu](https://github.com/adam-maj/tiny-gpu) 自带的 **矩阵乘** kernel（`make test_matmul`）。

本目录**不**再 checkout 一份子模块，而是复用 `../p5-tiny-gpu/tiny-gpu`（同一 pin：`02b6c2ce223f606051a6d3a35ca942fbb1dffde2`）。

## 通过标准

- `make all` / `./run_matmul.sh` **exit 0**
- cocotb：`TESTS=1 PASS=1 FAIL=0`
- 2×2 结果 C @ data mem addr 8..11 与 `A·B` 一致  
  - A = `[[1,2],[3,4]]`，B = `[[1,2],[3,4]]` → C = `[[7,10],[15,22]]`
- 证据：`PASS_EVIDENCE.txt`、`sim_matmul.log`

## 运行

```bash
# 仓库根：
git submodule update --init
cd p9-tinygpu-matmul
make all
# 或
./run_matmul.sh
```

`run_matmul.sh` 会：

1. `cd ../p5-tiny-gpu/tiny-gpu`
2. 若无 `.venv`：`python3 -m venv .venv && pip install 'cocotb<2'`
3. 设置 `PATH`（含 `~/bin` 的 `sv2v`）与 `LIBPYTHON_LOC`
4. 执行 `make test_matmul`

## 依赖（与 P5 相同）

| 组件 | 说明 |
|------|------|
| iverilog 12 | |
| sv2v | 例如 `~/bin/sv2v`（zachjs/sv2v） |
| cocotb 1.9.x | **勿用 2.x**（`--prefix` 已删，上游 Makefile 不兼容） |
| libpython3.x | 如 `apt install libpython3.13` |

## 与 P5 对比

| | P5 matadd | P9 matmul |
|--|-----------|-----------|
| Kernel | `C[i]=A[i]+B[i]` | `C[row,col]=Σ_k A[row,k]*B[k,col]` |
| 维数 | 1×8 向量加 | **2×2** 矩阵乘，`threads=4`，内积循环 `N=2` |
| 指令 | ADD/LDR/STR | **MUL/DIV/SUB/CMP/BRn** + LDR/STR |
| Make | `test_matadd` | `test_matmul` |

无 Vivado；不改上游 RTL；不 fork 整仓。
