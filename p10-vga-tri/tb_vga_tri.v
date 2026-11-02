`timescale 1ns/1ps
// Self-checking TB: fill P8 triangle, then assert P4 VGA sync + scaled pixels.
// Strategy: 640x480 timing, NN scale 10x; golden = same edge-function as P8.
module tb_vga_tri;
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
    localparam integer FB_W    = 64;
    localparam integer FB_H    = 48;
    localparam integer SCALE_X = H_RES / FB_W; // 10
    localparam integer SCALE_Y = V_RES / FB_H; // 10
    localparam integer FB_SZ   = FB_W * FB_H;
    localparam integer CORD_W  = 8;
    localparam integer COLOR_W = 1;

    reg         clk, rst, start, do_clear;
    reg  [CORD_W-1:0] x0, y0, x1, y1, x2, y2;
    reg  [COLOR_W-1:0] color;
    wire        busy, done;
    wire        hsync, vsync, de;
    wire [9:0]  x, y;
    wire [7:0]  r, g, b;

    reg  [COLOR_W-1:0] golden [0:FB_SZ-1];
    integer errors, filled_g, filled_vga, mismatch;
    integer h_period_meas, v_period_meas, h_periods_ok;
    integer i, cyc, fd, fx, fy, pix;
    integer ax, ay, bx, by, cx, cy, area, e0, e1, e2, inside;
    integer expect_on, got_on;

    vga_tri #(
        .H_RES(H_RES), .H_FP(H_FP), .H_SYNC(H_SYNC), .H_BP(H_BP),
        .V_RES(V_RES), .V_FP(V_FP), .V_SYNC(V_SYNC), .V_BP(V_BP),
        .FB_W(FB_W), .FB_H(FB_H), .CORD_W(CORD_W), .COLOR_W(COLOR_W)
    ) dut (
        .clk(clk), .rst(rst),
        .start(start), .do_clear(do_clear),
        .x0(x0), .y0(y0), .x1(x1), .y1(y1), .x2(x2), .y2(y2),
        .color(color),
        .busy(busy), .done(done),
        .hsync(hsync), .vsync(vsync), .de(de),
        .x(x), .y(y), .r(r), .g(g), .b(b)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    initial cyc = 0;
    always @(posedge clk) cyc = cyc + 1;

    task automatic tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    function integer edge_i;
        input integer pax, pay, pbx, pby, ppx, ppy;
        begin
            edge_i = (ppx - pax) * (pby - pay) - (ppy - pay) * (pbx - pax);
        end
    endfunction

    task build_golden;
        begin
            for (pix = 0; pix < FB_SZ; pix = pix + 1)
                golden[pix] = 0;
            area = edge_i(ax, ay, bx, by, cx, cy);
            for (fy = 0; fy < FB_H; fy = fy + 1) begin
                for (fx = 0; fx < FB_W; fx = fx + 1) begin
                    e0 = edge_i(bx, by, cx, cy, fx, fy);
                    e1 = edge_i(cx, cy, ax, ay, fx, fy);
                    e2 = edge_i(ax, ay, bx, by, fx, fy);
                    inside = 0;
                    if (area > 0)
                        inside = (e0 >= 0) && (e1 >= 0) && (e2 >= 0);
                    else if (area < 0)
                        inside = (e0 <= 0) && (e1 <= 0) && (e2 <= 0);
                    if (inside)
                        golden[fy * FB_W + fx] = 1'b1;
                end
            end
            filled_g = 0;
            for (pix = 0; pix < FB_SZ; pix = pix + 1)
                if (golden[pix]) filled_g = filled_g + 1;
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

    // Dump 64x48 PPM by sampling each FB cell center through VGA RGB path
    task dump_frame_ppm;
        integer xx, yy, sx, sy, v;
        begin
            fd = $fopen("frame.ppm", "w");
            if (fd == 0) $fatal(1, "fopen frame.ppm");
            $fwrite(fd, "P3\n%0d %0d\n255\n", FB_W, FB_H);
            // Must be positioned at start of a frame active; caller syncs
            for (yy = 0; yy < FB_H; yy = yy + 1) begin
                for (xx = 0; xx < FB_W; xx = xx + 1) begin
                    sx = xx * SCALE_X + (SCALE_X / 2);
                    sy = yy * SCALE_Y + (SCALE_Y / 2);
                    while (!(de && (x == sx[9:0]) && (y == sy[9:0]))) tick;
                    v = (r == 8'hFF) ? 255 : 0;
                    if ((g !== r) || (b !== r)) begin
                        $display("FAIL ppm sample rgb not gray @fb(%0d,%0d)", xx, yy);
                        $fatal(1, "rgb");
                    end
                    $fwrite(fd, "%0d %0d %0d\n", v, v, v);
                end
            end
            $fclose(fd);
            $display("METRIC wrote frame.ppm %0dx%0d (VGA-sampled centers)", FB_W, FB_H);
        end
    endtask

    initial begin
        errors = 0; mismatch = 0; filled_vga = 0;
        h_periods_ok = 0;
        start = 0; do_clear = 0; color = 0;
        x0 = 0; y0 = 0; x1 = 0; y1 = 0; x2 = 0; y2 = 0;
        rst = 1'b1;

        repeat (4) tick;
        rst = 1'b0;
        tick;

        // ---- Fill P8 case1 CCW triangle ----
        ax=10; ay=5; bx=50; by=8; cx=28; cy=40;
        build_golden;
        $display("METRIC golden_filled=%0d (P8 case1 expect 676)", filled_g);
        if (filled_g !== 676) $fatal(1, "golden count");

        @(negedge clk);
        x0 = ax[CORD_W-1:0]; y0 = ay[CORD_W-1:0];
        x1 = bx[CORD_W-1:0]; y1 = by[CORD_W-1:0];
        x2 = cx[CORD_W-1:0]; y2 = cy[CORD_W-1:0];
        color    = 1'b1;
        do_clear = 1'b1;
        start    = 1'b1;
        @(negedge clk);
        start = 1'b0;
        @(posedge clk);
        while (!busy) @(posedge clk);
        while (busy) @(posedge clk);
        @(posedge clk);
        $display("METRIC tri_fill done");

        // ---- hsync periods (P4 style) ----
        wait_fall(1'b0);
        for (i = 0; i < 4; i = i + 1) begin
            measure_period_from_low(1'b0, h_period_meas);
            $display("METRIC hsync_period[%0d]=%0d (expect %0d)", i, h_period_meas, H_TOTAL);
            if (h_period_meas !== H_TOTAL) $fatal(1, "hsync_period");
            h_periods_ok = h_periods_ok + 1;
        end

        // ---- hsync width ----
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
        $display("METRIC vsync_period=%0d (expect %0d)", v_period_meas, FRAME_CLKS);
        if (v_period_meas !== FRAME_CLKS) $fatal(1, "vsync_period");

        // ---- vsync width ----
        begin : vsync_width
            integer vlow_clks;
            vlow_clks = 0;
            while (vsync === 1'b0) begin
                vlow_clks = vlow_clks + 1;
                tick;
            end
            $display("METRIC vsync_width_clks=%0d (expect %0d)", vlow_clks, V_SYNC * H_TOTAL);
            if (vlow_clks !== (V_SYNC * H_TOTAL)) $fatal(1, "vsync_width");
        end

        // ---- Sync to first active pixel; compare full active frame bit-exact ----
        while (!(de && (x == 10'd0) && (y == 10'd0))) tick;
        filled_vga = 0;
        mismatch   = 0;
        begin : scan_frame
            integer n_active;
            n_active = 0;
            while (n_active < (H_RES * V_RES)) begin
                if (de) begin
                    fx = x / SCALE_X;
                    fy = y / SCALE_Y;
                    expect_on = golden[fy * FB_W + fx];
                    got_on    = (r == 8'hFF) && (g == 8'hFF) && (b == 8'hFF);
                    if (!de) begin end
                    if (expect_on) begin
                        if (!(r == 8'hFF && g == 8'hFF && b == 8'hFF)) begin
                            $display("FAIL pix miss x=%0d y=%0d fb=(%0d,%0d) rgb=%02h%02h%02h",
                                     x, y, fx, fy, r, g, b);
                            mismatch = mismatch + 1;
                            $fatal(1, "pixel miss");
                        end
                        filled_vga = filled_vga + 1;
                    end else begin
                        if (r !== 8'h00 || g !== 8'h00 || b !== 8'h00) begin
                            $display("FAIL pix extra x=%0d y=%0d fb=(%0d,%0d) rgb=%02h%02h%02h",
                                     x, y, fx, fy, r, g, b);
                            mismatch = mismatch + 1;
                            $fatal(1, "pixel extra");
                        end
                    end
                    n_active = n_active + 1;
                end else begin
                    if (r !== 8'h00 || g !== 8'h00 || b !== 8'h00)
                        $fatal(1, "blank rgb");
                end
                tick;
            end
        end

        $display("METRIC active_white_pixels=%0d (expect %0d = %0d*%0d*%0d)",
                 filled_vga, filled_g * SCALE_X * SCALE_Y, filled_g, SCALE_X, SCALE_Y);
        if (filled_vga !== (filled_g * SCALE_X * SCALE_Y))
            $fatal(1, "vga fill count");

        // ---- Dump 64x48 PPM via VGA-sampled cell centers ----
        while (!(de && (x == 10'd0) && (y == 10'd0))) tick;
        dump_frame_ppm;

        // Verify PPM samples matched golden (recount from file not needed —
        // dump_frame_ppm already saw RGB; spot-check filled centers count)
        $display("PASS vga_tri h_periods_ok=%0d vsync_period=%0d filled_fb=%0d filled_vga=%0d scale=%0dx%0d",
                 h_periods_ok, v_period_meas, filled_g, filled_vga, SCALE_X, SCALE_Y);
        $display("PASS vga_tri sync+pixels bit-exact");
        $finish;
    end

    initial begin
        // fill ~3k + a few frames + ppm sample walk
        wait (cyc > (FRAME_CLKS * 8 + 100000));
        $display("FAIL timeout cyc=%0d", cyc);
        $fatal(1, "timeout");
    end
endmodule
