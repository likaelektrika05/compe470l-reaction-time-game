`timescale 1ns / 1ps
// Full-game testbench. Plays the game like a person would.
// To keep the sim fast: 1 ms = 10 clocks, debounce = 3 clocks,
// display refresh = 2 clocks.
//
// Rounds tested:
//   1. normal round, react after 250 ms
//   2. false start (press during WAIT) -> "Err"
//   3. round at 400 ms -> best stays 250
//   4. round at 150 ms -> new best 150
//   5. no press -> stops at 9999
//   6. btnU reset -> READY, best back to 9999
module tb_reaction_game_top;
    localparam MS = 10;   // clocks per ms in this test

    reg  clk = 0, btnC = 0, btnU = 1;
    reg  [0:0] sw = 1'b0;
    wire [15:0] led;
    wire [6:0]  seg;
    wire        dp;
    wire [3:0]  an;

    reaction_game_top #(
        .CLKS_PER_MS(MS), .DEBOUNCE_TICKS(3), .REFRESH_TICKS(2)
    ) dut (
        .CLK100MHZ(clk), .btnC(btnC), .btnU(btnU), .sw(sw),
        .led(led), .seg(seg), .dp(dp), .an(an)
    );

    always #5 clk = ~clk;

    localparam [2:0] READY = 0, WAIT = 1, GO = 2, RESULT = 3, EARLY = 4;
    integer errors = 0;
    integer wait_seen;

    // Press and release btnC like a person (held 1 ms).
    task press;
        begin
            btnC = 1; repeat (MS) @(posedge clk);
            btnC = 0; repeat (MS) @(posedge clk);
        end
    endtask

    task expect_state(input [2:0] want, input [8*24-1:0] what);
        begin
            if (dut.state !== want) begin
                $display("FAIL: %0s: state = %0d, expected %0d", what, dut.state, want);
                errors = errors + 1;
            end
        end
    endtask

    // BCD (4 digits) to a normal number, for printing and checking
    function integer bcd2int(input [15:0] b);
        bcd2int = b[15:12]*1000 + b[11:8]*100 + b[7:4]*10 + b[3:0];
    endfunction

    // Start a round, wait for GO, react after "ms" milliseconds.
    // Returns the time shown on the display.
    task play_round(input integer ms, output integer shown_ms);
        integer t;
        begin
            press;
            expect_state(WAIT, "after start press");
            if (led !== 16'h0000) begin $display("FAIL: LEDs on during WAIT"); errors = errors + 1; end
            t = 0;
            while (!led[0]) begin @(posedge clk); t = t + 1; end
            wait_seen = t / MS;
            if (wait_seen < 990 || wait_seen > 5100) begin
                $display("FAIL: random wait was %0d ms (expected 1000..5095)", wait_seen);
                errors = errors + 1;
            end
            if (led !== 16'hFFFF) begin $display("FAIL: not all 16 LEDs on at GO"); errors = errors + 1; end
            repeat (ms * MS) @(posedge clk);
            press;
            expect_state(RESULT, "after react press");
            if (led !== 16'h0000) begin $display("FAIL: LEDs still on after react"); errors = errors + 1; end
            shown_ms = bcd2int(dut.shown);
        end
    endtask

    task check_close(input integer got, input integer want, input [8*24-1:0] what);
        begin
            // Allow +-2 ms for button debounce and where the 1 ms tick lands.
            if (got < want - 2 || got > want + 2) begin
                $display("FAIL: %0s: got %0d ms, expected about %0d", what, got, want);
                errors = errors + 1;
            end
        end
    endtask

    integer r1, r3, r4, r5;

    initial begin
        $dumpfile("tb_reaction_game_top.vcd");
        $dumpvars(0, tb_reaction_game_top);

        repeat (5) @(posedge clk); btnU = 0; repeat (5) @(posedge clk);
        expect_state(READY, "after reset");
        if (dut.shown !== 16'hAAAA) begin $display("FAIL: READY should show ----"); errors = errors + 1; end

        // 1. Normal round
        play_round(250, r1);
        $display("Round 1: random wait %0d ms, reaction %0d ms", wait_seen, r1);
        check_close(r1, 250, "round 1 time");

        // 2. False start
        press;
        expect_state(WAIT, "round 2 start");
        repeat (300 * MS) @(posedge clk);       // 300 ms, still waiting
        press;
        expect_state(EARLY, "false start");
        if (dut.shown !== 16'hEBBF) begin $display("FAIL: false start should show Err"); errors = errors + 1; end
        else $display("Round 2: false start -> display shows Err");

        // 3. Slower round: best must stay at round 1
        play_round(400, r3);
        $display("Round 3: random wait %0d ms, reaction %0d ms", wait_seen, r3);
        check_close(r3, 400, "round 3 time");
        sw[0] = 1; repeat (5) @(posedge clk);
        if (bcd2int(dut.shown) != r1) begin $display("FAIL: best should still be %0d, shows %0d", r1, bcd2int(dut.shown)); errors = errors + 1; end
        else $display("         sw[0]=1 shows best = %0d ms", bcd2int(dut.shown));
        sw[0] = 0; repeat (5) @(posedge clk);
        if (bcd2int(dut.shown) != r3) begin $display("FAIL: sw[0]=0 should show last time"); errors = errors + 1; end

        // 4. Faster round: new best
        play_round(150, r4);
        $display("Round 4: random wait %0d ms, reaction %0d ms", wait_seen, r4);
        check_close(r4, 150, "round 4 time");
        sw[0] = 1; repeat (5) @(posedge clk);
        if (bcd2int(dut.shown) != r4) begin $display("FAIL: best should be %0d, shows %0d", r4, bcd2int(dut.shown)); errors = errors + 1; end
        else $display("         sw[0]=1 shows new best = %0d ms", bcd2int(dut.shown));
        sw[0] = 0; repeat (5) @(posedge clk);

        // 5. No press: stops at 9999
        press;
        while (!led[0]) @(posedge clk);
        repeat (10_100 * MS) @(posedge clk);
        expect_state(RESULT, "timeout");
        if (dut.shown !== 16'h9999) begin $display("FAIL: timeout should show 9999"); errors = errors + 1; end
        else $display("Round 5: no press -> stops at 9999");
        if (bcd2int(dut.best) != r4) begin
            $display("FAIL: timeout changed the best time"); errors = errors + 1;
        end

        // 6. Reset
        btnU = 1; repeat (5) @(posedge clk); btnU = 0; repeat (5) @(posedge clk);
        expect_state(READY, "after btnU");
        if (dut.best !== 16'h9999) begin $display("FAIL: reset should set best to 9999"); errors = errors + 1; end
        else $display("Reset:   back to READY, best = 9999");

        if (errors == 0) $display("PASS: tb_reaction_game_top");
        else             $display("FAIL: tb_reaction_game_top had %0d errors", errors);
        $finish;
    end
endmodule
