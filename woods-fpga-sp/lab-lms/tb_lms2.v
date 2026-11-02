`timescale 1ns/1ps
module tb_lms2;
    localparam integer WSHIFT = 0;
    localparam integer MUSHIFT = 5;
    localparam integer N = 256;

    reg clk, rst, in_valid;
    reg  signed [15:0] xin, din;
    wire out_valid;
    wire signed [15:0] yout, eout, w0_out, w1_out;

    integer errors, n_checked;
    integer gx0, gw0, gw1;
    integer expect_y [0:N+4];
    integer expect_e [0:N+4];
    integer exp_wr, exp_rd;
    reg checking;

    function automatic integer sat16;
        input integer v;
        begin
            if (v > 32767) sat16 = 32767;
            else if (v < -32768) sat16 = -32768;
            else sat16 = v;
        end
    endfunction

    lms2 #(.WSHIFT(WSHIFT), .MUSHIFT(MUSHIFT)) dut (
        .clk(clk), .rst(rst), .in_valid(in_valid),
        .xin(xin), .din(din),
        .out_valid(out_valid), .yout(yout), .eout(eout),
        .w0_out(w0_out), .w1_out(w1_out)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (yout !== expect_y[exp_rd] || eout !== expect_e[exp_rd]) begin
                    $display("FAIL n=%0d y=%0d/%0d e=%0d/%0d",
                             n_checked, yout, expect_y[exp_rd], eout, expect_e[exp_rd]);
                    errors = errors + 1;
                    $fatal(1, "bit-exact");
                end
                n_checked = n_checked + 1;
                exp_rd = exp_rd + 1;
            end
        end
    end

    task automatic feed;
        input signed [15:0] x;
        input signed [15:0] d;
        integer nx0, nx1, acc, y, e, nw0, nw1;
        begin
            nx0 = x; nx1 = gx0;
            acc = nx0 * gw0 + nx1 * gw1;
            y = sat16(acc >>> WSHIFT);
            e = sat16(d - y);
            nw0 = sat16(gw0 + ((e * nx0) >>> MUSHIFT));
            nw1 = sat16(gw1 + ((e * nx1) >>> MUSHIFT));
            expect_y[exp_wr] = y;
            expect_e[exp_wr] = e;
            exp_wr = exp_wr + 1;
            gx0 = nx0; gw0 = nw0; gw1 = nw1;
            @(negedge clk);
            xin = x; din = d; in_valid = 1'b1;
            @(posedge clk);
        end
    endtask

    integer k, px;
    reg signed [15:0] x, d;
    initial begin
        errors = 0; n_checked = 0; exp_wr = 0; exp_rd = 0;
        gx0 = 0; gw0 = 0; gw1 = 0; px = 0;
        checking = 0; rst = 1; in_valid = 0; xin = 0; din = 0;
        repeat (3) @(posedge clk);
        rst = 0; @(posedge clk);
        checking = 1;

        // plant: d = 2*x + 1*x_prev; small bipolar x via LFSR-ish
        for (k = 0; k < N; k = k + 1) begin
            x = ((k * 5) % 17) - 8;  // -8..8
            d = sat16(2 * x + 1 * px);
            feed(x, d);
            px = x;
        end
        @(negedge clk); in_valid = 0;
        repeat (4) @(posedge clk);

        if (errors != 0 || n_checked != N) $fatal(1, "fail n=%0d", n_checked);
        $display("INFO final w0=%0d w1=%0d (plant 2, 1)", w0_out, w1_out);
        if (w0_out < 16'sd1 || w0_out > 16'sd3) $fatal(1, "w0 not converged");
        if (w1_out < 16'sd0 || w1_out > 16'sd2) $fatal(1, "w1 not converged");
        $display("PASS lms2 n_checked=%0d mismatches=0", n_checked);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
