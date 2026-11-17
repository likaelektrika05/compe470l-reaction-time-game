`timescale 1ns / 1ps
// tick_gen: makes a one-clock pulse every CLKS_PER_TICK clocks.
// Basys 3 clock is 100 MHz, so 100_000 clocks = 1 ms.
module tick_gen #(
    parameter CLKS_PER_TICK = 100_000
)(
    input  wire clk,
    input  wire rst,     // active-high, synchronous
    output reg  tick     // high for one clock, once per tick period
);
    localparam W = $clog2(CLKS_PER_TICK);
    reg [W-1:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            tick  <= 1'b0;
        end else if (count == CLKS_PER_TICK - 1) begin
            count <= 0;
            tick  <= 1'b1;
        end else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end
endmodule
