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
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    initial begin
        $dumpfile("tb.vcd"); $dumpvars(0, tb);
        ena   = 1'b0; rst_n = 1'b0; uio_in = 8'h00; ui_in = 8'h00;
        repeat (5) @(posedge clk);
        ena = 1'b1; rst_n = 1'b1;

        // send 0x55
        ui_in = 8'h55; uio_in[0] = 1; @(posedge clk); uio_in[0] = 0;
        // wait ~ 11 bit times (start + 8 data + stop + margin)
        repeat (1200) @(posedge clk);

        // send 0xA5
        ui_in = 8'hA5; uio_in[0] = 1; @(posedge clk); uio_in[0] = 0;
        repeat (1200) @(posedge clk);

        $finish;
    end
endmodule
