`timescale 1ns / 1ps
// ms_counter: counts milliseconds 0000 to 9999 as 4 BCD digits.
// Counting in BCD means the display needs no binary-to-BCD converter.
// It stops at 9999 and raises "max".
module ms_counter (
    input  wire        clk,
    input  wire        rst,   // active-high, synchronous
    input  wire        clr,   // set count back to 0000
    input  wire        en,    // count only while en is high
    input  wire        tick,  // 1 ms pulse from tick_gen
    output reg  [15:0] bcd,   // {thousands, hundreds, tens, ones}
    output wire        max    // high when count is 9999
);
    assign max = (bcd == 16'h9999);

    always @(posedge clk) begin
        if (rst || clr) begin
            bcd <= 16'h0000;
        end else if (en && tick && !max) begin
            if (bcd[3:0] != 4'd9) begin
                bcd[3:0] <= bcd[3:0] + 1'b1;
            end else begin
                bcd[3:0] <= 4'd0;
                if (bcd[7:4] != 4'd9) begin
                    bcd[7:4] <= bcd[7:4] + 1'b1;
                end else begin
                    bcd[7:4] <= 4'd0;
                    if (bcd[11:8] != 4'd9) begin
                        bcd[11:8] <= bcd[11:8] + 1'b1;
                    end else begin
                        bcd[11:8]  <= 4'd0;
                        bcd[15:12] <= bcd[15:12] + 1'b1; // max check stops it at 9
                    end
                end
            end
        end
    end
endmodule
