`timescale 1ns/1ps
// Self-checking TB for vga_timing + vga_bars (640x480@60 classic).
// Asserts: hsync/vsync periods & widths, active de width/lines, RGB bars.
module tb_vga;
    localparam integer H_RES   = 640;
    localparam integer H_FP    = 16;
    localparam integer H_SYNC  = 96;
    localparam integer H_BP    = 48;
    localparam integer V_RES   = 480;
    localparam integer V_FP    = 10;
    localparam integer V_SYNC  = 2;
    localparam integer V_BP    = 33;
    localparam integer H_TOTAL = H_RES + H_FP + H_SYNC + H_BP; // 800
    localparam integer V_TOTAL = V_RES + V_FP + V_SYNC + V_BP; // 525
    localparam integer FRAME_CLKS = H_TOTAL * V_TOTAL;         // 420000
    localparam integer BAR_W = H_RES / 8;                      // 80

    reg         clk;
    reg         rst;
    wire        hsync, vsync, de;
    wire [9:0]  x, y;
    wire [7:0]  r, g, b;

    integer errors;
    integer h_period_meas, v_period_meas;
    integer h_periods_ok, v_periods_ok;
    integer de_active_line, de_lines_frame;
    integer i, cyc;

    vga_timing #(
        .H_RES(H_RES), .H_FP(H_FP), .H_SYNC(H_SYNC), .H_BP(H_BP),
        .V_RES(V_RES), .V_FP(V_FP), .V_SYNC(V_SYNC), .V_BP(V_BP)
    ) u_timing (
        .clk(clk), .rst(rst),
        .hsync(hsync), .vsync(vsync), .de(de),
        .x(x), .y(y)
    );

    vga_bars #(.H_RES(H_RES)) u_bars (
        .de(de), .x(x), .y(y),
        .r(r), .g(g), .b(b)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    initial cyc = 0;
    always @(posedge clk) cyc = cyc + 1;

    // Advance one pixel clock and settle comb outputs
    task automatic tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic expect_rgb;
        input [9:0] px;
        input [7:0] er, eg, eb;
        input [8*40-1:0] tag;
        begin
            if (!de) begin
                $display("FAIL [%0s] de=0 at sample x=%0d y=%0d", tag, x, y);
                $fatal(1, "de at sample");
            end
            if (x !== px) begin
                $display("FAIL [%0s] x=%0d expect=%0d", tag, x, px);
                $fatal(1, "x");
            end
            if (r !== er || g !== eg || b !== eb) begin
                $display("FAIL [%0s] rgb=%02h%02h%02h expect=%02h%02h%02h x=%0d y=%0d",
                         tag, r, g, b, er, eg, eb, x, y);
                $fatal(1, "rgb");
            end
        end
    endtask

    task automatic bar_rgb;
        input  [2:0] bi;
        output [7:0] er, eg, eb;
        begin
            case (bi)
                3'd0: begin er = 8'hFF; eg = 8'hFF; eb = 8'hFF; end
                3'd1: begin er = 8'hFF; eg = 8'hFF; eb = 8'h00; end
                3'd2: begin er = 8'h00; eg = 8'hFF; eb = 8'hFF; end
                3'd3: begin er = 8'h00; eg = 8'hFF; eb = 8'h00; end
                3'd4: begin er = 8'hFF; eg = 8'h00; eb = 8'hFF; end
                3'd5: begin er = 8'hFF; eg = 8'h00; eb = 8'h00; end
                3'd6: begin er = 8'h00; eg = 8'h00; eb = 8'hFF; end
                default: begin er = 8'h00; eg = 8'h00; eb = 8'h00; end
            endcase
        end
    endtask

    task automatic wait_fall;
        input which; // 0=hsync 1=vsync
        begin
            if (which == 1'b0) begin
                if (hsync === 1'b0) begin
                    while (hsync === 1'b0) tick;
                end
                while (hsync !== 1'b0) tick;
            end else begin
                if (vsync === 1'b0) begin
                    while (vsync === 1'b0) tick;
                end
                while (vsync !== 1'b0) tick;
            end
        end
    endtask

    // From current sync-low cycle to next sync-low: period == TOTAL
    task automatic measure_period_from_low;
        input which;
        output integer period;
        begin
            period = 0;
            if (which == 1'b0) begin
                tick; period = 1;
                while (hsync === 1'b0) begin tick; period = period + 1; end
                while (hsync !== 1'b0) begin tick; period = period + 1; end
            end else begin
                tick; period = 1;
                while (vsync === 1'b0) begin tick; period = period + 1; end
                while (vsync !== 1'b0) begin tick; period = period + 1; end
            end
        end
    endtask

    initial begin
        errors         = 0;
        h_period_meas  = 0;
        v_period_meas  = 0;
        h_periods_ok   = 0;
        v_periods_ok   = 0;
        de_active_line = 0;
        de_lines_frame = 0;
        rst = 1'b1;

        repeat (4) tick;
        rst = 1'b0;
        tick;

        // ---- hsync periods ----
        wait_fall(1'b0);
        for (i = 0; i < 4; i = i + 1) begin
            measure_period_from_low(1'b0, h_period_meas);
            $display("METRIC hsync_period[%0d]=%0d (expect %0d)", i, h_period_meas, H_TOTAL);
            if (h_period_meas !== H_TOTAL) $fatal(1, "hsync_period");
            h_periods_ok = h_periods_ok + 1;
        end

        // ---- hsync pulse width (currently at start of low) ----
        begin : hsync_width
            integer w;
            w = 0;
            while (hsync === 1'b0) begin
                w = w + 1;
                tick;
            end
            $display("METRIC hsync_width=%0d (expect %0d)", w, H_SYNC);
            if (w !== H_SYNC) $fatal(1, "hsync_width");
        end

        // ---- vsync period ----
        wait_fall(1'b1);
        measure_period_from_low(1'b1, v_period_meas);
        $display("METRIC vsync_period=%0d (expect %0d = %0d*%0d)",
                 v_period_meas, FRAME_CLKS, H_TOTAL, V_TOTAL);
        if (v_period_meas !== FRAME_CLKS) $fatal(1, "vsync_period");
        v_periods_ok = 1;

        // ---- vsync width in clocks ----
        begin : vsync_width
            integer vlow_clks, v_lines;
            vlow_clks = 0;
            while (vsync === 1'b0) begin
                vlow_clks = vlow_clks + 1;
                tick;
            end
            v_lines = vlow_clks / H_TOTAL;
            $display("METRIC vsync_width_clks=%0d lines=%0d (expect clks=%0d lines=%0d)",
                     vlow_clks, v_lines, V_SYNC * H_TOTAL, V_SYNC);
            if (vlow_clks !== (V_SYNC * H_TOTAL)) $fatal(1, "vsync_width");
        end

        // ---- sync to first active pixel of a frame ----
        while (!(de && (x == 10'd0) && (y == 10'd0))) tick;

        // Count continuous de on this line (include current pixel)
        de_active_line = 0;
        while (de === 1'b1) begin
            de_active_line = de_active_line + 1;
            tick;
        end
        $display("METRIC de_active_pixels_line0=%0d (expect %0d)", de_active_line, H_RES);
        if (de_active_line !== H_RES) $fatal(1, "de_line");

        // Sample 8 bar centers on y=100
        while (!(de && (y == 10'd100) && (x == 10'd0))) tick;
        begin : sample_bars
            integer bi;
            reg [7:0] er, eg, eb;
            reg [9:0] sx;
            for (bi = 0; bi < 8; bi = bi + 1) begin
                sx = bi * BAR_W + (BAR_W / 2);
                while (!(de && (y == 10'd100) && (x == sx))) tick;
                bar_rgb(bi[2:0], er, eg, eb);
                expect_rgb(sx, er, eg, eb, "bar_center");
                $display("METRIC bar[%0d]@x=%0d rgb=%02h%02h%02h OK", bi, sx, r, g, b);
            end
        end

        // Blanking after active on y=50
        while (!(y == 10'd50 && x == 10'd0 && de)) tick;
        while (de === 1'b1) tick;
        if (de !== 1'b0 || r !== 8'h00 || g !== 8'h00 || b !== 8'h00)
            $fatal(1, "blank");
        $display("METRIC blanking_rgb=000000 OK");

        // Active lines over one full frame
        while (!(de && (x == 10'd0) && (y == 10'd0))) tick;
        de_lines_frame = 0;
        begin : count_lines
            integer seen_y;
            seen_y = -1;
            for (i = 0; i < FRAME_CLKS; i = i + 1) begin
                if (de && (x == 10'd0) && (y != seen_y)) begin
                    de_lines_frame = de_lines_frame + 1;
                    seen_y = y;
                end
                tick;
            end
        end
        $display("METRIC active_lines_per_frame=%0d (expect %0d)", de_lines_frame, V_RES);
        if (de_lines_frame !== V_RES) $fatal(1, "active_lines");

        $display("PASS vga h_periods_ok=%0d v_periods_ok=%0d H_TOTAL=%0d V_TOTAL=%0d FRAME_CLKS=%0d",
                 h_periods_ok, v_periods_ok, H_TOTAL, V_TOTAL, FRAME_CLKS);
        $display("PASS vga_timing+vga_bars");
        $finish;
    end

    initial begin
        wait (cyc > FRAME_CLKS * 10);
        $display("FAIL timeout cyc=%0d", cyc);
        $fatal(1, "timeout");
    end
endmodule
