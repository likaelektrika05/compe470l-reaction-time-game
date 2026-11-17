`timescale 1ns / 1ps
// Display multiplexer. Taken out of the Lab 6 digital_clock module
// so it can be reused on its own.
// The display can only show one digit at a time. We switch to the
// next digit every 1 ms. This is so fast that our eyes see all four.
module display_mux #(
    parameter integer REFRESH_TICKS = 100_000   // 1 ms at 100 MHz
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] value,   // 4 BCD digits, value[15:12] is the left digit
    output reg  [3:0]  an,      // digit select, 0 = on
    output reg  [3:0]  data     // number for the selected digit
);

    reg [31:0] refresh_count;
    reg [1:0]  digit;

    always @(posedge clk) begin
        if (rst) begin
            refresh_count <= 0;
            digit         <= 0;
        end else if (refresh_count == REFRESH_TICKS - 1) begin
            refresh_count <= 0;
            digit         <= digit + 1;
        end else begin
            refresh_count <= refresh_count + 1;
        end
    end

    // Digit 0 is the right side, digit 3 is the left side.
    always @(*) begin
        case (digit)
            2'd0: begin an = 4'b1110; data = value[3:0];   end
            2'd1: begin an = 4'b1101; data = value[7:4];   end
            2'd2: begin an = 4'b1011; data = value[11:8];  end
            2'd3: begin an = 4'b0111; data = value[15:12]; end
            default: begin an = 4'b1111; data = 4'd0; end
        endcase
    end

endmodule
