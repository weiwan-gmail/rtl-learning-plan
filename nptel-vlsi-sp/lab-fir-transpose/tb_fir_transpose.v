`timescale 1ns/1ps
module tb_fir_transpose;
    reg clk, rst, in_valid;
    reg signed [15:0] din;
    wire ov_d, ov_t;
    wire signed [31:0] y_d, y_t;
    integer errors, n, k, wr, rd_d, rd_t;
    integer hx0, hx1, hx2, hx3;
    integer expect_q [0:255];

    fir_direct    u_d (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_d),.dout(y_d));
    fir_transpose u_t (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_t),.dout(y_t));

    initial begin clk=0; forever #5 clk=~clk; end

    always @(posedge clk) begin
        if (!rst) begin
            #1;
            if (ov_d) begin
                if (y_d !== expect_q[rd_d]) begin
                    $display("FAIL direct got=%0d exp=%0d", y_d, expect_q[rd_d]);
                    errors=errors+1; $fatal(1,"direct");
                end
                rd_d=rd_d+1; n=n+1;
            end
            if (ov_t) begin
                if (y_t !== expect_q[rd_t]) begin
                    $display("FAIL transpose got=%0d exp=%0d", y_t, expect_q[rd_t]);
                    errors=errors+1; $fatal(1,"transpose");
                end
                rd_t=rd_t+1;
            end
        end
    end

    task automatic feed;
        input signed [15:0] s;
        integer y;
        begin
            hx3=hx2; hx2=hx1; hx1=hx0; hx0=s;
            y = 1*hx0 + 2*hx1 + 2*hx2 + 1*hx3;
            expect_q[wr]=y; wr=wr+1;
            @(negedge clk); din=s; in_valid=1;
            @(posedge clk); @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        errors=0; n=0; wr=0; rd_d=0; rd_t=0;
        hx0=0; hx1=0; hx2=0; hx3=0;
        rst=1; in_valid=0; din=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        feed(0); feed(1); feed(2); feed(3); feed(4);
        feed(-5); feed(10); feed(-2);
        for (k=0;k<16;k=k+1) feed(k-8);
        repeat(4) @(posedge clk);
        if (rd_d != wr || rd_t != wr) $fatal(1, "count wr=%0d rd_d=%0d rd_t=%0d", wr, rd_d, rd_t);
        if (errors) $fatal(1,"err");
        $display("PASS fir-transpose direct+transposed n=%0d mismatches=0", n);
        $display("METRIC SAME_BITEXACT=1 LINEAR_PHASE_H=1,2,2,1");
        $finish;
    end
endmodule
