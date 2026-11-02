`timescale 1ns/1ps
module tb_csd_mul;
    reg clk, rst, in_valid, sel;
    reg signed [15:0] x;
    wire out_valid;
    wire signed [31:0] y;
    integer n, k, exp;

    csd_mul dut (
        .clk(clk),.rst(rst),.in_valid(in_valid),.x(x),.sel_m19(sel),
        .out_valid(out_valid),.y(y)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic check;
        input signed [15:0] xv;
        input sel19;
        integer e;
        begin
            e = sel19 ? (-19)*xv : 29*xv;
            @(negedge clk); x=xv; sel=sel19; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || y !== e)
                $fatal(1, "x=%0d sel=%0d got=%0d exp=%0d", xv, sel19, y, e);
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        n=0; rst=1; in_valid=0; x=0; sel=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        for (k=-20; k<=20; k=k+1) begin
            check(k, 0);
            check(k, 1);
        end
        check(16'sd1000, 0);
        check(-16'sd1000, 1);
        $display("PASS csd-mul *29 and *-19 n=%0d", n);
        $display("METRIC CSD_29=100T01 CSD_M19=T0T01");
        $finish;
    end
endmodule
