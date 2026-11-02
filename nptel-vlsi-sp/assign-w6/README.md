# assign-w6 — Week 6 作业检查器

Digit-serial：12-bit 加法 fold N=12 再 unfold J=3 → digit size **3**（课程 Accepted (c)；选项 (a) 的 4=N/J 是干扰项）。

Lattice Figure 1 的折叠延迟按 Parhi 公式计算；`D_F(M4→A3)=-3`。图中 M1→A2 交叉边未计入（计入会变成 7 条负边，与 Accepted 的 6 不符）——见 `CHAPTER_MAP.md` OCR_GAP。

```bash
cd nptel-vlsi-sp/assign-w6 && make all
```
