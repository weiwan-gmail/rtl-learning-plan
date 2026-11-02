`timescale 1ns/1ps
module tb_biquad;
    reg clk, rst, in_valid;
    reg signed [15:0] x_in, b0, b1, b2, a1, a2;
    wire out_valid;
    wire signed [15:0] y_out;
    integer errors, n, i;

    // Fixed coeffs: simple lowpass-ish Q15
    // b0=b1=b2=8192 (0.25), a1=-16384 (-0.5), a2=8192 (0.25)
    localparam signed [15:0] B0 = 16'sd8192;
    localparam signed [15:0] B1 = 16'sd8192;
    localparam signed [15:0] B2 = 16'sd8192;
    localparam signed [15:0] A1 = -16'sd16384;
    localparam signed [15:0] A2 = 16'sd8192;

    reg signed [15:0] gx1, gx2, gy1, gy2;
    reg signed [31:0] gacc;
    reg signed [15:0] gy;

    biquad_df1 dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .x_in(x_in), .b0(b0), .b1(b1), .b2(b2), .a1(a1), .a2(a2),
        .out_valid(out_valid), .y_out(y_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic push;
        input signed [15:0] xv;
        begin
            gacc = B0*xv + B1*gx1 + B2*gx2 - A1*gy1 - A2*gy2;
            gy = gacc[30:15];
            @(negedge clk); x_in=xv; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || y_out !== gy) begin
                $display("FAIL i=%0d got=%0d exp=%0d", n, y_out, gy);
                errors=errors+1; $fatal(1,"biquad");
            end
            gx2=gx1; gx1=xv; gy2=gy1; gy1=gy;
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        errors=0; n=0; rst=1; in_valid=0; x_in=0;
        b0=B0; b1=B1; b2=B2; a1=A1; a2=A2;
        gx1=0; gx2=0; gy1=0; gy2=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        push(16'sd0); push(16'sd1000); push(16'sd2000);
        push(16'sd3000); push(-16'sd1000); push(16'sd500);
        for (i=0;i<20;i=i+1) push($random >>> 18); // keep small
        if (errors) $fatal(1,"err");
        $display("PASS biquad_df1 n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
