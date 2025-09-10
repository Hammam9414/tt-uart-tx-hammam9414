# test/test.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def basic(dut):
    """Reset, enable design, then verify uo_out[0] == ~ui_in[0]."""
    # Start 100 MHz clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset & init
    dut.rst_n.value = 0
    dut.ena.value   = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.ena.value   = 1
    await RisingEdge(dut.clk)

    # ui_in[0] = 0 -> uo_out[0] should be 1
    dut.ui_in.value = 0b0000_0000
    await RisingEdge(dut.clk)
    assert (int(dut.uo_out.value) & 1) == 1, f"Expected 1, got {int(dut.uo_out.value) & 1}"

    # ui_in[0] = 1 -> uo_out[0] should be 0
    dut.ui_in.value = 0b0000_0001
    await RisingEdge(dut.clk)
    assert (int(dut.uo_out.value) & 1) == 0, f"Expected 0, got {int(dut.uo_out.value) & 1}"

    # Disable -> outputs forced to 0
    dut.ena.value = 0
    await RisingEdge(dut.clk)
    assert int(dut.uo_out.value) == 0, f"Expected 0 when ena=0, got {int(dut.uo_out.value)}"
