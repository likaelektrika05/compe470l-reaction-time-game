`timescale 1ns / 1ps
// Tests display_mux with REFRESH_TICKS = 3. Shows 1234 and checks that
// each digit lights with the right number, right to left.
module tb_display_mux;
    reg clk = 0, rst = 1;
    reg [15:0] value = 16'h1234;
    wire [3:0] an, data;
    integer errors = 0, i;
    reg [3:0] want_an [0:3];
    reg [3:0] want_d  [0:3];

    display_mux #(.REFRESH_TICKS(3)) dut (.clk(clk), .rst(rst), .value(value), .an(an), .data(data));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_display_mux.vcd");
        $dumpvars(0, tb_display_mux);
        want_an[0] = 4'b1110; want_d[0] = 4'd4;
        want_an[1] = 4'b1101; want_d[1] = 4'd3;
        want_an[2] = 4'b1011; want_d[2] = 4'd2;
        want_an[3] = 4'b0111; want_d[3] = 4'd1;

        @(posedge clk); #1 rst = 0;
        for (i = 0; i < 8; i = i + 1) begin
            #1;
            if (an !== want_an[i%4] || data !== want_d[i%4]) begin
                $display("FAIL: step %0d an=%b data=%0d, expected an=%b data=%0d", i, an, data, want_an[i%4], want_d[i%4]);
                errors = errors + 1;
            end
            repeat (3) @(posedge clk);
        end

        if (errors == 0) $display("PASS: tb_display_mux (shows 1234 right to left)");
        else             $display("FAIL: tb_display_mux had %0d errors", errors);
        $finish;
    end
endmodule
