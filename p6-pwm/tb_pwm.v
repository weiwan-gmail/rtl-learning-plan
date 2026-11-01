`timescale 1ns/1ps
// Self-checking TB for counter-compare pwm.
// Asserts: period (clocks), duty high-time, rising/falling edges; $fatal on mismatch.
module tb_pwm;
    localparam W = 16;

    reg             clk;
    reg             rst;
    reg  [W-1:0]    period;
    reg  [W-1:0]    duty;
    wire            pwm_out;

    integer errors;
    integer cycle;
    reg     prev;

    pwm #(.W(W)) dut (
        .clk(clk), .rst(rst),
        .period(period), .duty(duty),
        .pwm_out(pwm_out)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    task automatic fail;
        input [8*64-1:0] tag;
        begin
            $display("FAIL [%0s] cycle=%0d p=%0d d=%0d pwm=%b",
                     tag, cycle, period, duty, pwm_out);
            errors = errors + 1;
            $fatal(1, "ASSERT %0s", tag);
        end
    endtask

    // Sync reset then one active edge so cnt starts from a known point.
    task automatic rearm;
        input [W-1:0] p;
        input [W-1:0] d;
        begin
            @(negedge clk);
            period = p;
            duty   = d;
            rst    = 1'b1;
            @(posedge clk); cycle = cycle + 1;
            @(negedge clk);
            rst = 1'b0;
            @(posedge clk); cycle = cycle + 1; // first active: sample cnt=0 into pwm_out
            #1;
            prev = pwm_out;
        end
    endtask

    // Sample N clocks after rearm; accumulate high samples and edge counts.
    task automatic sample_n;
        input integer n;
        output integer high_n;
        output integer rises;
        output integer falls;
        integer i;
        begin
            high_n = 0;
            rises  = 0;
            falls  = 0;
            // count current level as first sample of the window
            if (pwm_out) high_n = 1;
            for (i = 1; i < n; i = i + 1) begin
                @(posedge clk); cycle = cycle + 1; #1;
                if (!prev && pwm_out) rises = rises + 1;
                if (prev && !pwm_out) falls = falls + 1;
                if (pwm_out) high_n = high_n + 1;
                prev = pwm_out;
            end
        end
    endtask

    // For 0 < duty < period: wait for rising edge, then measure until next rise.
    task automatic measure_pwm_cycle;
        output integer period_meas;
        output integer high_meas;
        output integer rises;
        output integer falls;
        integer guard;
        integer ticks;
        integer highs;
        integer peff;
        begin
            peff = (period == 0) ? 1 : period;
            rises = 0; falls = 0; ticks = 0; highs = 0; guard = 0;

            // Seek rising edge (or accept already-high at cycle start after rearm
            // when duty>0: first active edge already produced pwm=1 from cnt=0.
            // Treat that as the start without requiring a transition.
            if (pwm_out === 1'b1) begin
                // already in high phase at window start
                rises = 1;
            end else begin
                while (pwm_out !== 1'b1 && guard < peff * 4 + 8) begin
                    @(posedge clk); cycle = cycle + 1; #1;
                    if (!prev && pwm_out) rises = rises + 1;
                    prev = pwm_out;
                    guard = guard + 1;
                end
                if (pwm_out !== 1'b1) fail("seek_rise");
                if (rises < 1) rises = 1;
            end

            // Now at first high sample of a cycle. Count until next rising edge.
            ticks = 1;
            highs = 1;
            prev  = pwm_out;
            guard = 0;
            while (guard < peff * 4 + 8) begin
                @(posedge clk); cycle = cycle + 1; #1;
                if (!prev && pwm_out) begin
                    // next rise — cycle complete; do not include this sample
                    rises = rises + 1;
                    period_meas = ticks;
                    high_meas   = highs;
                    prev = pwm_out;
                    disable measure_pwm_cycle;
                end
                if (prev && !pwm_out) falls = falls + 1;
                ticks = ticks + 1;
                if (pwm_out) highs = highs + 1;
                prev  = pwm_out;
                guard = guard + 1;
            end
            fail("cycle_timeout");
        end
    endtask

    task automatic check_modulated;
        input [W-1:0] p;
        input [W-1:0] d;
        input [8*48-1:0] tag;
        integer pm, hm, sr, sf;
        begin
            rearm(p, d);
            measure_pwm_cycle(pm, hm, sr, sf);
            if (pm !== p) begin
                $display("period got=%0d exp=%0d", pm, p);
                fail({tag, "_period"});
            end
            if (hm !== d) begin
                $display("duty got=%0d exp=%0d", hm, d);
                fail({tag, "_duty"});
            end
            if (sr < 2) fail({tag, "_edges_rise"});
            if (sf < 1) fail({tag, "_edges_fall"});
            $display("PASS %0s period=%0d duty_high=%0d rises=%0d falls=%0d",
                     tag, pm, hm, sr, sf);
        end
    endtask

    task automatic check_flat;
        input [W-1:0] p;
        input [W-1:0] d;
        input integer exp_high_per_period;
        input [8*48-1:0] tag;
        integer hn, sr, sf;
        integer peff;
        begin
            peff = (p == 0) ? 1 : p;
            rearm(p, d);
            // sample exactly two periods
            sample_n(peff * 2, hn, sr, sf);
            if (hn !== (exp_high_per_period * 2)) begin
                $display("flat high got=%0d exp=%0d", hn, exp_high_per_period * 2);
                fail({tag, "_duty"});
            end
            // no edges for always-low / always-high after initial level
            if (sr !== 0) fail({tag, "_unexpected_rise"});
            if (sf !== 0) fail({tag, "_unexpected_fall"});
            $display("PASS %0s flat high/period=%0d over 2*period rises=%0d falls=%0d",
                     tag, exp_high_per_period, sr, sf);
        end
    endtask

    initial begin
        errors = 0;
        cycle  = 0;
        period = 16'd8;
        duty   = 16'd4;
        rst    = 1'b1;
        prev   = 1'b0;

        repeat (3) @(posedge clk);
        cycle = cycle + 3;
        #1;
        if (pwm_out !== 1'b0) fail("reset_pwm_low");
        $display("PASS reset");

        check_modulated(16'd8,  16'd4,  "p8_d4");
        check_modulated(16'd16, 16'd4,  "p16_d4");
        check_modulated(16'd16, 16'd12, "p16_d12");
        check_modulated(16'd7,  16'd3,  "p7_d3");
        check_modulated(16'd64, 16'd17, "p64_d17");
        check_modulated(16'd5,  16'd1,  "p5_d1");
        check_modulated(16'd5,  16'd4,  "p5_d4");

        check_flat(16'd10, 16'd0,   0,  "p10_d0");
        check_flat(16'd10, 16'd10, 10,  "p10_d10");
        check_flat(16'd8,  16'd100, 8,  "p8_d100");
        check_flat(16'd1,  16'd0,   0,  "p1_d0");
        check_flat(16'd1,  16'd1,   1,  "p1_d1");

        if (errors == 0) begin
            $display("PASS pwm style=counter-compare cycles=%0d", cycle);
            $display("PASS pwm");
        end else
            $fatal(1, "tb_pwm FAILED errors=%0d", errors);
        $finish;
    end

    initial begin
        #10_000_000;
        $fatal(1, "timeout");
    end
endmodule
