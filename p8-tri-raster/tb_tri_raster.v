`timescale 1ns/1ps
// Self-checking TB for tri_raster: bit-exact vs integer edge-function golden.
module tb_tri_raster;
    localparam integer W       = 64;
    localparam integer H       = 48;
    localparam integer CORD_W  = 8;
    localparam integer COLOR_W = 1;
    localparam integer FB_SZ   = W * H;
    localparam integer ADDR_W  = 12;

    reg                      clk, rst, start, do_clear;
    reg  [CORD_W-1:0]        x0, y0, x1, y1, x2, y2;
    reg  [COLOR_W-1:0]       color;
    wire                     busy, done;
    reg  [ADDR_W-1:0]        rd_addr;
    wire [COLOR_W-1:0]       rd_data;

    reg  [COLOR_W-1:0]       golden [0:FB_SZ-1];
    integer errors, filled_rtl, filled_g, pix, n_case;
    integer fd;
    integer x, y, area, e0, e1, e2, inside;
    integer ax, ay, bx, by, cx, cy, col, do_clr;

    tri_raster #(
        .W(W), .H(H), .CORD_W(CORD_W), .COLOR_W(COLOR_W)
    ) dut (
        .clk(clk), .rst(rst),
        .start(start), .do_clear(do_clear),
        .x0(x0), .y0(y0), .x1(x1), .y1(y1), .x2(x2), .y2(y2),
        .color(color),
        .busy(busy), .done(done),
        .rd_addr(rd_addr), .rd_data(rd_data)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    function integer edge_i;
        input integer pax, pay, pbx, pby, ppx, ppy;
        begin
            edge_i = (ppx - pax) * (pby - pay) - (ppy - pay) * (pbx - pax);
        end
    endfunction

    task build_golden;
        begin
            if (do_clr) begin
                for (pix = 0; pix < FB_SZ; pix = pix + 1)
                    golden[pix] = 0;
            end
            area = edge_i(ax, ay, bx, by, cx, cy);
            for (y = 0; y < H; y = y + 1) begin
                for (x = 0; x < W; x = x + 1) begin
                    e0 = edge_i(bx, by, cx, cy, x, y);
                    e1 = edge_i(cx, cy, ax, ay, x, y);
                    e2 = edge_i(ax, ay, bx, by, x, y);
                    inside = 0;
                    if (area > 0)
                        inside = (e0 >= 0) && (e1 >= 0) && (e2 >= 0);
                    else if (area < 0)
                        inside = (e0 <= 0) && (e1 <= 0) && (e2 <= 0);
                    if (inside)
                        golden[y * W + x] = col[0];
                end
            end
        end
    endtask

    task run_tri;
        begin
            build_golden;
            @(negedge clk);
            x0 = ax[CORD_W-1:0]; y0 = ay[CORD_W-1:0];
            x1 = bx[CORD_W-1:0]; y1 = by[CORD_W-1:0];
            x2 = cx[CORD_W-1:0]; y2 = cy[CORD_W-1:0];
            color    = col[0];
            do_clear = do_clr[0];
            start    = 1'b1;
            @(negedge clk);
            start = 1'b0;
            @(posedge clk);
            while (!busy) @(posedge clk);
            while (busy) @(posedge clk);
            @(posedge clk);
        end
    endtask

    task check_fb;
        input [8*32-1:0] name;
        begin
            filled_rtl = 0;
            filled_g   = 0;
            for (pix = 0; pix < FB_SZ; pix = pix + 1) begin
                rd_addr = pix[ADDR_W-1:0];
                #1;
                if (rd_data !== golden[pix]) begin
                    $display("FAIL %0s pix=%0d rtl=%0d gold=%0d",
                             name, pix, rd_data, golden[pix]);
                    errors = errors + 1;
                    $fatal(1, "pixel mismatch");
                end
                if (rd_data != 0) filled_rtl = filled_rtl + 1;
                if (golden[pix] != 0) filled_g = filled_g + 1;
            end
            if (filled_rtl !== filled_g) begin
                $display("FAIL %0s fill count rtl=%0d gold=%0d",
                         name, filled_rtl, filled_g);
                $fatal(1, "count");
            end
            $display("PASS case %0s filled=%0d", name, filled_rtl);
        end
    endtask

    task dump_ppm;
        input [8*32-1:0] path;
        integer xx, yy, v;
        begin
            fd = $fopen(path, "w");
            if (fd == 0) $fatal(1, "fopen");
            $fwrite(fd, "P3\n%0d %0d\n255\n", W, H);
            for (yy = 0; yy < H; yy = yy + 1) begin
                for (xx = 0; xx < W; xx = xx + 1) begin
                    rd_addr = yy * W + xx;
                    #1;
                    v = rd_data ? 255 : 0;
                    $fwrite(fd, "%0d %0d %0d\n", v, v, v);
                end
            end
            $fclose(fd);
        end
    endtask

    initial begin
        errors = 0; n_case = 0;
        clk = 0; rst = 1; start = 0; do_clear = 0;
        x0 = 0; y0 = 0; x1 = 0; y1 = 0; x2 = 0; y2 = 0;
        color = 0; rd_addr = 0;
        ax = 0; ay = 0; bx = 0; by = 0; cx = 0; cy = 0; col = 0; do_clr = 0;

        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;
        @(posedge clk);

        // Case 1: CCW triangle fully on-screen
        n_case = 1;
        ax=10; ay=5; bx=50; by=8; cx=28; cy=40; col=1; do_clr=1;
        run_tri;
        check_fb("ccw_on");
        dump_ppm("tri_case1.ppm");

        // Case 2: CW triangle
        n_case = 2;
        ax=10; ay=5; bx=28; by=40; cx=50; cy=8; col=1; do_clr=1;
        run_tri;
        check_fb("cw_on");

        // Case 3: degenerate (colinear)
        n_case = 3;
        ax=5; ay=5; bx=20; by=5; cx=40; cy=5; col=1; do_clr=1;
        run_tri;
        check_fb("degenerate");
        if (filled_rtl !== 0) begin
            $display("FAIL degenerate expected 0 got %0d", filled_rtl);
            $fatal(1, "degenerate");
        end

        // Case 4: partially off-screen
        n_case = 4;
        ax=50; ay=10; bx=80; by=20; cx=55; cy=45; col=1; do_clr=1;
        run_tri;
        check_fb("clip_partial");
        dump_ppm("tri_case4.ppm");

        if (errors != 0) $fatal(1, "errors");
        $display("PASS tri_raster bit-exact W=%0d H=%0d cases=%0d",
                 W, H, n_case);
        $finish;
    end

    initial begin
        #50_000_000;
        $display("FAIL timeout");
        $fatal(1, "timeout");
    end
endmodule
