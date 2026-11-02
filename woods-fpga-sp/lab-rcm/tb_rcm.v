`timescale 1ns/1ps
module tb_rcm;
    reg clk, rst, in_valid;
    reg signed [15:0] x;
    reg [2:0] sel;
    wire out_valid;
    wire signed [31:0] y;
    integer errors, n, k;
    integer coeffs [0:4];

    rcm_const_mul dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .x(x), .sel(sel), .out_valid(out_valid), .y(y)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic check;
        input signed [15:0] xv;
        input [2:0] s;
        reg signed [31:0] exp;
        begin
            exp = xv * coeffs[s];
            @(negedge clk); x=xv; sel=s; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || y !== exp) begin
                $display("FAIL x=%0d sel=%0d got=%0d exp=%0d", xv, s, y, exp);
                errors=errors+1; $fatal(1,"rcm");
            end
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        coeffs[0]=7; coeffs[1]=5; coeffs[2]=9; coeffs[3]=15; coeffs[4]=6;
        errors=0; n=0; rst=1; in_valid=0; x=0; sel=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        check(16'sd1, 0); check(16'sd10, 1); check(-16'sd3, 2);
        check(16'sd100, 3); check(16'sd7, 4); check(-16'sd20, 0);
        for (k=0;k<30;k=k+1) check($random, k % 5);
        if (errors) $fatal(1,"err");
        $display("PASS rcm_const_mul n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
