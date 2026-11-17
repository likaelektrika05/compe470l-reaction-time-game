`timescale 1ns / 1ps
// Tests button_pulse with STABLE_TICKS = 5 so the sim is fast.
// A bouncy press must give exactly one pulse, and holding the button
// must not give more pulses.
module tb_button_pulse;
    reg clk = 0, reset = 1, btn = 0;
    wire pulse;
    integer pulses = 0, errors = 0;

    button_pulse #(.STABLE_TICKS(5)) dut (.clk(clk), .reset(reset), .btn_in(btn), .pulse(pulse));

    always #5 clk = ~clk;
    always @(posedge clk) if (pulse) pulses = pulses + 1;

    task bounce;
        integer k;
        begin
            for (k = 0; k < 4; k = k + 1) begin
                btn = ~btn; repeat (2) @(posedge clk);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_button_pulse.vcd");
        $dumpvars(0, tb_button_pulse);
        repeat (3) @(posedge clk); reset = 0;

        // Press 1: bounce, then hold for a long time
        bounce; btn = 1; repeat (50) @(posedge clk);
        if (pulses != 1) begin $display("FAIL: press 1 gave %0d pulses, expected 1", pulses); errors = errors + 1; end

        // Release with bounce: no pulse on release
        bounce; btn = 0; repeat (30) @(posedge clk);
        if (pulses != 1) begin $display("FAIL: release gave a pulse"); errors = errors + 1; end

        // Short glitch (shorter than STABLE_TICKS): ignored
        btn = 1; repeat (2) @(posedge clk); btn = 0; repeat (20) @(posedge clk);
        if (pulses != 1) begin $display("FAIL: glitch was counted as a press"); errors = errors + 1; end

        // Press 2
        btn = 1; repeat (30) @(posedge clk); btn = 0; repeat (30) @(posedge clk);
        if (pulses != 2) begin $display("FAIL: after press 2, pulses = %0d, expected 2", pulses); errors = errors + 1; end

        if (errors == 0) $display("PASS: tb_button_pulse (%0d presses, %0d pulses)", 2, pulses);
        else             $display("FAIL: tb_button_pulse had %0d errors", errors);
        $finish;
    end
endmodule
