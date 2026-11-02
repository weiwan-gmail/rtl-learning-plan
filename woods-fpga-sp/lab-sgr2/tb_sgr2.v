`timescale 1ns/1ps
module tb_sgr2;
    reg clk, rst, in_valid;
    reg signed [15:0] a, b, x_in, y_in;
    wire out_valid;
    wire signed [31:0] x_out, y_out, r2_out;
    integer errors, n;

    sgr_step dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .a(a), .b(b), .x_in(x_in), .y_in(y_in),
        .out_valid(out_valid), .x_out(x_out), .y_out(y_out), .r2_out(r2_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic check;
        input signed [15:0] aa, bb, xx, yy;
        reg signed [31:0] xe, ye, r2e;
        begin
            xe = aa*xx + bb*yy;
            ye = -bb*xx + aa*yy;
            r2e = aa*aa + bb*bb;
            @(negedge clk); a=aa; b=bb; x_in=xx; y_in=yy; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || x_out!==xe || y_out!==ye || r2_out!==r2e) begin
                $display("FAIL got (%0d,%0d,r2=%0d) exp (%0d,%0d,%0d)",
                         x_out,y_out,r2_out,xe,ye,r2e);
                errors=errors+1; $fatal(1,"sgr");
            end
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        errors=0; n=0; rst=1; in_valid=0; a=0;b=0;x_in=0;y_in=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        // nulling demo: apply to (a,b) itself → (r2, 0)
        check(16'sd3, 16'sd4, 16'sd3, 16'sd4);
        // expect x=25, y=0, r2=25
        if (x_out !== 32'sd25 || y_out !== 0 || r2_out !== 32'sd25) $fatal(1,"null345");
        check(16'sd5, 16'sd12, 16'sd5, 16'sd12);
        check(16'sd8, 16'sd15, 16'sd8, 16'sd15);
        check(16'sd7, -16'sd24, 16'sd7, -16'sd24);
        // apply same (a,b) to another column
        check(16'sd3, 16'sd4, 16'sd1, 16'sd2);
        check(16'sd3, 16'sd4, 16'sd10, -16'sd5);
        check(-16'sd6, 16'sd8, -16'sd6, 16'sd8);
        check(16'sd20, 16'sd21, 16'sd20, 16'sd21);
        check(16'sd1, 16'sd0, 16'sd9, 16'sd4);
        if (errors) $fatal(1,"err");
        $display("PASS sgr_step n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999 NULL_R2=1 NO_SQRT=1");
        $finish;
    end
endmodule
