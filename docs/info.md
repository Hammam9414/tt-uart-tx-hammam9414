# Tiny Inverter (tt_um_example)

## How it works
This design implements a 1-bit inverter on the TinyTapeout harness. When `ena=1`, `uo_out[0]` drives `~ui_in[0]`. All other outputs are held at `0`. When `ena=0`, **all** outputs are forced to `0`. The harness `clk` and `rst_n` pins are present but not used by this logic.

## Interface / pins
- `ui_in[0]`  — input bit (other `ui_in` bits are ignored)
- `uo_out[0]` — output bit = `~ui_in[0]` (only when `ena=1`)
- `ena`       — enables outputs; when `0`, `uo_out` is `8'h00`
- `clk`, `rst_n` — unused by this design
- `uio_*`     — unused (left as inputs, not driven)

## How to test
1. Drive `rst_n=1` and `ena=1`.
2. Set `ui_in[0]=0` → expect `uo_out[0]=1`.
3. Set `ui_in[0]=1` → expect `uo_out[0]=0`.
4. Set `ena=0` → expect `uo_out` remains `8'h00` regardless of input.

## Test strategy
A cocotb test starts the clock, releases reset, toggles `ui_in[0]`, and checks:
- `uo_out[0] == ~ui_in[0]` when `ena=1`
- `uo_out == 8'h00` when `ena=0`
