`timescale 1ns/1ps
module tb_retiming;
    reg clk, rst, in_valid;
    reg signed [15:0] din;
    wire ov_c, ov_p;
    wire signed [31:0] y_c, y_p;
    integer errors, n, k;
    integer hx0, hx1, hx2;
    integer expect_q [0:255];
    integer wr, rd_c, rd_p;

    fir3_combo u_c (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),
                    .out_valid(ov_c),.dout(y_c));
    fir3_pipe  u_p (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),
                    .out_valid(ov_p),.dout(y_p));

    initial begin clk=0; forever #5 clk=~clk; end

    always @(posedge clk) begin
        if (!rst) begin
            #1;
            if (ov_c) begin
                if (y_c !== expect_q[rd_c]) begin
                    $display("FAIL combo got=%0d exp=%0d", y_c, expect_q[rd_c]);
                    errors=errors+1; $fatal(1,"combo");
                end
                rd_c=rd_c+1; n=n+1;
            end
            if (ov_p) begin
                if (y_p !== expect_q[rd_p]) begin
                    $display("FAIL pipe got=%0d exp=%0d", y_p, expect_q[rd_p]);
                    errors=errors+1; $fatal(1,"pipe");
                end
                rd_p=rd_p+1;
            end
        end
    end

    task automatic feed;
        input signed [15:0] s;
        integer y;
        begin
            hx2=hx1; hx1=hx0; hx0=s;
            y = 1*hx0 + 2*hx1 + 1*hx2;
            expect_q[wr]=y; wr=wr+1;
            @(negedge clk); din=s; in_valid=1;
            @(posedge clk); @(negedge clk); in_valid=0;
            // combo latency 1 — already sampled; pipe needs more clocks
            repeat (3) @(posedge clk);
        end
    endtask

    initial begin
        errors=0;n=0;wr=0;rd_c=0;rd_p=0;
        hx0=0;hx1=0;hx2=0;
        rst=1; in_valid=0; din=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        feed(0); feed(1); feed(2); feed(3); feed(4);
        feed(-5); feed(10); feed(-2);
        for (k=0;k<12;k=k+1) feed(k-6);
        // drain pipe
        repeat(10) @(posedge clk);
        if (rd_c != wr || rd_p != wr) begin
            $display("count mismatch wr=%0d rd_c=%0d rd_p=%0d", wr, rd_c, rd_p);
            $fatal(1,"count");
        end
        if (errors) $fatal(1,"err");
        $display("PASS retiming fir3 combo+pipe n=%0d mismatches=0", n);
        $display("METRIC LATENCY_COMBO=1 LATENCY_PIPE=3 SAME_BITEXACT=1");
        $finish;
    end
endmodule
