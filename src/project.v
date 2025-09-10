// src/project.v
`timescale 1ns/1ps
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,   // 8 dedicated inputs
    output wire [7:0] uo_out,  // 8 dedicated outputs
    input  wire [7:0] uio_in,  // 8 IOs: input path
    output wire [7:0] uio_out, // 8 IOs: output path (unused)
    output wire [7:0] uio_oe,  // 8 IOs: output enable (unused)
    input  wire       ena,     // design enable (1 when selected)
    input  wire       clk,     // harness clock (unused here)
    input  wire       rst_n    // async active-low reset (unused here)
);
    // Never drive bidirectional IOs in this design
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Simple inverter on ui_in[0]; obey TT rule: outputs must be 0 when !ena
    wire inv0 = ~ui_in[0];
    assign uo_out = ena ? {7'b0, inv0} : 8'h00;

    // Silence unused warnings for formal/synth flows
    wire _unused = &{1'b0, clk, rst_n, uio_in};
endmodule

`default_nettype wire
