`timescale 1ns / 1ps
// best_score: keeps the fastest time.
// Times are 4 BCD digits. Comparing packed BCD as a plain number
// gives the right answer, so no conversion is needed.
// Starts at 9999 so the first real time always wins.
module best_score (
    input  wire        clk,
    input  wire        rst,    // active-high, synchronous
    input  wire        save,   // one-clock pulse: a new time is ready
    input  wire [15:0] time_bcd,
    output reg  [15:0] best
);
    always @(posedge clk) begin
        if (rst)
            best <= 16'h9999;
        else if (save && time_bcd < best)
            best <= time_bcd;
    end
endmodule
