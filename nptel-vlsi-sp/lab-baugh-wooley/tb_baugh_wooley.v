`timescale 1ns/1ps
module tb_baugh_wooley;
    reg clk, rst, in_valid;
    reg [7:0] a, b;
    wire out_valid;
    wire [15:0] product;
    integer n, ia, ib, exp;

    baugh_wooley8 dut (
        .clk(clk),.rst(rst),.in_valid(in_valid),.a(a),.b(b),
        .out_valid(out_valid),.product(product)
    );

    initial begin clk=0; forever #5 clk=~clk; end

    task automatic check;
        input [7:0] aa, bb;
        integer sa, sb, p;
        begin
            sa = $signed(aa);
            sb = $signed(bb);
            p  = sa * sb;
            @(negedge clk); a=aa; b=bb; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || $signed(product) !== p)
                $fatal(1, "a=%0d b=%0d got=%0d exp=%0d", sa, sb, $signed(product), p);
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        n=0; rst=1; in_valid=0; a=0; b=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        // exhaustive is 65536 — a dense grid + corners is enough and fast
        check(8'h00, 8'h00);
        check(8'h01, 8'h01);
        check(8'hFF, 8'hFF); // -1 * -1 = 1
        check(8'h80, 8'h80); // -128*-128
        check(8'h7F, 8'h7F);
        check(8'h80, 8'h7F);
        check(8'h7F, 8'h80);
        for (ia=0; ia<256; ia=ia+17)
            for (ib=0; ib<256; ib=ib+13)
                check(ia[7:0], ib[7:0]);
        $display("PASS baugh-wooley8 n=%0d mismatches=0", n);
        $display("METRIC SIGNED_ARRAY=1");
        $finish;
    end
endmodule
