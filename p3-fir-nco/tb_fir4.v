`timescale 1ns/1ps
// Self-checking TB for fir4: bit-exact vs integer golden (same coeffs + LATENCY).
module tb_fir4;
    localparam signed [15:0] H0 = 16'sd1;
    localparam signed [15:0] H1 = 16'sd2;
    localparam signed [15:0] H2 = 16'sd2;
    localparam signed [15:0] H3 = 16'sd1;
    localparam integer       SHIFT   = 0;
    localparam integer       LATENCY = 1;  // registered MAC stage
    localparam integer       NVEC    = 256;

    reg                   clk, rst, in_valid;
    reg  signed [15:0]    din;
    wire                  out_valid;
    wire signed [15:0]    dout;

    integer errors, i, seed;
    reg signed [15:0] gx0, gx1, gx2, gx3;
    reg signed [15:0] expect_q [0:NVEC+64];
    integer exp_wr, exp_rd, n_checked, pending;
    real sum_err2, sum_ref2, rmse, snr_db, diff;
    reg  checking;

    fir4 #(.H0(H0), .H1(H1), .H2(H2), .H3(H3), .SHIFT(SHIFT)) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .din(din),
        .out_valid(out_valid), .dout(dout)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    function automatic signed [15:0] golden_mac;
        input signed [15:0] a0, a1, a2, a3;
        reg signed [31:0] p0, p1, p2, p3;
        reg signed [33:0] acc, sh;
        begin
            p0 = a0 * H0; p1 = a1 * H1; p2 = a2 * H2; p3 = a3 * H3;
            acc = {{2{p0[31]}}, p0} + {{2{p1[31]}}, p1}
                + {{2{p2[31]}}, p2} + {{2{p3[31]}}, p3};
            sh = acc >>> SHIFT;
            if (sh > 34'sd32767)       golden_mac = 16'sd32767;
            else if (sh < -34'sd32768) golden_mac = -16'sd32768;
            else                       golden_mac = sh[15:0];
        end
    endfunction

    // Compare after each rising edge (NBA settled)
    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (exp_rd >= exp_wr) begin
                    $display("FAIL unexpected out_valid");
                    $fatal(1, "unexpected out");
                end
                if (dout !== expect_q[exp_rd]) begin
                    $display("FAIL bit-exact n=%0d dout=%0d expect=%0d",
                             n_checked, dout, expect_q[exp_rd]);
                    $fatal(1, "bit-exact");
                end
                diff      = dout - expect_q[exp_rd];
                sum_err2  = sum_err2 + diff * diff;
                sum_ref2  = sum_ref2 + 1.0 * expect_q[exp_rd] * expect_q[exp_rd];
                n_checked = n_checked + 1;
                exp_rd    = exp_rd + 1;
                pending   = pending - 1;
            end
        end
    end

    // Queue golden for a sample that will be captured on the next posedge.
    // Call only while sitting just after a negedge (or with in_valid already
    // being set for this half-cycle).
    task automatic queue_sample;
        input signed [15:0] s;
        reg signed [15:0] y;
        begin
            din      = s;
            in_valid = 1'b1;
            y        = golden_mac(s, gx0, gx1, gx2);
            gx3 = gx2; gx2 = gx1; gx1 = gx0; gx0 = s;
            expect_q[exp_wr] = y;
            exp_wr  = exp_wr + 1;
            pending = pending + 1;
        end
    endtask

    task automatic apply_sample;
        input signed [15:0] s;
        begin
            @(negedge clk);
            queue_sample(s);
            @(posedge clk); // DUT capture + checker
        end
    endtask

    task automatic idle_cycles;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk);
                in_valid = 1'b0;
                din      = 16'sd0;
                @(posedge clk);
            end
        end
    endtask

    initial begin
        errors = 0; n_checked = 0; exp_wr = 0; exp_rd = 0; pending = 0;
        sum_err2 = 0.0; sum_ref2 = 0.0;
        seed = 32'hF1840001;
        checking = 0;
        gx0 = 0; gx1 = 0; gx2 = 0; gx3 = 0;
        in_valid = 0; din = 0; rst = 1;

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        @(posedge clk);
        checking = 1;

        // Impulse
        apply_sample(16'sd1000);
        idle_cycles(1);
        apply_sample(16'sd0);
        apply_sample(16'sd0);
        apply_sample(16'sd0);
        apply_sample(16'sd0);
        idle_cycles(3);
        $display("PASS directed impulse (checked=%0d)", n_checked);

        // Step
        for (i = 0; i < 8; i = i + 1) apply_sample(16'sd500);
        idle_cycles(3);
        $display("PASS directed step (checked=%0d)", n_checked);

        // Alternating
        for (i = 0; i < 16; i = i + 1)
            apply_sample(i[0] ? -16'sd2000 : 16'sd2000);
        idle_cycles(3);
        $display("PASS directed alt (checked=%0d)", n_checked);

        // Valid gaps
        apply_sample(16'sd111);
        idle_cycles(3);
        apply_sample(16'sd222);
        idle_cycles(1);
        apply_sample(-16'sd333);
        idle_cycles(3);
        $display("PASS valid-gap bubbles (checked=%0d)", n_checked);

        // Random + bubbles
        for (i = 0; i < NVEC; i = i + 1) begin
            if (($random(seed) & 7) == 0)
                idle_cycles(1 + ($random(seed) & 3));
            apply_sample($random(seed));
        end
        idle_cycles(5);
        $display("PASS random stream (checked=%0d)", n_checked);

        // Saturation corners (coeffs sum=6 → 6*32767 needs sat)
        apply_sample(16'sd32767);
        apply_sample(16'sd32767);
        apply_sample(16'sd32767);
        apply_sample(16'sd32767);
        apply_sample(-16'sd32768);
        apply_sample(-16'sd32768);
        apply_sample(-16'sd32768);
        apply_sample(-16'sd32768);
        idle_cycles(5);
        $display("PASS saturation corners (checked=%0d)", n_checked);

        if (exp_rd != exp_wr || pending != 0) begin
            $display("FAIL leftover rd=%0d wr=%0d pending=%0d",
                     exp_rd, exp_wr, pending);
            $fatal(1, "queue leftover");
        end
        if (n_checked < 100) begin
            $display("FAIL too few checked=%0d", n_checked);
            $fatal(1, "coverage");
        end

        rmse = $sqrt(sum_err2 / n_checked);
        snr_db = (sum_err2 == 0.0) ? 999.0 : 10.0 * $log10(sum_ref2 / sum_err2);

        $display("METRIC bit-exact=YES mismatches=0 checked=%0d", n_checked);
        $display("METRIC RMSE=%0f SNR_dB=%0f (999=+inf bit-exact)", rmse, snr_db);
        $display("PASS tb_fir4 LATENCY=%0d coeffs=[%0d,%0d,%0d,%0d] SHIFT=%0d",
                 LATENCY, H0, H1, H2, H3, SHIFT);
        $display("PASS fir4");
        $finish;
    end

    initial begin
        #5_000_000;
        $fatal(1, "timeout");
    end
endmodule
