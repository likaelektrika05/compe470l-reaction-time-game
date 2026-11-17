`timescale 1ns / 1ps
// lfsr_random: picks a random wait time of about 1 to 5 seconds.
// A 16-bit LFSR runs on every clock. When the player presses start,
// "sample" goes high and we grab the LFSR value. The exact clock the
// person presses on is random, so the wait is random too.
// wait_ms = 1000 + lfsr[11:0], so it is 1000 to 5095 ms.
module lfsr_random (
    input  wire        clk,
    input  wire        rst,     // active-high, synchronous
    input  wire        sample,  // one-clock pulse: grab a new wait time
    output reg  [12:0] wait_ms, // binary, 1000..5095
    output wire [15:0] lfsr     // raw value (for testing)
);
    reg [15:0] r;
    assign lfsr = r;

    // Taps for x^16 + x^14 + x^13 + x^11 + 1 (maximal length: 65535 states)
    wire feedback = r[15] ^ r[13] ^ r[12] ^ r[10];

    always @(posedge clk) begin
        if (rst) begin
            r       <= 16'hACE1;          // any value except 0
            wait_ms <= 13'd1000;
        end else begin
            r <= {r[14:0], feedback};
            if (sample)
                wait_ms <= 13'd1000 + {1'b0, r[11:0]};
        end
    end
endmodule
