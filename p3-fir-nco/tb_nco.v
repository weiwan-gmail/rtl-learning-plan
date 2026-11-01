`timescale 1ns/1ps
// Self-checking TB for nco: bit-exact vs integer phase accumulator golden.
module tb_nco;
    localparam PH_W  = 32;
    localparam OUT_W = 16;
    localparam NVEC  = 200;

    reg                     clk, rst, in_valid;
    reg  [PH_W-1:0]         freq_word;
    wire                    out_valid;
    wire signed [OUT_W-1:0] dout;

    reg  [PH_W-1:0] gphase;
    reg  signed [OUT_W-1:0] expect_q [0:NVEC+128];
    integer exp_wr, exp_rd, n_checked, i, seed;
    reg checking;

    nco #(.PH_W(PH_W), .OUT_W(OUT_W)) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .freq_word(freq_word),
        .out_valid(out_valid), .dout(dout)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (exp_rd >= exp_wr) $fatal(1, "unexpected out");
                if (dout !== expect_q[exp_rd]) begin
                    $display("FAIL nco dout=%0h expect=%0h n=%0d",
                             dout, expect_q[exp_rd], n_checked);
                    $fatal(1, "nco bit-exact");
                end
                n_checked = n_checked + 1;
                exp_rd    = exp_rd + 1;
            end
        end
    end

    task automatic step_en;
        input [PH_W-1:0] fw;
        reg [PH_W-1:0] nxt;
        begin
            @(negedge clk);
            freq_word = fw;
            in_valid  = 1'b1;
            nxt       = gphase + fw;
            gphase    = nxt;
            expect_q[exp_wr] = nxt[PH_W-1 -: OUT_W];
            exp_wr = exp_wr + 1;
            @(posedge clk);
        end
    endtask

    task automatic idle;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk);
                in_valid = 1'b0;
                @(posedge clk);
            end
        end
    endtask

    initial begin
        n_checked = 0; exp_wr = 0; exp_rd = 0;
        gphase = 0; checking = 0; seed = 32'hC0000001;
        in_valid = 0; freq_word = 0; rst = 1;

        repeat (3) @(posedge clk);
        @(negedge clk); rst = 0;
        @(posedge clk); checking = 1;

        // constant freq
        for (i = 0; i < 64; i = i + 1)
            step_en(32'h1000_0000);
        idle(3);
        $display("PASS nco constant fw (checked=%0d)", n_checked);

        // bubbles + varying fw
        for (i = 0; i < NVEC; i = i + 1) begin
            if (($random(seed) & 5) == 0) idle(1 + ($random(seed) & 2));
            step_en($random(seed));
        end
        idle(4);
        $display("PASS nco random (checked=%0d)", n_checked);

        if (exp_rd != exp_wr) $fatal(1, "leftover");
        $display("METRIC nco bit-exact=YES checked=%0d", n_checked);
        $display("PASS nco");
        $finish;
    end

    initial begin #2_000_000; $fatal(1, "timeout"); end
endmodule
