`timescale 1ns / 1ps
// COMPE 470L Final Project: Reaction-Time Game (Basys 3)
//
// btnC  : start a round / react
// btnU  : reset (also clears the best time)
// sw[0] : on the result screen, 0 = last time, 1 = best time
// led   : all 16 turn on for "GO"
// 7-seg : "----" while ready/waiting, live ms while GO,
//         the time after you react, "Err" on a false start
module reaction_game_top #(
    parameter integer CLKS_PER_MS   = 100_000,     // 1 ms at 100 MHz
    parameter integer DEBOUNCE_TICKS = 1_000_000,  // 10 ms
    parameter integer REFRESH_TICKS = 100_000      // 1 ms per digit
)(
    input  wire        CLK100MHZ,
    input  wire        btnC,
    input  wire        btnU,
    input  wire [0:0]  sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an
);
    // Reset: bring btnU into our clock with two flip-flops.
    reg rst_0 = 1'b1, rst = 1'b1;
    always @(posedge CLK100MHZ) begin
        rst_0 <= btnU;
        rst   <= rst_0;
    end

    // sw[0] also goes through two flip-flops.
    reg sw_0 = 1'b0, show_best = 1'b0;
    always @(posedge CLK100MHZ) begin
        sw_0      <= sw[0];
        show_best <= sw_0;
    end

    wire        btn, tick, sample, cnt_clr, cnt_en, go, save, cnt_max;
    wire [2:0]  state;
    wire [12:0] wait_ms;
    wire [15:0] lfsr, ms_bcd, best;

    button_pulse #(.STABLE_TICKS(DEBOUNCE_TICKS)) start_button (
        .clk(CLK100MHZ), .reset(rst), .btn_in(btnC), .pulse(btn)
    );

    tick_gen #(.CLKS_PER_TICK(CLKS_PER_MS)) ms_tick (
        .clk(CLK100MHZ), .rst(rst), .tick(tick)
    );

    lfsr_random random (
        .clk(CLK100MHZ), .rst(rst), .sample(sample), .wait_ms(wait_ms), .lfsr(lfsr)
    );

    game_fsm fsm (
        .clk(CLK100MHZ), .rst(rst), .btn(btn), .tick(tick),
        .wait_ms(wait_ms), .cnt_max(cnt_max),
        .state(state), .sample(sample), .cnt_clr(cnt_clr),
        .cnt_en(cnt_en), .go(go), .save(save)
    );

    ms_counter counter (
        .clk(CLK100MHZ), .rst(rst), .clr(cnt_clr), .en(cnt_en),
        .tick(tick), .bcd(ms_bcd), .max(cnt_max)
    );

    best_score best_time (
        .clk(CLK100MHZ), .rst(rst), .save(save), .time_bcd(ms_bcd), .best(best)
    );

    // What to show. The counter stops after GO, so in RESULT
    // ms_bcd still holds your last time.
    localparam [15:0] DASHES = 16'hAAAA;   // "----"
    localparam [15:0] ERR    = 16'hEBBF;   // "Err" + blank
    localparam [2:0]  S_READY = 3'd0, S_WAIT = 3'd1, S_GO = 3'd2,
                      S_RESULT = 3'd3, S_EARLY = 3'd4;

    reg [15:0] shown;
    always @(*) begin
        case (state)
            S_GO:     shown = ms_bcd;
            S_RESULT: shown = show_best ? best : ms_bcd;
            S_EARLY:  shown = ERR;
            default:  shown = DASHES;      // READY and WAIT
        endcase
    end

    wire [3:0] digit;
    display_mux #(.REFRESH_TICKS(REFRESH_TICKS)) mux (
        .clk(CLK100MHZ), .rst(rst), .value(shown), .an(an), .data(digit)
    );

    bcd_to_7seg decoder (.bcd(digit), .seg(seg));

    assign led = go ? 16'hFFFF : 16'h0000;
    assign dp  = 1'b1;   // decimal point off
endmodule
