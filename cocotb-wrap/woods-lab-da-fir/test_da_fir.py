"""Random unsigned 8-bit DA FIR vs MAC golden H=[1,2,2,1]."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly

H = [1, 2, 2, 1]


def s16(sig):
    v = int(sig.value.signed_integer)
    return ((v + 0x8000) & 0xFFFF) - 0x8000


@cocotb.test()
async def test_da_random(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.in_valid.value = 0
    dut.din.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    taps = [0, 0, 0, 0]
    rng = 0xDAF10001

    def rnd():
        nonlocal rng
        rng = (rng * 1103515245 + 12345) & 0xFFFFFFFF
        return rng

    n = 0
    samples = [0, 1, 2, 3, 10, 255, 128] + [rnd() & 255 for _ in range(40)]
    for samp in samples:
        taps = [samp] + taps[:3]
        y = sum(H[i] * taps[i] for i in range(4))
        await FallingEdge(dut.clk)
        dut.din.value = samp
        dut.in_valid.value = 1
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.in_valid.value = 0
        got = False
        for _ in range(16):
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.out_valid.value):
                assert s16(dut.dout) == y, (s16(dut.dout), y)
                n += 1
                got = True
                break
        assert got, "da timeout"
    dut._log.info("PASS woods-lab-da-fir cocotb n=%d", n)
