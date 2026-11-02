# NPTEL 108105157 — Assignments 1–8 (cleaned OCR)

Source: Swayam quiz screenshots (image PDFs). Radio marks in the scans are **incorrect student attempts**; **Accepted Answers** below are the green course key, cross-checked against the rasterized PDFs.

Figures were redrawn as DFG edge lists in `assign-wN/check.py`. Original PDFs are **not** in git (`*.pdf` gitignored).

---

## Assignment 1 — Week 1 (SFG / DFG / DG / critical path)

**Due:** 2020-03-11

**Q1.** In a DFG, the delay of each path is doubled. Will the critical path  
(a) increase, (b) decrease, (c) remain same, (d) increase or decrease depending on the DFG.  
**Accepted: (c)** — delay-free edges stay delay-free.

**Q2.** Two \(N\times N\) matrices \(A,B\) are multiplied to produce \(C=AB\). Dimension of the resulting DG:  
(a) 2, (b) 3, (c) \(N\), (d) \(2N\).  
**Accepted: (b)** — indices \(i,j,k\).

**Q3.** Critical path of the linear-phase FIR in Figure 1:  
(a) six adders, (b) four multipliers, (c) one multiplier and one adder, (d) four multipliers and six adders.  
**Accepted: (c)**  
Figure 1 is a **transposed** linear-phase 7-tap with four unique coefficients \(b_0\ldots b_3\): \(x(n)\) broadcasts to four multipliers; adder chains are broken by \(D\).

**Q4.** If the above filter is transposed, the critical path becomes  
(a) four adders and one multiplier, (b) three adders and one multiplier, (c) four multipliers and three adders, (d) four multipliers and six adders.  
**Accepted: (a)** — direct-form linear-phase (pairing + mul + add cascade).

**Q5.** Which is NOT true?  
(a) retiming can reduce critical path in a DFG  
(b) a DG is always pipelined  
(c) intra-iteration dependence increases critical path  
(d) DG is preferred in array processing due to regularity  
**Accepted: (b)**

---

## Assignment 2 — Week 2 (retiming / iteration bound)

**Q1.** Correct statement about DFG vs DG:  
(a) DG shows only intra-iteration dependence  
(b) In DFG no delay is allowed on any edge  
(c) DG is preferred when regularity of the architecture is important  
(d) In DG, edges can contain multipliers  
**Accepted: (c)**

**Figure 1** (nodes A–H, each node time \(T\)): reconstructed edges  
`A→B:2D, A→C:0, B→D:0, B→E:0, D→F:0, C→E:0, C→F:1D, E→G:0, F→H:0, G→H:1D`.

**Q2.** Minimum clock period: (a) \(T\) (b) \(2T\) (c) \(3T\) (d) \(4T\).  
**Accepted: (d)** — delay-free paths B–D–F–H and A–C–E–G.

**Q3.** Dependence of H on D: (a) intra-iteration (b) inter-iteration (c) none (d) not enough information.  
**Accepted: (a)**

**Q4.** Change delays A–B and A–C to \(3D\) and \(D\). Output of H:  
(a) delayed 2 cycles (b) delayed 1 cycle (c) new unrelated signal (d) unchanged.  
**Accepted: (b)**

**Q5.** Reduce A–B from \(2D\) to \(D\), put \(D\) on B–D and B–E (were 0). Output of H:  
(a) delayed 2 (b) delayed 1 (c) new signal (d) unchanged.  
**Accepted: (d)** — cutset / \(r(B)=-1\).

**Q6.** Critical path of the **transposed** DFG: (a) \(T\) (b) \(2T\) (c) \(3T\) (d) \(4T\).  
**Accepted: (d)**

**Q7.** Feedback H→A: minimum delay on H–A to be feasible: (a) 1 (b) 0 (c) 2 (d) 4.  
**Accepted: (b)** — every A→H path already has ≥1 delay.

