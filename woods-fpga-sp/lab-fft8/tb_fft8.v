`timescale 1ns/1ps
module tb_fft8;
    reg clk, rst, in_valid;
    reg  signed [15:0] din_re, din_im;
    wire in_ready, out_valid, done;
    wire signed [15:0] dout_re, dout_im;

    integer errors, n_out, i;

    localparam signed [15:0] ONE_Q15 = 16'sd32767;
    localparam signed [15:0] COS_PI4 = 16'sd23170;

    reg signed [15:0] xin_r [0:7];
    reg signed [15:0] xin_i [0:7];
    reg signed [15:0] gxr [0:7];
    reg signed [15:0] gxi [0:7];

    function automatic [2:0] bitrev3;
        input [2:0] a;
        bitrev3 = {a[0], a[1], a[2]};
    endfunction

    function automatic signed [15:0] mul_q15;
        input signed [15:0] a, b;
        reg signed [31:0] p;
        begin p = a * b; mul_q15 = p >>> 15; end
    endfunction

    task automatic golden_fft;
        integer n, stage, bfly, ia, ib;
        reg signed [15:0] wr, wi, ar, ai, br, bi, pr, pi;
        reg signed [16:0] sr, si, dr, di;
        begin
            for (n = 0; n < 8; n = n + 1) begin
                gxr[bitrev3(n[2:0])] = xin_r[n];
                gxi[bitrev3(n[2:0])] = xin_i[n];
            end
            for (stage = 0; stage < 3; stage = stage + 1)
            for (bfly = 0; bfly < 4; bfly = bfly + 1) begin
                if (stage == 0) begin ia = bfly * 2; ib = ia + 1; end
                else if (stage == 1) begin
                    ia = ((bfly >> 1) << 2) | (bfly & 1);
                    ib = ia | 2;
                end else begin ia = bfly; ib = bfly + 4; end
                wr = ONE_Q15; wi = 0;
                if (stage == 1 && (bfly & 1)) begin wr = 0; wi = -ONE_Q15; end
                if (stage == 2) case (bfly)
                    0: begin wr = ONE_Q15; wi = 0; end
                    1: begin wr = COS_PI4; wi = -COS_PI4; end
                    2: begin wr = 0; wi = -ONE_Q15; end
                    default: begin wr = -COS_PI4; wi = -COS_PI4; end
                endcase
                ar = gxr[ia]; ai = gxi[ia];
                br = gxr[ib]; bi = gxi[ib];
                begin : cmul
                    reg signed [31:0] p_rr, p_ii, p_ri, p_ir;
                    p_rr = br * wr; p_ii = bi * wi;
                    p_ri = br * wi; p_ir = bi * wr;
                    pr = (p_rr - p_ii) >>> 15;
                    pi = (p_ri + p_ir) >>> 15;
                end
                sr = ar + pr; si = ai + pi;
                dr = ar - pr; di = ai - pi;
                gxr[ia] = sr >>> 1; gxi[ia] = si >>> 1;
                gxr[ib] = dr >>> 1; gxi[ib] = di >>> 1;
            end
        end
    endtask

    fft8 dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .din_re(din_re), .din_im(din_im),
        .in_ready(in_ready),
        .out_valid(out_valid), .dout_re(dout_re), .dout_im(dout_im),
        .done(done)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    task automatic run_vec;
        begin
            golden_fft;
            n_out = 0;
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk);
                while (in_ready !== 1'b1) @(negedge clk);
                din_re = xin_r[i]; din_im = xin_i[i]; in_valid = 1'b1;
                @(posedge clk);
            end
            @(negedge clk); in_valid = 1'b0;
            while (n_out < 8) begin
                @(posedge clk); #1;
                if (out_valid) begin
                    if (dout_re !== gxr[n_out] || dout_im !== gxi[n_out]) begin
                        $display("FAIL bin=%0d got=(%0d,%0d) exp=(%0d,%0d)",
                                 n_out, dout_re, dout_im, gxr[n_out], gxi[n_out]);
                        errors = errors + 1;
                        $fatal(1, "bit-exact");
                    end
                    n_out = n_out + 1;
                end
            end
            @(posedge clk);
        end
    endtask

    initial begin
        errors = 0;
        rst = 1; in_valid = 0; din_re = 0; din_im = 0;
        repeat (4) @(posedge clk);
        rst = 0; @(posedge clk);

        for (i = 0; i < 8; i = i + 1) begin xin_r[i] = 16'sd1000; xin_i[i] = 0; end
        run_vec;
        for (i = 0; i < 8; i = i + 1) begin xin_r[i] = 0; xin_i[i] = 0; end
        xin_r[0] = 16'sd8000;
        run_vec;
        for (i = 0; i < 8; i = i + 1) begin xin_r[i] = i * 16'sd100; xin_i[i] = 0; end
        run_vec;
        xin_r[0]=16'sd4000; xin_i[0]=0;
        xin_r[1]=0; xin_i[1]=-16'sd4000;
        xin_r[2]=-16'sd4000; xin_i[2]=0;
        xin_r[3]=0; xin_i[3]=16'sd4000;
        xin_r[4]=16'sd4000; xin_i[4]=0;
        xin_r[5]=0; xin_i[5]=-16'sd4000;
        xin_r[6]=-16'sd4000; xin_i[6]=0;
        xin_r[7]=0; xin_i[7]=16'sd4000;
        run_vec;

        if (errors != 0) $fatal(1, "errors");
        $display("PASS fft8 vectors=4 mismatches=0");
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
