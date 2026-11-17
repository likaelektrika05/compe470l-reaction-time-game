`timescale 1ns / 1ps
// game_fsm: the brain of the reaction-time game.
//
//   READY  --press-->  WAIT   (grab a random wait time)
//   WAIT   --press-->  EARLY  (pressed too soon: false start)
//   WAIT   --wait done-->  GO (LEDs on, start counting ms)
//   GO     --press or 9999 ms-->  RESULT (save the time)
//   RESULT / EARLY  --press-->  WAIT  (next round)
//
// "btn" must be a one-clock pulse (from button_pulse).
module game_fsm (
    input  wire        clk,
    input  wire        rst,       // active-high, synchronous
    input  wire        btn,       // start / react pulse
    input  wire        tick,      // 1 ms pulse
    input  wire [12:0] wait_ms,   // random wait from lfsr_random
    input  wire        cnt_max,   // ms_counter reached 9999
    output reg  [2:0]  state,
    output wire        sample,    // tell lfsr_random to pick a wait time
    output wire        cnt_clr,   // clear ms_counter
    output wire        cnt_en,    // let ms_counter count
    output wire        go,        // turn the LEDs on
    output reg         save       // one-clock pulse: a new result is ready
);
    localparam [2:0] READY  = 3'd0,
                     WAIT   = 3'd1,
                     GO     = 3'd2,
                     RESULT = 3'd3,
                     EARLY  = 3'd4;

    reg [12:0] wait_cnt;   // ms spent in WAIT

    // A press in READY, RESULT or EARLY starts a new round.
    wire start = btn && (state == READY || state == RESULT || state == EARLY);

    assign sample  = start;
    assign cnt_clr = start;
    assign cnt_en  = (state == GO);
    assign go      = (state == GO);

    always @(posedge clk) begin
        if (rst) begin
            state    <= READY;
            wait_cnt <= 13'd0;
            save     <= 1'b0;
        end else begin
            save <= 1'b0;
            case (state)
                READY, RESULT, EARLY: begin
                    if (start) begin
                        state    <= WAIT;
                        wait_cnt <= 13'd0;
                    end
                end

                WAIT: begin
                    if (btn) begin
                        state <= EARLY;                 // false start
                    end else if (tick) begin
                        if (wait_cnt >= wait_ms - 1)
                            state <= GO;                // wait is over
                        else
                            wait_cnt <= wait_cnt + 1'b1;
                    end
                end

                GO: begin
                    if (btn || cnt_max) begin
                        state <= RESULT;
                        save  <= 1'b1;
                    end
                end

                default: state <= READY;
            endcase
        end
    end
endmodule
