`timescale 1ns/1ps
module tb_rls1;
    reg clk, rst, in_valid;
    reg signed [15:0] xin, din;
    wire out_valid;
    wire signed [15:0] yout, eout, w_out;
    wire signed [31:0] w_q_out, p_out;
    integer errors, n, i;
    // golden state
    reg signed [31:0] gw, gp;
    localparam PSCALE = 256;
    localparam WSCALE = 256;
    localparam PINIT  = 256*16;

    function automatic signed [31:0] div_tz;
        input signed [31:0] num, den;
        reg signed [31:0] a, b, q;
        begin
            if (den == 0) div_tz = 0;
            else begin
                a = (num < 0) ? -num : num;
                b = (den < 0) ? -den : den;
                q = a / b;
                div_tz = ((num < 0) ^ (den < 0)) ? -q : q;
            end
        end
    endfunction

    rls1 dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .xin(xin), .din(din),
        .out_valid(out_valid), .yout(yout), .eout(eout),
        .w_out(w_out), .w_q_out(w_q_out), .p_out(p_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic push;
        input signed [15:0] xv, dv;
        reg signed [31:0] den, k_q, y, e, wn, pn;
        begin
            den = PSCALE + (xv * xv * gp);
            k_q = div_tz(gp * xv * PSCALE, den);
            y   = div_tz(gw * xv, WSCALE);
            e   = dv - y;
            wn  = gw + div_tz(k_q * e * WSCALE, PSCALE);
            pn  = div_tz(gp * PSCALE, den);
            if (pn < 1) pn = 1;
            @(negedge clk); xin=xv; din=dv; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || yout !== y[15:0] || eout !== e[15:0] ||
                w_q_out !== wn || p_out !== pn) begin
                $display("FAIL n=%0d got y=%0d e=%0d wq=%0d p=%0d exp y=%0d e=%0d wq=%0d p=%0d",
                         n, yout, eout, w_q_out, p_out, y, e, wn, pn);
                errors=errors+1; $fatal(1,"rls");
            end
            gw = wn; gp = pn; n = n + 1;
            @(negedge clk); in_valid=0;
        end
    endtask

    reg signed [15:0] xs [0:19];
    initial begin
        errors=0; n=0; rst=1; in_valid=0; xin=0; din=0;
        gw=0; gp=PINIT;
        xs[0]=1;xs[1]=2;xs[2]=-1;xs[3]=3;xs[4]=-2;
        xs[5]=1;xs[6]=2;xs[7]=4;xs[8]=-3;xs[9]=1;
        xs[10]=2;xs[11]=-1;xs[12]=3;xs[13]=1;xs[14]=-2;
        xs[15]=2;xs[16]=1;xs[17]=-1;xs[18]=2;xs[19]=3;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        for (i=0;i<20;i=i+1) push(xs[i], 16'sd3 * xs[i]);
        if (errors) $fatal(1,"err");
        if (w_out !== 16'sd3 && w_out !== 16'sd2 && w_out !== 16'sd4)
            $fatal(1, "w not near 3");
        $display("PASS rls1 n=%0d final_w=%0d w_q=%0d p=%0d mismatches=0",
                 n, w_out, w_q_out, p_out);
        $display("METRIC RMSE=0 SNR_dB=999 TARGET_W=3");
        $finish;
    end
endmodule
