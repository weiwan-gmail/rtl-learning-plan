"""Random plant: both LMS and delayed-LMS converge near gain k."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly


def sat16(v):
    return max(-32768, min(32767, int(v)))


def s16(sig):
    return sat16(int(sig.value.signed_integer))


@cocotb.test()
async def test_dlms_random_gain(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.in_valid.value = 0
    dut.xin.value = 0
    dut.din.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    rng = 0xD1D50001

    def rnd():
        nonlocal rng
        rng = (rng * 1103515245 + 12345) & 0xFFFFFFFF
        return rng

    gain = 3
    for _ in range(400):
        x = int((rnd() % 17) - 8)
        d = sat16(gain * x)
        await FallingEdge(dut.clk)
        dut.xin.value = x
        dut.din.value = d
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)

    await FallingEdge(dut.clk)
    dut.in_valid.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    wL, wD = s16(dut.w0_l), s16(dut.w0_d)
    assert 2 <= wL <= 4, wL
    assert 2 <= wD <= 4, wD
    dut._log.info("PASS nptel-lab-dlms cocotb LMS_w0=%d DLMS_w0=%d", wL, wD)
