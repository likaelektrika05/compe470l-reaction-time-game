`timescale 1ns / 1ps
// Tests tick_gen with a small period (10 clocks) so the sim is fast.
module tb_tick_gen;
    reg clk = 0, rst = 1;
    wire tick;
    integer errors = 0, ticks = 0, last = 0, gap;

    tick_gen #(.CLKS_PER_TICK(10)) dut (.clk(clk), .rst(rst), .tick(tick));

    always #5 clk = ~clk;   // 100 MHz

    integer cycle = 0;
    always @(posedge clk) begin
        cycle = cycle + 1;
        if (tick) begin
            ticks = ticks + 1;
            gap = cycle - last;
            if (ticks > 1 && gap != 10) begin
                $display("FAIL: gap between ticks was %0d, expected 10", gap);
                errors = errors + 1;
            end
            last = cycle;
        end
    end

    initial begin
        $dumpfile("tb_tick_gen.vcd");
        $dumpvars(0, tb_tick_gen);
        repeat (3) @(posedge clk);
        rst = 0;
        repeat (100) @(posedge clk);
        if (ticks < 9) begin
            $display("FAIL: only %0d ticks in 100 clocks", ticks);
            errors = errors + 1;
        end
        if (errors == 0) $display("PASS: tb_tick_gen (%0d ticks, 1 every 10 clocks)", ticks);
        else             $display("FAIL: tb_tick_gen had %0d errors", errors);
        $finish;
    end
endmodule
