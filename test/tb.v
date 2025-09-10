// test/tb.v
`timescale 1ns/1ps
`default_nettype none

module tb;
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena, clk, rst_n;

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

    initial begin
        clk    = 1'b0;   // cocotb will drive the clock
        rst_n  = 1'b0;
        ena    = 1'b0;
        ui_in  = 8'h00;
        uio_in = 8'h00;
    end

`ifdef COCOTB_SIM
    initial begin
        $dumpfile("test/tb.vcd");
        $dumpvars(0, tb);
    end
`endif
endmodule
