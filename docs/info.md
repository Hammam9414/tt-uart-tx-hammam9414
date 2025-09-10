<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This design implements an 8-N-1 UART transmitter. When `start` is pulsed with a new byte on `data_in`, the byte is loaded into a shift register. The transmitter drives a start bit (0), then 8 data bits LSB-first, then a stop bit (1) at the configured baud tick. Between frames `tx` idles high.

## How to test

- `clk`: system clock
- `rst`: async reset, active high
- `start`: pulse high for 1 clk to start a transmission
- `data_in[7:0]`: byte to send
- `tx`: UART output (idle = 1)

## Test strategy
Reset the DUT, load a byte (e.g., 0x55), assert `start` for one cycle, and check the serialized bit pattern with expected timing on `tx`.

## Notes
Baud timing is derived from `clk` via a divider.
