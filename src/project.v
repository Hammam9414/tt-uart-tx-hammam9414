// dut.v : super simple flop with async reset
`timescale 1ns/1ps
`default_nettype none

module tt_um_example (
    input  wire clk,
    input  wire rst_n,
    input  wire in,
    output reg  out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            out <= 1'b0;
        else
            out <= ~in;   // invert input
    end

endmodule
