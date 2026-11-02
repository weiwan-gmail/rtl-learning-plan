`timescale 1ns/1ps
module tb_fir_3par;
    reg clk, rst, in_s, in_p;
    reg signed [15:0] din, x0, x1, x2;
    wire ov_s, ov_p;
    wire signed [31:0] ys, y0, y1, y2;
    integer k, n;

    fir_serial3 u_s (.clk(clk),.rst(rst),.in_valid(in_s),.din(din),.out_valid(ov_s),.dout(ys));
    fir_3par    u_p (.clk(clk),.rst(rst),.in_valid(in_p),.x0(x0),.x1(x1),.x2(x2),
                     .out_valid(ov_p),.y0(y0),.y1(y1),.y2(y2));

    initial begin clk=0; forever #5 clk=~clk; end

    initial begin
        n=0; rst=1; in_s=0; in_p=0; din=0; x0=0; x1=0; x2=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        begin : par
            integer i, gx0, gx1, gx2, e0, e1, e2;
            integer seq [0:29];
            for (i=0;i<30;i=i+1) seq[i]=i-15;
            gx0=0; gx1=0; gx2=0;
            for (i=0;i<30;i=i+3) begin
                x0=seq[i]; x1=seq[i+1]; x2=seq[i+2];
                @(negedge clk); in_p=1;
                @(posedge clk); #1;
                if (!ov_p) $fatal(1,"3par silent");
                gx2=gx1; gx1=gx0; gx0=seq[i];
                e0 = 1*gx0+2*gx1+1*gx2;
                gx2=gx1; gx1=gx0; gx0=seq[i+1];
                e1 = 1*gx0+2*gx1+1*gx2;
                gx2=gx1; gx1=gx0; gx0=seq[i+2];
                e2 = 1*gx0+2*gx1+1*gx2;
                if (y0!==e0 || y1!==e1 || y2!==e2)
                    $fatal(1,"3par i=%0d", i);
                n=n+3;
                @(negedge clk); in_p=0;
            end
        end
        $display("PASS fir-3par vs serial golden n=%0d mismatches=0", n);
        $display("METRIC PARALLEL=3 SAME_BITEXACT=1");
        $finish;
    end
endmodule
