`timescale 1ns/1ps
// Self-checking TB for sdr_loop (NCO|DC → fir4 → cic_decim).
// Compares ordered output samples to a sample-domain integer golden
// (bit-exact). Prints DC settle + tone RMSE/SNR metrics.
module tb_sdr_loop;
    localparam integer PH_W  = 32;
    localparam integer IN_W  = 16;
    localparam integer OUT_W = 20;
    localparam integer N     = 2;
    localparam integer R     = 4;
    localparam integer M     = 1;
    localparam integer H0 = 1, H1 = 2, H2 = 2, H3 = 1;
    localparam integer SHIFT = 0;
    localparam integer GAIN_CIC = 16; // (R*M)^N
    localparam integer SUM_H    = 6;  // 1+2+2+1
    localparam integer MAX_OUT  = 4096;

    reg                     clk, rst, in_valid, src_is_dc;
    reg  [PH_W-1:0]         freq_word;
    reg  signed [IN_W-1:0]  dc_val;
    wire                    out_valid;
    wire signed [OUT_W-1:0] dout;

    integer errors, n_checked, n_in;
    integer expect_q [0:MAX_OUT];
    integer exp_wr, exp_rd;
    reg     checking;

    // Sample-domain golden state
    reg [PH_W-1:0] g_phase;
    reg signed [IN_W-1:0] gx0, gx1, gx2, gx3;
    integer gi0, gi1, gd0, gd1, gcnt;

    // Metric accumulators (tone case)
    real sse, ref_energy;
    integer tone_n;

    sdr_loop #(
        .PH_W(PH_W), .IN_W(IN_W), .OUT_W(OUT_W),
        .N(N), .R(R), .M(M)
    ) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid),
        .freq_word(freq_word),
        .src_is_dc(src_is_dc),
        .dc_val(dc_val),
        .out_valid(out_valid),
        .dout(dout)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    function automatic signed [15:0] fir_mac;
        input signed [15:0] a0, a1, a2, a3;
        reg signed [33:0] acc, sh;
        begin
            acc = a0*H0 + a1*H1 + a2*H2 + a3*H3;
            sh  = acc >>> SHIFT;
            if (sh > 34'sd32767)       fir_mac = 16'sd32767;
            else if (sh < -34'sd32768) fir_mac = -16'sd32768;
            else                       fir_mac = sh[15:0];
        end
    endfunction

    function automatic integer sext20;
        input integer v;
        begin
            sext20 = (v << (32-OUT_W)) >>> (32-OUT_W);
        end
    endfunction

    task automatic golden_reset;
        begin
            g_phase = 0;
            gx0 = 0; gx1 = 0; gx2 = 0; gx3 = 0;
            gi0 = 0; gi1 = 0; gd0 = 0; gd1 = 0; gcnt = 0;
            exp_wr = 0; exp_rd = 0;
        end
    endtask

    // Push one FIR input sample through FIR + CIC golden (sample domain).
    task automatic golden_fir_cic_push;
        input signed [15:0] s;
        reg signed [15:0] f;
        integer i0n, i1n, c0, c1;
        begin
            f   = fir_mac(s, gx0, gx1, gx2);
            gx3 = gx2; gx2 = gx1; gx1 = gx0; gx0 = s;

            i0n = sext20(gi0 + f);
            i1n = sext20(gi1 + i0n);
            gi0 = i0n;
            gi1 = i1n;
            if (gcnt == R - 1) begin
                c0 = sext20(i1n - gd0);
                c1 = sext20(c0 - gd1);
                gd0 = i1n;
                gd1 = c0;
                if (exp_wr >= MAX_OUT) $fatal(1, "expect overflow");
                expect_q[exp_wr] = c1;
                exp_wr = exp_wr + 1;
                gcnt = 0;
            end else begin
                gcnt = gcnt + 1;
            end
        end
    endtask

    // One top-level enabled beat → NCO or DC → FIR/CIC golden.
    task automatic golden_push_top;
        input integer is_dc;
        input signed [15:0] dc;
        input [PH_W-1:0] fw;
        reg [PH_W-1:0] nxt;
        reg signed [15:0] s;
        begin
            if (is_dc) begin
                s = dc;
            end else begin
                nxt     = g_phase + fw;
                g_phase = nxt;
                s       = nxt[PH_W-1 -: IN_W];
            end
            golden_fir_cic_push(s);
        end
    endtask

    always @(posedge clk) begin
        if (!rst && checking) begin
            #1;
            if (out_valid) begin
                if (exp_rd >= exp_wr) begin
                    $display("FAIL unexpected out_valid n_checked=%0d exp_wr=%0d",
                             n_checked, exp_wr);
                    $fatal(1, "unexpected out");
                end
                if (dout !== expect_q[exp_rd][OUT_W-1:0]) begin
                    $display("FAIL bit-exact n=%0d dout=%0d expect=%0d",
                             n_checked, $signed(dout), expect_q[exp_rd]);
                    errors = errors + 1;
                    $fatal(1, "bit-exact");
                end
                // tone metrics
                sse = sse + (dout - expect_q[exp_rd]) * (dout - expect_q[exp_rd]);
                ref_energy = ref_energy + expect_q[exp_rd] * expect_q[exp_rd];
                tone_n = tone_n + 1;

                n_checked = n_checked + 1;
                exp_rd    = exp_rd + 1;
            end
        end
    end

    task automatic feed;
        input integer is_dc;
        input signed [15:0] dc;
        input [PH_W-1:0] fw;
        begin
            @(negedge clk);
            src_is_dc = is_dc[0];
            dc_val    = dc;
            freq_word = fw;
            in_valid  = 1'b1;
            golden_push_top(is_dc, dc, fw);
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
                @(posedge clk);
            end
        end
    endtask

    task automatic run_dc_case;
        input signed [15:0] A;
        input integer n_samp;
        integer k, expect_dc, ok, settle_from;
        begin
            $display("CASE DC A=%0d n=%0d", A, n_samp);
            golden_reset;
            n_in = 0; n_checked = 0; errors = 0;
            sse = 0; ref_energy = 0; tone_n = 0;
            checking = 1;
            for (k = 0; k < n_samp; k = k + 1)
                feed(1, A, 32'h0);
            // Drain pipeline bubbles (NCO/FIR/CIC NBA skew)
            idle(32);
            checking = 0;

            if (n_checked != exp_wr)
                $fatal(1, "DC count mismatch checked=%0d expect=%0d",
                       n_checked, exp_wr);

            expect_dc = A * SUM_H * GAIN_CIC;
            // Last 4 outputs (after FIR+CIC settle) must equal DC gain
            if (n_checked < 8) $fatal(1, "DC too few outs");
            settle_from = n_checked - 4;
            ok = 1;
            for (k = settle_from; k < n_checked; k = k + 1) begin
                if (expect_q[k] !== expect_dc) ok = 0;
            end
            if (!ok) begin
                $display("FAIL DC settle expect=%0d last=%0d",
                         expect_dc, expect_q[n_checked-1]);
                $fatal(1, "DC settle");
            end
            $display("METRIC DC settle=%0d (= A*sumH*(R*M)^N) n_out=%0d",
                     expect_dc, n_checked);
            $display("PASS sdr_loop DC bit-exact A=%0d", A);
        end
    endtask

    task automatic run_tone_case;
        input [PH_W-1:0] fw;
        input integer n_samp;
        real rmse, snr_db;
        integer k;
        begin
            $display("CASE TONE fw=0x%08h n=%0d", fw, n_samp);
            golden_reset;
            n_in = 0; n_checked = 0; errors = 0;
            sse = 0; ref_energy = 0; tone_n = 0;
            checking = 1;
            for (k = 0; k < n_samp; k = k + 1)
                feed(0, 16'sd0, fw);
            idle(32);
            checking = 0;

            if (n_checked != exp_wr)
                $fatal(1, "TONE count mismatch checked=%0d expect=%0d",
                       n_checked, exp_wr);
            if (errors != 0) $fatal(1, "TONE errors");

            if (tone_n == 0) $fatal(1, "no tone outs");
            rmse = (sse <= 0.0) ? 0.0 : $sqrt(sse / tone_n);
            if (sse <= 0.0)
                snr_db = 999.0;
            else if (ref_energy <= 0.0)
                snr_db = 0.0;
            else
                snr_db = 10.0 * $log10(ref_energy / sse);

            $display("METRIC RMSE=%0f SNR_dB=%0f n_out=%0d",
                     rmse, snr_db, n_checked);
            if (rmse > 0.0) $fatal(1, "TONE RMSE not bit-exact");
            $display("PASS sdr_loop TONE bit-exact fw=0x%08h", fw);
        end
    endtask

    initial begin
        errors = 0; n_checked = 0; n_in = 0;
        checking = 0; in_valid = 0; src_is_dc = 0;
        freq_word = 0; dc_val = 0; rst = 1;
        golden_reset;

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        idle(2);

        // DC path: constant into FIR → CIC
        run_dc_case(16'sd3, 256);

        // Need re-reset between cases (DUT + golden)
        @(negedge clk); rst = 1;
        idle(4);
        @(negedge clk); rst = 0;
        idle(2);

        run_dc_case(-16'sd2, 128);

        @(negedge clk); rst = 1;
        idle(4);
        @(negedge clk); rst = 0;
        idle(2);

        // NCO sawtooth tone → FIR → CIC
        run_tone_case(32'h1000_0000, 512);

        @(negedge clk); rst = 1;
        idle(4);
        @(negedge clk); rst = 0;
        idle(2);

        run_tone_case(32'h0400_0000, 512);

        $display("PASS sdr_loop all cases bit-exact");
        $finish;
    end
endmodule
