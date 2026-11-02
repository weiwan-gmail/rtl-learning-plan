`timescale 1ns/1ps
module tb_iir_retime;
    localparam signed [15:0] B0 = 16'sd1, B1 = 16'sd1, A1 = 16'sd1;
    localparam integer SHIFT = 1;

    reg clk, rst, in_valid;
    reg signed [15:0] din;
    wire ov_c, ov_p;
    wire signed [15:0] y_c, y_p;
    integer errors, n, k, wr, rd_c, rd_p, gx, gy;
    integer expect_q [0:255];

    function automatic integer sat16;
        input integer v;
        begin
            if (v > 32767) sat16 = 32767;
            else if (v < -32768) sat16 = -32768;
            else sat16 = v;
        end
    endfunction

    iir1_combo #(.B0(B0),.B1(B1),.A1(A1),.SHIFT(SHIFT)) u_c (
        .clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_c),.dout(y_c));
    iir1_pipe  #(.B0(B0),.B1(B1),.A1(A1),.SHIFT(SHIFT)) u_p (
        .clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_p),.dout(y_p));

    initial begin clk=0; forever #5 clk=~clk; end

    always @(posedge clk) begin
        if (!rst) begin
            #1;
            if (ov_c) begin
                if (y_c !== expect_q[rd_c]) begin
                    $display("FAIL combo got=%0d exp=%0d", y_c, expect_q[rd_c]);
                    $fatal(1,"combo");
                end
                rd_c=rd_c+1; n=n+1;
            end
            if (ov_p) begin
                if (y_p !== expect_q[rd_p]) begin
                    $display("FAIL pipe got=%0d exp=%0d", y_p, expect_q[rd_p]);
                    $fatal(1,"pipe");
                end
                rd_p=rd_p+1;
            end
        end
    end

    task automatic feed;
        input signed [15:0] s;
        integer acc, yn;
        begin
            acc = s*B0 + gx*B1 + gy*A1;
            yn  = sat16(acc >>> SHIFT);
            expect_q[wr]=yn; wr=wr+1;
            gx = s; gy = yn;
            @(negedge clk); din=s; in_valid=1;
            @(posedge clk); @(negedge clk); in_valid=0;
            repeat (4) @(posedge clk); // drain pipe; next sample sees updated y1
        end
    endtask

    initial begin
        errors=0; n=0; wr=0; rd_c=0; rd_p=0; gx=0; gy=0;
        rst=1; in_valid=0; din=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        feed(0); feed(8); feed(16); feed(-8); feed(4);
        for (k=0;k<12;k=k+1) feed(k-6);
        repeat(6) @(posedge clk);
        if (rd_c != wr || rd_p != wr) $fatal(1,"count");
        $display("PASS iir-retime combo+pipe n=%0d mismatches=0", n);
        $display("METRIC LATENCY_COMBO=1 LATENCY_PIPE=2 SAME_BITEXACT=1");
        $finish;
    end
endmodule
