# test.py : cocotb test
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def basic_test(dut):
    """Simple test: reset, then drive in=0/1 and check out == ~in"""
    # Start clock (10 ns period = 100 MHz)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Drive input 0 -> expect out=1
    dut.in.value = 0
    await RisingEdge(dut.clk)
    assert dut.out.value == 1, f"Expected 1, got {dut.out.value}"

    # Drive input 1 -> expect out=0
    dut.in.value = 1
    await RisingEdge(dut.clk)
    assert dut.out.value == 0, f"Expected 0, got {dut.out.value}"
