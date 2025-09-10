// tb.v : minimal testbench shell for cocotb
`timescale 1ns/1ps
`default_nettype none

module tb;
    reg clk;
    reg rst_n;
    reg in;
    wire out;

    // Instantiate DUT
    dut uut (
        .clk(clk),
        .rst_n(rst_n),
        .in(in),
        .out(out)
    );

    // Initial values only — cocotb will drive clock and signals
    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        in    = 1'b0;
    end
endmodule
