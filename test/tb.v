`timescale 1ns/1ps
`default_nettype none

module tb;
    reg         clk;
    reg         rst_n;
    reg         ena;
    reg  [7:0]  ui_in;
    reg  [7:0]  uio_in;
    wire [7:0]  uo_out;
    wire [7:0]  uio_out;
    wire [7:0]  uio_oe;

    // Instance name "dut" (matches your GL waveform scopes)
    tt_um_example dut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    initial begin
        clk    = 1'b0;
        rst_n  = 1'b0;
        ena    = 1'b0;
        ui_in  = 8'h00;
        uio_in = 8'h00;
    end

`ifdef COCOTB_SIM
    // Let cocotb generate fst/vcd – this block is optional.
`endif

`ifdef GL_TEST
  supply1 VPWR, VDD, vccd1;
  supply0 VGND, VSS, vssd1;
`endif

endmodule

`default_nettype wire
