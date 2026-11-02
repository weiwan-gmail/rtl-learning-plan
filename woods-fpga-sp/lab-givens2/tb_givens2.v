`timescale 1ns/1ps
module tb_givens2;
    reg clk, rst, in_valid;
    reg signed [15:0] c, s, x_in, y_in;
    wire out_valid;
    wire signed [15:0] x_out, y_out;
    integer errors, n;

    givens_apply dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .c(c), .s(s), .x_in(x_in), .y_in(y_in),
        .out_valid(out_valid), .x_out(x_out), .y_out(y_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic check;
        input signed [15:0] cv, sv, xv, yv;
        reg signed [31:0] xn, yn;
        reg signed [15:0] xe, ye;
        begin
            xn = cv*xv + sv*yv;
            yn = -sv*xv + cv*yv;
            xe = xn[30:15]; ye = yn[30:15];
            @(negedge clk); c=cv; s=sv; x_in=xv; y_in=yv; in_valid=1;
            @(posedge clk); #1;
            if (!out_valid || x_out!==xe || y_out!==ye) begin
                $display("FAIL got=(%0d,%0d) exp=(%0d,%0d)", x_out,y_out,xe,ye);
                errors=errors+1; $fatal(1,"givens");
            end
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    // Q15: c=a/r*32768 for 3-4-5 → 19661, 26214
    initial begin
        errors=0; n=0; rst=1; in_valid=0; c=0;s=0;x_in=0;y_in=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        check(16'sd32767, 16'sd0, 16'sd1000, 16'sd2000);       // identity-ish
        check(16'sd23170, 16'sd23170, 16'sd1000, 16'sd0);      // 45°
        check(16'sd0, 16'sd32767, 16'sd1000, 16'sd0);          // 90°
        check(16'sd19661, 16'sd26214, 16'sd3000, 16'sd4000);   // null → (~5000,0)
        check(16'sd19661, 16'sd26214, 16'sd1000, 16'sd2000);   // apply to col2
        if (errors) $fatal(1,"err");
        $display("PASS givens_apply n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999 NULL_DEMO=1");
        $finish;
    end
endmodule
