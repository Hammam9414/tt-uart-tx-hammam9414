// test/tb.v : minimal testbench shell for cocotb
`timescale 1ns/1ps
`default_nettype none

module tb;
    reg clk;
    reg rst_n;
    reg in;
    wire out;

    // Instantiate DUT
    tt_um_example uut (
        .clk  (clk),
        .rst_n(rst_n),
        .in   (in),
        .out  (out)
    );

    // Seed known values; cocotb will drive the clock & signals
    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        in    = 1'b0;
    end

    // Force a VCD at the exact path your CI uploads
`ifdef COCOTB_SIM
    initial begin
        $dumpfile("test/tb.vcd");
        $dumpvars(0, tb);
    end
`endif
endmodule
