`timescale 1ns/1ps
module tb_biquad_fold;
    localparam signed [15:0] B0=16'sd8192, B1=16'sd8192, B2=16'sd8192;
    localparam signed [15:0] A1=-16'sd16384, A2=16'sd8192;

    reg clk, rst, in_p, in_f;
    reg signed [15:0] xp, xf;
    wire ov_p, ov_f, busy;
    wire signed [15:0] yp, yf;

    reg signed [15:0] gx1, gx2, gy1, gy2;
    reg signed [31:0] gacc;
    reg signed [15:0] gy;
    integer n, k;

    biquad_par  u_p (.clk(clk),.rst(rst),.in_valid(in_p),.x_in(xp),
                     .b0(B0),.b1(B1),.b2(B2),.a1(A1),.a2(A2),
                     .out_valid(ov_p),.y_out(yp));
    biquad_fold u_f (.clk(clk),.rst(rst),.in_valid(in_f),.x_in(xf),
                     .b0(B0),.b1(B1),.b2(B2),.a1(A1),.a2(A2),
                     .out_valid(ov_f),.y_out(yf),.busy(busy));

    initial begin clk=0; forever #5 clk=~clk; end

    task automatic push_both;
        input signed [15:0] xv;
        begin
            gacc = B0*xv + B1*gx1 + B2*gx2 - A1*gy1 - A2*gy2;
            gy   = gacc[30:15];
            // parallel sample
            @(negedge clk); xp=xv; in_p=1; in_f=0;
            @(posedge clk); #1;
            if (!ov_p || yp !== gy) begin
                $display("par FAIL got=%0d exp=%0d x=%0d", yp, gy, xv);
                $fatal(1, "par mismatch");
            end
            @(negedge clk); in_p=0;
            // folded sample (5 clocks)
            xf=xv; in_f=1;
            @(posedge clk); #1;
            @(negedge clk); in_f=0;
            begin : waitf
                integer t;
                for (t=0; t<8; t=t+1) begin
                    @(posedge clk); #1;
                    if (ov_f) begin
                        if (yf !== gy) begin
                            $display("fold FAIL got=%0d exp=%0d", yf, gy);
                            $fatal(1, "fold mismatch");
                        end
                        n=n+1;
                        disable waitf;
                    end
                end
                $fatal(1, "fold timeout");
            end
            gx2=gx1; gx1=xv; gy2=gy1; gy1=gy;
        end
    endtask

    initial begin
        n=0; rst=1; in_p=0; in_f=0; xp=0; xf=0;
        gx1=0; gx2=0; gy1=0; gy2=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        push_both(16'sd0); push_both(16'sd1000); push_both(16'sd2000);
        push_both(-16'sd1500); push_both(16'sd500);
        for (k=0;k<8;k=k+1) push_both((k-4)*400);
        $display("PASS biquad-fold parallel vs N=5 folded n=%0d", n);
        $display("METRIC FOLDING_FACTOR=5 SAME_BITEXACT=1");
        $finish;
    end
endmodule
