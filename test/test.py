import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

def lsb_safe(dut):
    """Return 0/1 for uo_out[0], or None if X/Z."""
    v = dut.uo_out[0].value
    # cocotb 1.9: is_resolvable present; still guard binstr
    if hasattr(v, "is_resolvable") and not v.is_resolvable:
        return None
    s = v.binstr.lower()
    if "x" in s or "z" in s:
        return None
    return int(v)

async def expect_lsb(dut, exp, tries=20):
    for _ in range(tries):
        await RisingEdge(dut.clk)
        got = lsb_safe(dut)
        if got is not None:
            assert got == exp, f"Expected {exp}, got {got}"
            return
    assert False, "uo_out[0] stayed X/Z too long"

@cocotb.test()
async def basic(dut):
    """Reset, enable design, then verify uo_out[0] == ~ui_in[0]."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Known reset state
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 0
    dut.rst_n.value  = 0

    # Hold reset a bit at GL so flops settle
    await ClockCycles(dut.clk, 5)
    dut.ena.value    = 1
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    # Check invert of LSB
    dut.ui_in.value = 0
    await expect_lsb(dut, 1)   # ~0 = 1

    dut.ui_in.value = 1
    await expect_lsb(dut, 0)   # ~1 = 0

    # Optional: verify gating
    dut.ena.value = 0
    await ClockCycles(dut.clk, 2)
    got = lsb_safe(dut)
    if got is not None:
        assert got == 0, f"With ena=0, expected 0, got {got}"
