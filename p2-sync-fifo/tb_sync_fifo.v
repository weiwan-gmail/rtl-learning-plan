`timescale 1ns/1ps
// Self-checking TB for sync_fifo: directed + random golden queue.
module tb_sync_fifo;
    localparam WIDTH = 8;
    localparam DEPTH = 8;
    localparam CNT_W = $clog2(DEPTH) + 1;
    localparam QMAX  = 4096;

    reg                   clk;
    reg                   rst;
    reg                   wr_en;
    reg                   rd_en;
    reg  [WIDTH-1:0]      din;
    wire [WIDTH-1:0]      dout;
    wire                  full;
    wire                  empty;
    wire [CNT_W-1:0]      count;

    integer errors;
    integer cycle;
    integer i;

    // golden software queue
    reg [WIDTH-1:0] gq [0:QMAX-1];
    integer g_head, g_tail, g_n;
    reg [WIDTH-1:0] expect_d;
    reg             expect_valid;  // dout should match after accepted read

    // shadow of accepted ops for same-cycle bookkeeping
    integer seed;

    sync_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk  (clk),
        .rst  (rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din  (din),
        .dout (dout),
        .full (full),
        .empty(empty),
        .count(count)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task fatal_check;
        input cond;
        input [8*64-1:0] tag;
        begin
            if (!cond) begin
                $display("FAIL [%0s] cycle=%0d full=%b empty=%b count=%0d dout=%02h",
                         tag, cycle, full, empty, count, dout);
                errors = errors + 1;
                $fatal(1, "ASSERT %0s", tag);
            end
        end
    endtask

    task gq_push;
        input [WIDTH-1:0] d;
        begin
            fatal_check(g_n < QMAX, "golden_overflow");
            gq[g_tail] = d;
            g_tail = (g_tail + 1) % QMAX;
            g_n = g_n + 1;
        end
    endtask

    task gq_pop;
        output [WIDTH-1:0] d;
        begin
            fatal_check(g_n > 0, "golden_underflow");
            d = gq[g_head];
            g_head = (g_head + 1) % QMAX;
            g_n = g_n - 1;
        end
    endtask

    // Apply wr/rd at posedge; sample flags/dout on following negedge.
    // Tracks golden: push on accepted write; pop+check dout on accepted read
    // (registered dout updates on the same accepted-read posedge).
    task tick;
        input do_wr;
        input do_rd;
        input [WIDTH-1:0] d_in;
        reg will_wr;
        reg will_rd;
        reg [WIDTH-1:0] popped;
        begin
            @(negedge clk);
            // protocol discipline: TB may *attempt* wr when full / rd when empty;
            // DUT must ignore. Track expected accepted ops from current flags.
            will_wr = do_wr & ~full;
            will_rd = do_rd & ~empty;

            wr_en = do_wr;
            rd_en = do_rd;
            din   = d_in;

            @(posedge clk);
            cycle = cycle + 1;

            if (will_wr)
                gq_push(d_in);
            if (will_rd) begin
                gq_pop(popped);
                expect_d     = popped;
                expect_valid = 1'b1;
            end else begin
                expect_valid = 1'b0;
            end

            @(negedge clk);
            wr_en = 1'b0;
            rd_en = 1'b0;

            // count vs golden depth
            fatal_check(count == g_n[CNT_W-1:0], "count_vs_golden");
            fatal_check(full  == (g_n == DEPTH), "full_flag");
            fatal_check(empty == (g_n == 0),     "empty_flag");
            // never both full and empty unless DEPTH==0 (impossible)
            fatal_check(!(full & empty), "full_and_empty");

            if (expect_valid)
                fatal_check(dout === expect_d, "dout_order");
        end
    endtask

    task reset_dut;
        begin
            wr_en = 1'b0;
            rd_en = 1'b0;
            din   = {WIDTH{1'b0}};
            rst   = 1'b1;
            g_head = 0; g_tail = 0; g_n = 0;
            expect_valid = 1'b0;
            repeat (3) begin
                @(posedge clk);
                cycle = cycle + 1;
            end
            @(negedge clk);
            fatal_check(empty == 1'b1, "rst_empty");
            fatal_check(full  == 1'b0, "rst_not_full");
            fatal_check(count == {CNT_W{1'b0}}, "rst_count0");
            rst = 1'b0;
            @(posedge clk);
            cycle = cycle + 1;
            @(negedge clk);
        end
    endtask

    initial begin
        errors = 0;
        cycle  = 0;
        seed   = 32'hC0FFEE01;
        wr_en  = 1'b0;
        rd_en  = 1'b0;
        din    = 8'd0;
        rst    = 1'b1;

        // -------- directed --------
        reset_dut;

        // fill to full
        for (i = 0; i < DEPTH; i = i + 1)
            tick(1'b1, 1'b0, 8'hA0 + i[7:0]);
        fatal_check(full == 1'b1, "fill_full");
        fatal_check(empty == 1'b0, "fill_not_empty");

        // write-when-full: must ignore (no corruption / count stick)
        tick(1'b1, 1'b0, 8'hFF);
        fatal_check(full == 1'b1, "wr_full_ignored");
        fatal_check(count == DEPTH[CNT_W-1:0], "wr_full_count");

        // drain to empty; check FIFO order
        for (i = 0; i < DEPTH; i = i + 1)
            tick(1'b0, 1'b1, 8'h00);
        fatal_check(empty == 1'b1, "drain_empty");
        fatal_check(full  == 1'b0, "drain_not_full");

        // read-when-empty: must ignore
        tick(1'b0, 1'b1, 8'h00);
        fatal_check(empty == 1'b1, "rd_empty_ignored");
        fatal_check(count == {CNT_W{1'b0}}, "rd_empty_count");

        // simultaneous wr+rd from empty: only write accepted
        tick(1'b1, 1'b1, 8'h55);
        fatal_check(count == {{(CNT_W-1){1'b0}}, 1'b1}, "sim_empty_wr_only");
        tick(1'b0, 1'b1, 8'h00);
        fatal_check(empty == 1'b1, "sim_empty_then_rd");

        // fill then simultaneous wr+rd while full: only read accepted, then space
        for (i = 0; i < DEPTH; i = i + 1)
            tick(1'b1, 1'b0, 8'hB0 + i[7:0]);
        fatal_check(full == 1'b1, "refill_full");
        // simultaneous at full: read pops, write ignored (strict !full gate)
        tick(1'b1, 1'b1, 8'hEE);
        fatal_check(count == (DEPTH-1), "sim_full_rd_only");
        // drain rest
        while (g_n > 0)
            tick(1'b0, 1'b1, 8'h00);
        fatal_check(empty == 1'b1, "post_sim_empty");

        $display("PASS directed tb_sync_fifo");

        // -------- random traffic --------
        reset_dut;
        begin : random_block
            integer t;
            reg r_wr, r_rd;
            reg [WIDTH-1:0] r_din;
            for (t = 0; t < 2000; t = t + 1) begin
                r_wr  = ($random(seed) & 1);
                r_rd  = ($random(seed) & 1);
                r_din = $random(seed);
                // occasionally force pure write / pure read pressure
                if ((t % 17) == 0) begin r_wr = 1'b1; r_rd = 1'b0; end
                if ((t % 19) == 0) begin r_wr = 1'b0; r_rd = 1'b1; end
                tick(r_wr, r_rd, r_din);
            end
            // drain residual
            while (g_n > 0)
                tick(1'b0, 1'b1, 8'h00);
        end
        fatal_check(empty == 1'b1, "rand_final_empty");
        $display("PASS random tb_sync_fifo cycles=%0d", cycle);

        if (errors == 0)
            $display("PASS tb_sync_fifo WIDTH=%0d DEPTH=%0d cycles=%0d errors=0",
                     WIDTH, DEPTH, cycle);
        else
            $fatal(1, "tb_sync_fifo FAILED errors=%0d", errors);
        $finish;
    end

    initial begin
        #5000000;
        $fatal(1, "TIMEOUT tb_sync_fifo");
    end
endmodule
