/* Simple UART TX wrapped for Tiny Tapeout.
 * UI:  ui_in[7:0]  = byte to send
 * UIO: uio_in[0]   = start pulse (1 clk wide)
 * UO : uo_out[0]   = TX (idle=1), others 0
 */
`timescale 1ns/1ps
`default_nettype none

// ==== TOP required by the template (name must start with tt_um_) ====
module tt_um_example (
    input  wire [7:0] ui_in,   // 8 dedicated inputs
    output wire [7:0] uo_out,  // 8 dedicated outputs
    input  wire [7:0] uio_in,  // 8 IOs: input path
    output wire [7:0] uio_out, // 8 IOs: output path (unused)
    output wire [7:0] uio_oe,  // 8 IOs: output enable (unused)
    input  wire       ena,     // always 1 when the design is selected
    input  wire       clk,     // harness clock (we assume 100 MHz)
    input  wire       rst_n    // active-low reset
);
    // Never drive bidirectional pins in this design
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Start is taken from IO[0]; only active when enabled
    wire start = uio_in[0] & ena;
    wire tx, busy;

    // TT rule: when not enabled, outputs must be 0
    assign uo_out = ena ? {7'b0, tx} : 8'h00;

    // UART TX: 1 start, 8 data (LSB first), 1 stop, no parity
    uart_tx #(.CLK_HZ(100_000_000), .BAUD(1_000_000)) UTX (
        .clk(clk),
        .rst_n(rst_n),
        .data(ui_in),
        .start(start),
        .tx(tx),
        .busy(busy)
    );

    // prevent "unused" warnings for inputs we don't use explicitly
    wire _unused = &{1'b0, busy};
endmodule

// ==== Minimal, friendly UART transmitter (synthesizable) ====
module uart_tx #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer BAUD   = 1_000_000
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data,
    input  wire       start,     // pulse 1 clk when !busy
    output reg        tx,        // idle=1
    output reg        busy
);
    localparam integer DIV = (BAUD == 0) ? 1 : (CLK_HZ / BAUD);
    localparam [1:0] S_IDLE=2'd0, S_START=2'd1, S_DATA=2'd2, S_STOP=2'd3;

    reg [1:0]  state;
    reg [$clog2(DIV)-1:0] divcnt;
    reg [2:0]  bitcnt;
    reg [7:0]  shreg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= S_IDLE;
            tx     <= 1'b1;
            busy   <= 1'b0;
            divcnt <= 0;
            bitcnt <= 0;
            shreg  <= 8'h00;
        end else begin
            case (state)
            S_IDLE: begin
                tx   <= 1'b1;
                busy <= 1'b0;
                if (start) begin
                    busy   <= 1'b1;
                    shreg  <= data;
                    bitcnt <= 3'd0;
                    divcnt <= 0;
                    tx     <= 1'b0;   // start bit
                    state  <= S_START;
                end
            end
            S_START: begin
                if (divcnt == DIV-1) begin
                    divcnt <= 0;
                    tx     <= shreg[0];  // first data bit (LSB)
                    state  <= S_DATA;
                end else divcnt <= divcnt + 1;
            end
            S_DATA: begin
                if (divcnt == DIV-1) begin
                    divcnt <= 0;
                    if (bitcnt == 3'd7) begin
                        tx    <= 1'b1;   // stop bit next
                        state <= S_STOP;
                    end else begin
                        bitcnt <= bitcnt + 1;
                        shreg  <= {1'b0, shreg[7:1]}; // shift right
                        tx     <= shreg[1];           // next LSB
                    end
                end else divcnt <= divcnt + 1;
            end
            S_STOP: begin
                if (divcnt == DIV-1) begin
                    state  <= S_IDLE;
                    busy   <= 1'b0;
                    divcnt <= 0;
                end else divcnt <= divcnt + 1;
            end
            endcase
        end
    end
endmodule