**Q8.** 2-D FIR \(y(n,m)=\sum_l\sum_r x(n-l,m-r)w(l,r)\). DG dimension:  
(a) 2 (b) 3 (c) 4 (d) \(M+N\).  
**Accepted: (c)**

---

## Assignment 3 — Week 3 (retiming LMS / unfolding prep)

**Figure 1:** `A(20)→B(10):0, B→C:D, C(10)→D(5):0, D→B:0, C→A:D`.

**Q1.** Critical path: (a) 15 (b) 30 (c) 25 (d) 10 u.t.  
**Accepted: (b)** — \(A+B=30\).

**Q2.** \(r(A)=0,r(B)=1,r(C)=2,r(D)=3\):  
(a) valid (b) valid and minimizes CP (c) invalid (d) does not minimize CP.  
**Accepted: (c)** — \(w'(D→B)=0+1-3<0\).

**Q3.** Two-stage retiming \(r_1=(0,1,1,1)\) then \(r_2=(1,1,0,1)\). Resulting CP:  
(a) 20 (b) 25 (c) 30 (d) 15.  
**Accepted: (b)**

**Q4.** Source S→B has 1 delay, \(r(B)=2\), \(r(S)=0\). New delay on S–B:  
(a) 1 (b) 2 (c) 3 (d) 0.  
**Accepted: (c)** — \(1+2-0=3\).

**Figure 2:** same topology as Assignment 2 Figure 1.  
Retiming \(r(A)=1,r(B)=0,r(C)=1,r(D)=1,r(F)=2,r(E)=1,r(G)=2,r(H)=3\). Each node \(T\).

**Q5.** CP after retiming: (a) \(4T\) (b) \(3T\) (c) \(2T\) (d) \(T\).  
**Accepted: (b)**

**Q6.** Output of node B delayed by: (a) 1 (b) 2 (c) 3 (d) 0 cycle.  
**Accepted: (d)** — \(r(B)=0\).

---

## Assignment 4 — Week 4 (unfolding / iteration bound)

**Figure 1:** two cascaded WDF adaptors. Adder = 1 u.t., multiplier = 2 u.t.

**Q1.** Critical path: (a) 12 (b) 10 (c) 5 (d) 8.  
**Accepted: (b)** — feed-forward through both sections.

**Q2.** Iteration bound: (a) 2 (b) 1 (c) 4 (d) 6.  
**Accepted: (a)**

**Figure 2:** `A(20)→B(10):0, B→C(5):D, C→D(10):0, D→E(10):0, D→B:0, E→C:D, C→A:D`.

**Q3.** CP: (a) 20 (b) 25 (c) 30 (d) 35.  
**Accepted: (c)**

**Q4.** Iteration bound: (a) 20 (b) 25 (c) 15 (d) 10.  
**Accepted: (b)** — loops B–C–D and C–D–E, \(T/D=25\).

**Q5.** Minimum CP achievable by retiming: (a) 15 (b) 20 (c) 10 (d) 25.  
**Accepted: (d)** — cannot beat IB.

**Q6.** Incorrect statement:  
(a) cutset retiming satisfies retiming theorem  
(b) cutset retiming can be used on any DFG  
(c) iteration bound of a loop cannot be achieved by retiming alone  
(d) an FIR can be pipelined by an arbitrary number of latches  
**Accepted: (b)**

---

## Assignment 5 — Week 5 (LMS / unfolding)

**Q1.** LMS cannot be pipelined because:  
(a) coefficients are adaptive (b) may not converge (c) delay-free error feedback for coefficient update (d) \(d(n)\) may be unavailable.  
**Accepted: (c)**

**Q2.** Delayed-LMS vs LMS convergence: (a) higher (b) at par (c) slower (d) depends on order.  
**Accepted: (c)**

**Q3.** In a \(J\)-unfolded system, an edge with \(w\) delays produces delay-free edges if:  
(a) \(w\le J\) (b) \(w<J\) (c) \(w\ge J\) (d) \(w>J\).  
**Accepted: (b)**

**Q4.** Loop with delay \(w\), unfold by \(J\): number of parallel loops is upper-bounded by  
(a) \(J-1\) (b) \(J\) (c) \(\min\{w,J\}\) (d) \(\max\{w,J\}\).  
**Accepted: (b)** — \(\gcd(w,J)\le J\).

**Figure 1:** `A(10) --3D--> B(20) --> C(20) --> D(10) --> A` (other delays 0).

**Q5.** Unfold \(J=2\), CP of unfolded DFG: (a) 20 (b) 40 (c) 60 (d) 50.  
**Accepted: (c)**

**Q6.** Then retime to minimize CP: (a) 20 (b) 30 (c) 40 (d) 50.  
**Accepted: (c)** — unfolded IB = 40.

**Q7.** First retime so A–B, B–C, C–D have one delay each and D–A has zero; unfold \(J=2\). CP:  
(a) 20 (b) 30 (c) 40 (d) 50.  
**Accepted: (c)**

---

## Assignment 6 — Week 6 (folding / digit-serial)

**Q1.** Bit-serial vs word-serial advantage: (a) faster input (b) less hardware (c) both (d) no switches.  
**Accepted: (b)**

**Q2.** 12-bit adder folded by \(N=12\), then unfolded by \(J=3\). Result is  
(a) digit-serial digit size 4 (b) bit-serial (c) digit-serial digit size 3 (d) hardware and delay optimized.  
**Accepted: (c)** — bit-serial unfolded by \(J\) has digit size \(J=3\). (Option (a) is \(N/J=4\), a common mix-up.)

**Figure 1 lattice**, folding factor 2. Sets:  
`SA1={A2,A1}` (A2 at \(2l+0\), A1 at \(2l+1\)), `SA2={A3,A4}`, `SM1={M1,M2}`, `SM2={M3,M4}`, `SM3={φ,M5}`.  
Adders pipelined by 1 latch, multipliers by 2.  
\(D_F(U\to V)=N w - P_U + v - u\).

**Q3.** Number of edges with **negative** folding delays: (a) 4 (b) 3 (c) 6 (d) 5.  
**Accepted: (c)**  
Checker omits the ambiguous `M1→A2` crossing (would make 7 negatives). See PLACEHOLDERS.

**Q4.** \(D_F(M4\to A3)\): (a) 2 (b) −2 (c) −3 (d) 0.  
**Accepted: (c)** — \(2\cdot0-2+0-1=-3\).

**Q5.** After retiming to avoid negatives, **incorrect** inequality:  
(a) \(r(A2)-r(M2)\le 0\)  
(b) \(r(A3)-r(A4)\le 0\)  
(c) \(r(M2)-r(A1)\le -1\)  
(d) \(r(A2)-r(M4)\le -1\)  
**Accepted: (d)** — edge A2→M4 has \(D_F=2\), so the bound is \(\le 1\).

**Q6.** Loop of 3 nodes, delay \(w_l\), compute \(t_l\), fold by \(N\), each node of time \(t\) pipelined by \(t\) latches.  
\(D_F(A\to B)+D_F(B\to C)+D_F(C\to A)=\)  
(a) \(w_l\) (b) \(w_l-t_l\) (c) \(N w_l - t_l\) (d) insufficient information.  
**Accepted: (c)**

---

## Assignment 7 — Week 7 (lifetime / polyphase / CSD)

**Table 1** (period 12). Variable \(T_i\): (input time, zero-latency output time)

| var | in | out0 | var | in | out0 |
|-----|----|------|-----|----|------|
| T0 | 0 | 0 | T6 | 6 | 3 |
| T1 | 0 | 6 | T7 | 6 | 9 |
| T2 | 2 | 0 | T8 | 8 | 3 |
| T3 | 2 | 6 | T9 | 8 | 9 |
| T4 | 4 | 0 | T10 | 10 | 3 |
| T5 | 4 | 6 | T11 | 10 | 9 |

**Q1.** Minimum latency so no variable has negative storage: (a) 7 (b) 5 (c) 4 (d) 3.  
**Accepted: (a)** — \(\max_i(\mathrm{in}_i-\mathrm{out0}_i)=7\) (T10).

**Q2.** Minimum registers to hold live variables: (a) 7 (b) 8 (c) 5 (d) 6.  
**Accepted: (b)**

**Q3.** \(x(n)=10\cos(2\pi n/8)\,u(n)\). 0-th polyphase component in a factor-of-8 decomposition:  
(a) \(10 u(n)\) (b) 0 (c) \(10\cos(2\pi n/4)u(n)\) (d) \(10\cos(2\pi/8)u(n)\).  
**Accepted: (a)** — \(x(8m)=10\cos(2\pi m)=10\).

**Q4.** Why the same polyphase complexity reduction does not apply to IIR:  
(a) polyphase impossible for IIR (b) IIR may be unstable  
(c) a polyphase component of an IIR impulse response is again IIR  
(d) IIR has infinitely many polyphase components  
**Accepted: (c)**

**Q5.** CSD of 29: (a) `10T0T0` (b) `10T00T` (c) `100T01` (d) `1T000T`.  
**Accepted: (c)** — \(32-4+1=29\).

**Q6.** Advantage of Baugh–Wooley over carry-ripple (Horner) multiplier:  
(a) less hardware (b) free from overflow in intermediate partial-product adds  
(c) wider range (d) easier to pipeline  
**Accepted: (b)**

---

## Assignment 8 — Week 8 (bit-serial / DA / CSD)

**Q1.** \(W\)-bit two’s complement, radix changed from 2 to 4:  
\(A=-a_{W-1}+a_{W-2}4^{-1}+\cdots+a_0 4^{-(W-1)}\) in the problem text.  
Range: (a) \(-1\) to \(1-2^{-(W-1)}\) (b) \(-1\) to \(1-4^{-(W-1)}\)  
(c) \(-1\) to \((1-2^{-2W})/3\) (d) \(-1\) to \(1-2^{-2W}\).  
**Accepted: (c)** — checker uses \(\sum_{k=1}^{W}4^{-k}=(1-4^{-W})/3=(1-2^{-2W})/3\).

**Q2.** Carry-save vs carry-ripple multipliers: (a) easier carry (b) less hardware (c) shorter critical path (d) less overflow.  
**Accepted: (c)**

**Q3.** Bit-serial FIR \(y(n)=-3x(n)+3x(n-1)\), wordlength \(W\), adders separated by pipeline latches. LSB of \(x(n)\) enters at cycle \(Wn+0\). LSB of \(y(n)\) shows up at  
(a) \(Wn+1\) (b) \(Wn+2\) (c) \(Wn+3\) (d) \(Wn+4\).  
**Accepted: (c)** — RTL: `lab-bitserial-fir/` (`METRIC LSB_LATENCY=3`).

**Q4.** DA of \(c_1 A+c_2 B\). If we store only the **magnitude** of \(c_1(a_i-\bar a_i)+c_2(b_i-\bar b_i)\), ROM addresses needed:  
(a) 2 (b) 3 (c) 4 (d) 1.  
**Accepted: (a)** — only \(|c_1+c_2|\) and \(|c_1-c_2|\).

**Q5.** CSD of −19: (a) `10T010` (b) `T0T01` (c) `T0101` (d) `T000T`.  
**Accepted: (b)** — \(-16-4+1=-19\).

**Q6.** Feasibility of bit-serial IIR depends on  
(a) only wordlength (b) only coefficients  
(c) wordlength and coefficients (d) wordlength, coefficients **and order**.  
**Accepted: (d)**
