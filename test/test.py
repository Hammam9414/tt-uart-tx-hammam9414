# test/test.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, with_timeout, First

CLK_HZ = 100_000_000
BAUD   = 1_000_000
CLKS_PER_BIT = CLK_HZ // BAUD  # 100

def tx_bit(dut) -> int:
    """
    Safely read TX (uo_out[0]).
    - If value is X/Z (unresolvable), treat it as idle=1.
    - Only the LSB (bit 0) is used.
    """
    v = dut.uo_out.value
    # If the BinaryValue is not resolvable, treat as idle-high
    if hasattr(v, "is_resolvable") and not v.is_resolvable:
        return 1
    # Work with binstr to avoid int() blowing up on XX... patterns
    binstr = v.binstr
    if "x" in binstr.lower() or "z" in binstr.lower():
        return 1
    return (int(v) & 1)

async def wait_clean_idle_high(dut, idle_cycles=CLKS_PER_BIT):
    """
    Wait until TX reads as 1 (idle) for 'idle_cycles' consecutive clk edges.
    This filters out any X/Z settling after reset.
    """
    good = 0
    while good < idle_cycles:
        await RisingEdge(dut.clk)
        if tx_bit(dut) == 1:
            good += 1
        else:
            good = 0

async def reset(dut):
    dut.ena.value   = 0
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # a few cycles with reset asserted
    await ClockCycles(dut.clk, 8)

    dut.ena.value   = 1
    dut.rst_n.value = 1

    # give DUT a couple cycles post-reset
    await ClockCycles(dut.clk, 4)

    # wait for a clean idle-high line (filters X/Z too)
    await wait_clean_idle_high(dut, idle_cycles=CLKS_PER_BIT // 2)

async def pulse_start(dut):
    # Assuming start is uio_in[0]; we only drive bit0 to avoid toggling other bits
    dut.uio_in.value = 1  # drives bit0=1, others 0 if vector width==1
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0

async def check_frame(dut, b: int):
    """
    Sample in the middle of each bit cell:
    - Wait for a FALLING EDGE (1->0) to detect start, ignoring initial X/Z
    - Half bit to mid-start
    - Then 1 bit to mid-bit0, then each subsequent bit cell
    """
    # Wait for a clean falling edge from idle-high to start=0, with timeout
    async def wait_start_fall():
        # ensure we are idling high first
        await wait_clean_idle_high(dut, idle_cycles=CLKS_PER_BIT // 4)
        # now wait until it goes low
        while tx_bit(dut) != 0:
            await RisingEdge(dut.clk)

    await with_timeout(wait_start_fall(), timeout_time=10_000, timeout_unit="ns")

    # Move to the middle of the start bit
    await ClockCycles(dut.clk, CLKS_PER_BIT // 2)
    assert tx_bit(dut) == 0, "start != 0"

    # 8 data bits, LSB first; sample in the middle of each bit
    for i in range(8):
        await ClockCycles(dut.clk, CLKS_PER_BIT)  # advance one full bit from mid of previous
        exp = (b >> i) & 1
        got = tx_bit(dut)
        assert got == exp, f"bit{i} mismatch: expected {exp}, got {got}"

    # Stop bit
    await ClockCycles(dut.clk, CLKS_PER_BIT)
    assert tx_bit(dut) == 1, "stop != 1"

@cocotb.test()
async def basic(dut):
    # cocotb drives the clock (tb.v does not)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())  # 100 MHz
    await reset(dut)
    for v in (0x55, 0xA5, 0x00):
        dut.ui_in.value = v
        await pulse_start(dut)
        await check_frame(dut, v)
