`timescale 1ns / 1ps
// Tests ms_counter: BCD carries, enable, clear, and stopping at 9999.
// tick is held high so it counts once per clock (fast sim).
module tb_ms_counter;
    reg clk = 0, rst = 1, clr = 0, en = 0, tick = 1;
    wire [15:0] bcd;
    wire max;
    integer errors = 0;

    ms_counter dut (.clk(clk), .rst(rst), .clr(clr), .en(en), .tick(tick), .bcd(bcd), .max(max));

    always #5 clk = ~clk;

    task check(input [15:0] want);
        begin
            if (bcd !== want) begin
                $display("FAIL: bcd = %h, expected %h (t=%0t)", bcd, want, $time);
                errors = errors + 1;
            end
        end
    endtask

    task count(input integer n);
        begin
            en = 1;
            repeat (n) @(posedge clk);
            #1 en = 0;
        end
    endtask

    initial begin
        $dumpfile("tb_ms_counter.vcd");
        $dumpvars(0, tb_ms_counter);
        @(posedge clk); #1 rst = 0;
        check(16'h0000);

        count(9);    #1 check(16'h0009);   // ones only
        count(1);    #1 check(16'h0010);   // 9 -> 10 carry
        count(90);   #1 check(16'h0100);   // 99 -> 100 carry
        count(900);  #1 check(16'h1000);   // 999 -> 1000 carry

        // en low: should hold
        repeat (20) @(posedge clk);
        #1 check(16'h1000);

        // clear
        clr = 1; @(posedge clk); #1 clr = 0;
        check(16'h0000);

        // count to 9999, then try to go past it
        count(9999); #1 check(16'h9999);
        if (!max) begin $display("FAIL: max not high at 9999"); errors = errors + 1; end
        count(50);   #1 check(16'h9999);   // must stay at 9999

        if (errors == 0) $display("PASS: tb_ms_counter");
        else             $display("FAIL: tb_ms_counter had %0d errors", errors);
        $finish;
    end
endmodule
