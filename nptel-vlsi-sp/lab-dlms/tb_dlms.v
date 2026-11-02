`timescale 1ns/1ps
module tb_dlms;
    localparam integer MUSHIFT = 6, N = 400;

    reg clk, rst, in_valid;
    reg signed [15:0] xin, din;
    wire ov_l, ov_d;
    wire signed [15:0] y_l, e_l, w0_l, w1_l;
    wire signed [15:0] y_d, e_d, w0_d, w1_d;
    integer k;

    function automatic integer sat16;
        input integer v;
        begin
            if (v > 32767) sat16 = 32767;
            else if (v < -32768) sat16 = -32768;
            else sat16 = v;
        end
    endfunction

    lms2  #(.MUSHIFT(MUSHIFT)) u_l (
        .clk(clk),.rst(rst),.in_valid(in_valid),.xin(xin),.din(din),
        .out_valid(ov_l),.yout(y_l),.eout(e_l),.w0_out(w0_l),.w1_out(w1_l));
    dlms2 #(.MUSHIFT(MUSHIFT),.D(1)) u_d (
        .clk(clk),.rst(rst),.in_valid(in_valid),.xin(xin),.din(din),
        .out_valid(ov_d),.yout(y_d),.eout(e_d),.w0_out(w0_d),.w1_out(w1_d));

    initial begin clk=0; forever #5 clk=~clk; end

    initial begin
        rst=1; in_valid=0; xin=0; din=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        for (k = 0; k < N; k = k + 1) begin
            begin : f
                reg signed [15:0] x, d;
                x = ((k * 5) % 17) - 8;
                d = sat16(3 * x);
                @(negedge clk); xin=x; din=d; in_valid=1;
                @(posedge clk);
            end
        end
        @(negedge clk); in_valid=0;
        repeat(4) @(posedge clk);
        $display("INFO LMS  w0=%0d", w0_l);
        $display("INFO DLMS w0=%0d", w0_d);
        if (w0_l < 16'sd2 || w0_l > 16'sd4) $fatal(1, "LMS w0 not near 3");
        if (w0_d < 16'sd2 || w0_d > 16'sd4) $fatal(1, "DLMS w0 not near 3");
        $display("PASS dlms LMS+DLMS plant d=3x  LMS_w0=%0d DLMS_w0=%0d", w0_l, w0_d);
        $display("METRIC DLMS_D=1 MUSHIFT=6 SAME_PLANT=1");
        $finish;
    end
endmodule
