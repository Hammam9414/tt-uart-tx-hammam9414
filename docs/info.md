# Tiny Inverter (tt_um_example)

## How it works
This design is a 1-bit combinational inverter connected to the TinyTapeout harness. When the design is enabled (`ena=1`), `uo_out[0]` drives the inverse of `ui_in[0]`. All other outputs are held at 0. When `ena=0`, all outputs are forced to 0 per TT rules. The clock and reset pins are present to match the harness but are not used by the logic.

## Interface / pins
- `ui_in[0]`: data input bit (others ignored)
- `uo_out[0]`: inverted output bit (`uo_out[0] = ~ui_in[0]` when `ena=1`)
- `uio_*`: unused (not driven)
- `ena`: when 1, outputs are active; when 0, all outputs = 0
- `clk`, `rst_n`: present for the harness; not used by the logic

## How to test
1. Assert `rst_n=1` (not used by logic, but keep deasserted).
2. Set `ena=1`.
3. Drive `ui_in[0]` to 0 → expect `uo_out[0]=1`.
4. Drive `ui_in[0]` to 1 → expect `uo_out[0]=0`.
5. Optional: set `ena=0` and verify `uo_out` becomes `8'h00` regardless of input.

## Test strategy
Use a simple cocotb test to toggle `ui_in[0]` and check `uo_out[0]`. Verify `ena` gating forces outputs to 0.

## Notes
Outputs never drive the bidirectional `uio_*` pads. All unused outputs remain 0.
