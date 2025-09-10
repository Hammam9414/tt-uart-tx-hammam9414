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

    // Instantiate the Tiny Tapeout top (tt_um_example per template)
    tt_um_example dut (
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    // Start values; **no** stimulus here
    initial begin
  clk      = 1'b0;
  rst      = 1'b1;
  start    = 1'b0;
  data_in  = 8'h00;
  // optional: other pins -> known values
  repeat (5) @(posedge clk);
  rst = 1'b0;
end

    // Let cocotb drive the clock, so no always #5 and **no $finish** here.
endmodule
