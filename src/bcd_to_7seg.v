`timescale 1ns / 1ps
// From COMPE 470L Lab 6 (Digital Clock).
// BCD to 7-segment decoder. Turns a number 0-9 into the segments to light.
// On the Basys 3 a segment is on when it gets 0. Order is {g,f,e,d,c,b,a}.
// Final project: added codes A = "-", B = "r", E = "E" so the board can
// show "----" and "Err". Codes C, D, F stay blank.
module bcd_to_7seg (
    input  wire [3:0] bcd,
    output reg  [6:0] seg
);

    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            4'hA: seg = 7'b0111111;  // "-"  (g only)
            4'hB: seg = 7'b0101111;  // "r"  (e, g)
            4'hE: seg = 7'b0000110;  // "E"  (a, d, e, f, g)
            default: seg = 7'b1111111;
        endcase
    end

endmodule
