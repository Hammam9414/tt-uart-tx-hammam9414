// test/tb.v
`timescale 1ns/1ps
`default_nettype none

module tb;
    // DUT ports
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena, clk, rst_n;

    // Instantiate DUT (TinyTapeout top)
    tt_um_example dut (
        .ui_in (ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena   (ena),
        .clk   (clk),
        .rst_n (rst_n)
    );

    // Give known power-up values; cocotb will control them afterwards.
    initial begin
        clk    = 1'b0;   // cocotb drives the clock; we just seed it
        rst_n  = 1'b0;   // cocotb reset() toggles this
        ena    = 1'b0;   // cocotb sets to 1 in reset()
        ui_in  = 8'h00;
        uio_in = 8'h00;  // cocotb pulses bit 0 for start
        // no stimulus here; no always blocks; no $finish
    end

endmodule
