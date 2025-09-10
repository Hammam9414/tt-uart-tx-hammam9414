// Minimal TT user macro: invert ui_in[0] into uo_out[0]
// Drives ALL outputs deterministically and gates with ena.

`timescale 1ns/1ps
`default_nettype none

module tt_um_example (
    input  wire        clk,
    input  wire        rst_n,   // async, active-low
    input  wire        ena,     // project enable
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);
    // simple register to be deterministic at GL after reset
    reg q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else
            q <= ~ui_in[0];
    end

    // Gate your outputs with ena; drive all bits
    assign uo_out  = ena ? {7'b0, q} : 8'b0;

    // No bidir use in this example: keep them driven and disabled
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
endmodule

`default_nettype wire
