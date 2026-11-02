`timescale 1ns/1ps
module tb_da_fir4;
    reg clk, rst, in_valid;
    reg  signed [15:0] din;
    wire out_valid;
    wire signed [15:0] dout;

    integer errors, n_checked;
    integer hx0, hx1, hx2, hx3;
    integer expect_q [0:127];
    integer exp_wr, exp_rd;
    reg checking;

    da_fir4 dut (
        .clk(clk), .rst(rst), .in_valid(in_valid), .din(din),
        .out_valid(out_valid), .dout(dout)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    function automatic integer golden_y;
        input integer a0, a1, a2, a3;
        begin
            golden_y = 1*a0 + 2*a1 + 2*a2 + 1*a3;
        end
    endfunction

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
        input integer s; // 0..255
        integer y;
        begin
            // update delay (newest = x0)
            hx3 = hx2; hx2 = hx1; hx1 = hx0; hx0 = s;
            y = golden_y(hx0, hx1, hx2, hx3);
            expect_q[exp_wr] = y;
            exp_wr = exp_wr + 1;
            @(negedge clk);
            din = s; in_valid = 1'b1;
            @(posedge clk);
            @(negedge clk); in_valid = 1'b0;
            // wait for result
            wait (out_valid === 1'b1);
            @(posedge clk);
            @(negedge clk);
        end
    endtask

    integer k;
    initial begin
        errors = 0; n_checked = 0; exp_wr = 0; exp_rd = 0;
        hx0 = 0; hx1 = 0; hx2 = 0; hx3 = 0;
        checking = 0; rst = 1; in_valid = 0; din = 0;
        repeat (3) @(posedge clk);
        rst = 0; @(posedge clk);
        checking = 1;

        feed(0);
        feed(1);
        feed(2);
        feed(3);
        feed(10);
        feed(255);
        feed(128);
        for (k = 0; k < 20; k = k + 1)
            feed((k * 13) & 255);

        repeat (2) @(posedge clk);
        if (errors != 0 || n_checked == 0) $fatal(1, "fail");
        $display("PASS da_fir4 n_checked=%0d mismatches=0", n_checked);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
