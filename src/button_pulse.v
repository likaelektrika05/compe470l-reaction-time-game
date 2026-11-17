`timescale 1ns / 1ps
// From COMPE 470L Lab 6 (Digital Clock).
// Button cleaner. Two flip-flops bring the button into our clock.
// The button must stay the same for 10 ms before we accept it.
// Then we send one pulse for each press.
module button_pulse #(
    parameter integer STABLE_TICKS = 1_000_000
)(
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  pulse
);

    reg        sync_0, sync_1;
    reg        stable;
    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
            stable <= 1'b0;
            count  <= 0;
            pulse  <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
            pulse  <= 1'b0;

            if (sync_1 == stable) begin
                count <= 0;
            end else if (count == STABLE_TICKS - 1) begin
                count  <= 0;
                stable <= sync_1;
                if (sync_1)
                    pulse <= 1'b1;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
