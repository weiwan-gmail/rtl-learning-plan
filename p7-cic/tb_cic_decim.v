`timescale 1ns/1ps
// Self-checking TB for cic_decim: bit-exact vs integer golden (N=2,R=4,M=1).
module tb_cic_decim;
    localparam integer N     = 2;
    localparam integer R     = 4;
    localparam integer M     = 1;
    localparam integer IN_W  = 16;
    localparam integer OUT_W = 20;
    localparam integer NVEC  = 256;

    reg                     clk, rst, in_valid;
    reg  signed [IN_W-1:0]  din;
    wire                    out_valid;
    wire signed [OUT_W-1:0] dout;

    integer errors, n_checked, n_in, seed;
    integer gi0, gi1, gd0, gd1, gcnt;
    integer expect_q [0:NVEC+16];
    integer exp_wr, exp_rd;
    reg     checking;

    cic_decim #(
        .N(N), .R(R), .M(M), .IN_W(IN_W), .OUT_W(OUT_W)
    ) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .din(din),
        .out_valid(out_valid), .dout(dout)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    // Golden step matching RTL: same-cycle integrator cascade + M=1 combs on strobe.
    task automatic golden_push;
        input integer s;  // signed sample
        integer i0n, i1n, c0, c1;
        begin
            i0n = gi0 + s;
            i1n = gi1 + i0n;
            // wrap to OUT_W two's complement
            i0n = (i0n << (32-OUT_W)) >>> (32-OUT_W);
            i1n = (i1n << (32-OUT_W)) >>> (32-OUT_W);
            gi0 = i0n;
            gi1 = i1n;
            if (gcnt == R - 1) begin
                c0 = i1n - gd0;
                c1 = c0 - gd1;
                c0 = (c0 << (32-OUT_W)) >>> (32-OUT_W);
                c1 = (c1 << (32-OUT_W)) >>> (32-OUT_W);
                gd0 = i1n;
                gd1 = c0;
                expect_q[exp_wr] = c1;
                exp_wr = exp_wr + 1;
                gcnt = 0;
            end else begin
                gcnt = gcnt + 1;
            end
        end
    endtask

    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (exp_rd >= exp_wr) begin
                    $display("FAIL unexpected out_valid n_checked=%0d", n_checked);
                    $fatal(1, "unexpected out");
                end
                if (dout !== expect_q[exp_rd][OUT_W-1:0]) begin
                    $display("FAIL bit-exact n=%0d dout=%0d expect=%0d",
                             n_checked, dout, expect_q[exp_rd]);
                    errors = errors + 1;
                    $fatal(1, "bit-exact");
                end
                n_checked = n_checked + 1;
                exp_rd    = exp_rd + 1;
            end
        end
    end

    task automatic feed;
        input signed [IN_W-1:0] s;
        begin
            @(negedge clk);
            din      = s;
            in_valid = 1'b1;
            golden_push(s);
            n_in = n_in + 1;
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
                din      = 0;
                @(posedge clk);
            end
        end
    endtask

    initial begin
        errors = 0; n_checked = 0; n_in = 0; seed = 32'hC1C00001;
        gi0 = 0; gi1 = 0; gd0 = 0; gd1 = 0; gcnt = 0;
        exp_wr = 0; exp_rd = 0; checking = 0;
        clk = 0; rst = 1; in_valid = 0; din = 0;

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        @(posedge clk);
        checking = 1;

        // --- DC ramp: 0,1,2,... ---
        begin : ramp
            integer t;
            for (t = 0; t < 64; t = t + 1)
                feed(t[IN_W-1:0]);
        end
        idle(4);

        // --- alternating +/-1 ---
        begin : alt
            integer t;
            for (t = 0; t < 64; t = t + 1)
                feed(t[0] ? -16'sd1 : 16'sd1);
        end
        idle(4);

        // --- random ---
        begin : rnd
            integer t, r;
            for (t = 0; t < NVEC; t = t + 1) begin
                r = $random(seed);
                feed(r[IN_W-1:0]);
            end
        end
        idle(8);

        checking = 0;
        if (n_checked == 0) begin
            $display("FAIL no outputs checked");
            $fatal(1, "no outputs");
        end
        if (exp_rd != exp_wr) begin
            $display("FAIL pending expects exp_wr=%0d exp_rd=%0d", exp_wr, exp_rd);
            $fatal(1, "pending");
        end
        // Expect floor(n_in/R) outputs
        if (n_checked !== (64 + 64 + NVEC) / R) begin
            $display("FAIL count n_checked=%0d expect=%0d",
                     n_checked, (64 + 64 + NVEC) / R);
            $fatal(1, "count");
        end

        $display("PASS cic_decim bit-exact n_in=%0d n_out=%0d N=%0d R=%0d M=%0d",
                 n_in, n_checked, N, R, M);
        $finish;
    end
endmodule
