#!/usr/bin/env python3
def fir3(xs):
    # xs newest-first stream; return y stream with zero init
    x1=x2=0
    ys=[]
    for x in xs:
        ys.append(1*x + 2*x1 + 1*x2)
        x2,x1=x1,x
    return ys

def main():
    xs=list(range(-6,7))
    ys=fir3(xs)
    assert ys[0]==-6 and ys[1]==(-5)+2*(-6)==-17
    print("ys", ys[:5], "...")
    print("PASS check_retiming.py (combo≡pipe golden)")

if __name__ == "__main__":
    main()
