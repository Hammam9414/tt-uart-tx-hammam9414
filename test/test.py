import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLK_HZ = 100_000_000
BAUD   = 1_000_000
CLKS_PER_BIT = CLK_HZ // BAUD

def tx_bit(dut):
    return int(dut.uo_out.value) & 1  # TX on bit0

async def reset(dut):
    dut.ena.value = 0
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.ena.value = 1
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

async def pulse_start(dut):
    dut.uio_in.value = 1
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0

async def check_frame(dut, b):
    # wait for start
    while tx_bit(dut) != 0:
        await RisingEdge(dut.clk)
    # mid-start
    for _ in range(CLKS_PER_BIT // 2):
        await RisingEdge(dut.clk)
    assert tx_bit(dut) == 0
    # data bits LSB first
    for i in range(8):
        for _ in range(CLKS_PER_BIT):
            await RisingEdge(dut.clk)
        assert tx_bit(dut) == ((b >> i) & 1), f"bit{i} mismatch"
    # stop
    for _ in range(CLKS_PER_BIT):
        await RisingEdge(dut.clk)
    assert tx_bit(dut) == 1

@cocotb.test()
async def basic(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    await reset(dut)
    for v in (0x55, 0xA5, 0x00):
        dut.ui_in.value = v
        await pulse_start(dut)
        await check_frame(dut, v)
