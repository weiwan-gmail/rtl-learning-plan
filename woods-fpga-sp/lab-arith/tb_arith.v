`timescale 1ns/1ps
module tb_arith;
    reg clk, rst, in_valid;
    reg signed [15:0] a, b;
    reg cin;
    wire out_valid, cout;
    wire signed [15:0] sum;

    reg [7:0] ma, mb;
    wire mout_valid;
    wire [15:0] product;

    integer errors, n;

    cla_add16 u_add (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .a(a), .b(b), .cin(cin),
        .out_valid(out_valid), .sum(sum), .cout(cout)
    );
    array_mult8 u_mul (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .a(ma), .b(mb),
        .out_valid(mout_valid), .product(product)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    task automatic check_add;
        input signed [15:0] aa, bb;
        input cin0;
        reg [16:0] wide;
        begin
            wide = {1'b0, aa} + {1'b0, bb} + cin0;
            // unsigned-width add of bit patterns for cout; for signed sum use wrap
            wide = {1'b0, aa[15:0]} + {1'b0, bb[15:0]} + cin0;
            @(negedge clk); a=aa; b=bb; cin=cin0; ma=aa[7:0]; mb=bb[7:0]; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || sum !== wide[15:0] || cout !== wide[16]) begin
                $display("FAIL add a=%0d b=%0d cin=%0d got sum=%0d cout=%0d exp %0d/%0d",
                         aa, bb, cin0, sum, cout, wide[15:0], wide[16]);
                errors = errors + 1; $fatal(1, "add");
            end
            if (!mout_valid || product !== (aa[7:0] * bb[7:0])) begin
                $display("FAIL mul a=%0d b=%0d got=%0d exp=%0d",
                         aa[7:0], bb[7:0], product, aa[7:0]*bb[7:0]);
                errors = errors + 1; $fatal(1, "mul");
            end
            n = n + 1;
            @(negedge clk); in_valid = 0;
        end
    endtask

    integer k;
    initial begin
        errors = 0; n = 0;
        rst = 1; in_valid = 0; a = 0; b = 0; cin = 0; ma = 0; mb = 0;
        repeat (3) @(posedge clk); rst = 0; @(posedge clk);
        check_add(16'sd0, 16'sd0, 0);
        check_add(16'sd100, 16'sd200, 0);
        check_add(-16'sd50, 16'sd80, 0);
        check_add(16'hFFFF, 16'sd1, 0);
        check_add(16'h7FFF, 16'sd1, 0);
        check_add(16'sd7, 16'sd9, 1);
        for (k = 0; k < 40; k = k + 1)
            check_add($random, $random, k[0]);
        if (errors) $fatal(1, "errors");
        $display("PASS cla_add16+array_mult8 n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
