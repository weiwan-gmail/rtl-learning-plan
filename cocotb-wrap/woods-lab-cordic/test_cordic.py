"""Random rotate-mode CORDIC vs integer golden (Woods atan Q13 table)."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly

ATAN = [6434, 3798, 2007, 1019, 511, 256, 128, 64, 32, 16, 8, 4, 2, 1, 0, 0]


def wrap16(v):
    return ((int(v) + 0x8000) & 0xFFFF) - 0x8000


def gold_rotate(x, y, z, niter=16):
    x, y, z = int(x), int(y), int(z)
    for i in range(niter):
        xs, ys, at = x >> i, y >> i, ATAN[i]
        if z < 0:
            x, y, z = x + ys, y - xs, z + at
        else:
            x, y, z = x - ys, y + xs, z - at
        x, y, z = wrap16(x), wrap16(y), wrap16(z)
    return x, y, z


def s16(sig):
    return wrap16(int(sig.value.signed_integer))


@cocotb.test()
async def test_cordic_random_angles(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst.value = 1
    dut.start.value = 0
    dut.x_in.value = 0
    dut.y_in.value = 0
    dut.z_in.value = 0
    for _ in range(4):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    rng = 0xC0D1C001

    def rnd():
        nonlocal rng
        rng = (rng * 1103515245 + 12345) & 0xFFFFFFFF
        return rng

    n = 0
    vecs = [(9949, 0, 0), (9949, 0, 6434), (4000, 3000, 1000)]
    for _ in range(12):
        vecs.append((wrap16(rnd() % 8000) - 4000, wrap16(rnd() % 4000) - 2000, wrap16(rnd() % 4000) - 2000))

    for xin, yin, zin in vecs:
        xg, yg, zg = gold_rotate(xin, yin, zin)
        await FallingEdge(dut.clk)
        dut.x_in.value = xin
        dut.y_in.value = yin
        dut.z_in.value = zin
        dut.start.value = 1
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        dut.start.value = 0
        for _ in range(24):
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.done.value):
                assert s16(dut.x_out) == xg
                assert s16(dut.y_out) == yg
                assert s16(dut.z_out) == zg
                n += 1
                break
        else:
            raise AssertionError("cordic timeout")
        await FallingEdge(dut.clk)

    assert n == len(vecs)
    dut._log.info("PASS woods-lab-cordic cocotb n=%d", n)
