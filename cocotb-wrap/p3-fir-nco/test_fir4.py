"""Random FIR4 stream + sat corners vs integer golden H=[1,2,2,1]."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly


def sat16(v):
    return max(-32768, min(32767, int(v)))


def s16(sig):
    return sat16(int(sig.value.signed_integer))


def mac(a0, a1, a2, a3):
    return sat16(a0 * 1 + a1 * 2 + a2 * 2 + a3 * 1)


@cocotb.test()
async def test_fir4_random(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.in_valid.value = 0
    dut.din.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    gx0 = gx1 = gx2 = 0
    n = 0
    rng = 0xF1840001

    def rnd16():
        nonlocal rng
        rng = (rng * 1103515245 + 12345) & 0xFFFFFFFF
        v = rng & 0xFFFF
        return v - 0x10000 if v >= 0x8000 else v

    samples = [1000, 0, 0, 0, 0, 500, 500, 2000, -2000]
    samples += [rnd16() for _ in range(80)]
    samples += [32767, 32767, 32767, 32767, -32768, -32768, -32768, -32768]

    for samp in samples:
        y = mac(samp, gx0, gx1, gx2)
        gx2, gx1, gx0 = gx1, gx0, samp
        await FallingEdge(dut.clk)
        dut.din.value = samp
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)
        await ReadOnly()
        assert int(dut.out_valid.value) == 1
        assert s16(dut.dout) == y, (s16(dut.dout), y)
        n += 1
        if n % 11 == 0:
            await FallingEdge(dut.clk)
            dut.in_valid.value = 0
            await RisingEdge(dut.clk)

    dut._log.info("PASS p3-fir-nco cocotb fir4 n=%d", n)
