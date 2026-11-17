`timescale 1ns / 1ps
// Tests lfsr_random: full 65535 period, never 0, wait_ms always 1000..5095.
module tb_lfsr_random;
    reg clk = 0, rst = 1, sample = 0;
    wire [12:0] wait_ms;
    wire [15:0] lfsr;
    integer errors = 0, i, period = 0;
    integer min_w = 99999, max_w = 0;
    reg [15:0] start;

    lfsr_random dut (.clk(clk), .rst(rst), .sample(sample), .wait_ms(wait_ms), .lfsr(lfsr));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_lfsr_random.vcd");
        $dumpvars(0, tb_lfsr_random);
        @(posedge clk); #1 rst = 0;

        // 1) Period check: should take 65535 clocks to come back to the start.
        start = lfsr;
        for (i = 1; i <= 70000 && period == 0; i = i + 1) begin
            @(posedge clk); #1;
            if (lfsr == 16'h0000) begin
                $display("FAIL: LFSR hit 0 (it would get stuck)");
                errors = errors + 1;
            end
            if (lfsr == start) period = i;
        end
        if (period != 65535) begin
            $display("FAIL: period = %0d, expected 65535", period);
            errors = errors + 1;
        end

        // 2) Range check: sample many times at uneven moments.
        for (i = 0; i < 2000; i = i + 1) begin
            repeat ((i * 7) % 13 + 1) @(posedge clk);
            #1 sample = 1;
            @(posedge clk); #1 sample = 0;
            if (wait_ms < 1000 || wait_ms > 5095) begin
                $display("FAIL: wait_ms = %0d out of range", wait_ms);
                errors = errors + 1;
            end
            if (wait_ms < min_w) min_w = wait_ms;
            if (wait_ms > max_w) max_w = wait_ms;
        end

        if (errors == 0) $display("PASS: tb_lfsr_random (period %0d, wait_ms seen %0d..%0d)", period, min_w, max_w);
        else             $display("FAIL: tb_lfsr_random had %0d errors", errors);
        $finish;
    end
endmodule
