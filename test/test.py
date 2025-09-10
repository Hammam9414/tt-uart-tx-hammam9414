# test.py : cocotb test
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def basic_test(tt_um_example):
    """Simple test: reset, then drive in=0/1 and check out == ~in"""
    # Start clock (10 ns period = 100 MHz)
    cocotb.start_soon(Clock(tt_um_example.clk, 10, units="ns").start())

    # Apply reset
    tt_um_example.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(tt_um_example.clk)
    tt_um_example.rst_n.value = 1
    await RisingEdge(tt_um_example.clk)

    # Drive input 0 -> expect out=1
    tt_um_example.in.value = 0
    await RisingEdge(tt_um_example.clk)
    assert tt_um_example.out.value == 1, f"Expected 1, got {tt_um_example.out.value}"

    # Drive input 1 -> expect out=0
    tt_um_example.in.value = 1
    await RisingEdge(tt_um_example.clk)
    assert tt_um_example.out.value == 0, f"Expected 0, got {tt_um_example.out.value}"
