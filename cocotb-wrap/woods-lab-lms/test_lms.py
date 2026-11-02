"""Randomized 2-tap LMS vs integer golden (Woods lab-lms)."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly

WSHIFT, MUSHIFT = 0, 5


def sat16(v):
    return max(-32768, min(32767, int(v)))


def s16(sig):
    return sat16(int(sig.value.signed_integer))


@cocotb.test()
async def test_lms_random_plant(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.in_valid.value = 0
    dut.xin.value = 0
    dut.din.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    gx0 = gw0 = gw1 = 0
    rng = 0xC0FFEE01

    def rnd():
        nonlocal rng
        rng = (rng * 1103515245 + 12345) & 0xFFFFFFFF
        return rng

    n = 0
    for k in range(256):
        x = int((rnd() % 17) - 8)
        d = sat16(2 * x + gx0)
        y = sat16((x * gw0 + gx0 * gw1) >> WSHIFT)
        e = sat16(d - y)
        nw0 = sat16(gw0 + ((e * x) >> MUSHIFT))
        nw1 = sat16(gw1 + ((e * gx0) >> MUSHIFT))
        await FallingEdge(dut.clk)
        dut.xin.value = x
        dut.din.value = d
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.out_valid.value) == 1, "out_valid"
        assert s16(dut.yout) == y, (s16(dut.yout), y)
        assert s16(dut.eout) == e, (s16(dut.eout), e)
        gx0, gw0, gw1 = x, nw0, nw1
        n += 1

    await FallingEdge(dut.clk)
    dut.in_valid.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    w0, w1 = s16(dut.w0_out), s16(dut.w1_out)
    assert 1 <= w0 <= 3 and 0 <= w1 <= 2, (w0, w1)
    dut._log.info("PASS woods-lab-lms cocotb n=%d w0=%d w1=%d", n, w0, w1)
