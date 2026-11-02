`timescale 1ns/1ps
module tb_iir1;
    localparam signed [15:0] B0 = 16'sd1, B1 = 16'sd1, A1 = 16'sd1;
    localparam integer SHIFT = 1;
    localparam integer NVEC = 64;

    reg clk, rst, in_valid;
    reg  signed [15:0] din;
    wire out_valid;
    wire signed [15:0] dout;

    integer errors, n_checked, gx1, gy1;

    function automatic integer sat16;
        input integer v;
        begin
            if (v > 32767) sat16 = 32767;
            else if (v < -32768) sat16 = -32768;
            else sat16 = v;
        end
    endfunction

    iir1 #(.B0(B0), .B1(B1), .A1(A1), .SHIFT(SHIFT)) dut (
        .clk(clk), .rst(rst), .in_valid(in_valid), .din(din),
        .out_valid(out_valid), .dout(dout)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    reg signed [15:0] expect_q [0:NVEC+4];
    integer exp_wr, exp_rd;
    reg checking;

    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (dout !== expect_q[exp_rd]) begin
                    $display("FAIL n=%0d dout=%0d exp=%0d", n_checked, dout, expect_q[exp_rd]);
                    errors = errors + 1;
                    $fatal(1, "bit-exact");
                end
                n_checked = n_checked + 1;
                exp_rd = exp_rd + 1;
            end
        end
    end

    task automatic feed;
        input signed [15:0] s;
        integer acc, sh, y;
        begin
            acc = s * B0 + gx1 * B1 + gy1 * A1;
            sh  = acc >>> SHIFT;
            y   = sat16(sh);
            expect_q[exp_wr] = y;
            exp_wr = exp_wr + 1;
            gx1 = s;
            gy1 = y;
            @(negedge clk);
            din = s; in_valid = 1'b1;
            @(posedge clk);
        end
    endtask

    integer k;
    initial begin
        errors = 0; n_checked = 0; gx1 = 0; gy1 = 0; exp_wr = 0; exp_rd = 0;
        checking = 0; rst = 1; in_valid = 0; din = 0;
        repeat (3) @(posedge clk);
        rst = 0; @(posedge clk);
        checking = 1;

        feed(16'sd0);
        feed(16'sd1000);
        feed(16'sd1000);
        feed(16'sd1000);
        feed(-16'sd500);
        feed(16'sd0);
        feed(16'sd0);
        for (k = 0; k < 40; k = k + 1)
            feed($signed(16'h0 ^ (k * 37)));  // small pattern
        // impulse
        feed(16'sd2000);
        for (k = 0; k < 10; k = k + 1) feed(16'sd0);

        @(negedge clk); in_valid = 0;
        repeat (4) @(posedge clk);

        if (errors != 0 || n_checked == 0) $fatal(1, "fail");
        $display("PASS iir1 n_checked=%0d mismatches=0", n_checked);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
