// Formal wrapper for P2 sync_fifo (SymbiYosys / Yosys -formal).
// Reuses ../p2-sync-fifo/sync_fifo.v unchanged.
// Small WIDTH/DEPTH keep BMC cheap on Z3.
`default_nettype none

module fifo_props (
    input  wire       clk,
    input  wire       rst,
    input  wire       wr_en,
    input  wire       rd_en,
    input  wire [1:0] din
);
    localparam WIDTH = 2;
    localparam DEPTH = 4;
    localparam CNT_W = $clog2(DEPTH) + 1;

    wire [WIDTH-1:0] dout;
    wire             full;
    wire             empty;
    wire [CNT_W-1:0] count;

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
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

`ifdef FORMAL
    reg f_past_valid;
    initial f_past_valid = 1'b0;
    always @(posedge clk)
        f_past_valid <= 1'b1;

    // Cycle 0 is reset.
    always @(*) begin
        if (!f_past_valid)
            assume (rst);
    end

    // Environment contract → no overflow / underflow of occupancy.
    always @(*) begin
        if (f_past_valid && !rst) begin
            assume (!(wr_en && full));
            assume (!(rd_en && empty));
        end
    end

    // P1: empty/full mutual exclusion + count ↔ flags
    always @(*) begin
        if (f_past_valid && !rst) begin
            assert (!(full && empty));
            assert (count <= DEPTH[CNT_W-1:0]);
            assert (empty == (count == {CNT_W{1'b0}}));
            assert (full  == (count == DEPTH[CNT_W-1:0]));
        end
    end

    // P2: under assume, count evolves exactly with wr/rd (no wrap)
    always @(posedge clk) begin
        if (f_past_valid && !$past(rst) && !rst) begin
            assert (count <= DEPTH[CNT_W-1:0]);

            if ($past(wr_en) && !$past(rd_en))
                assert (count == $past(count) + {{CNT_W-1{1'b0}}, 1'b1});
            if ($past(rd_en) && !$past(wr_en))
                assert (count == $past(count) - {{CNT_W-1{1'b0}}, 1'b1});
            if ($past(wr_en) && $past(rd_en))
                assert (count == $past(count));
            if (!$past(wr_en) && !$past(rd_en))
                assert (count == $past(count));
        end
    end

    // Cover: fill; return to empty after full
    always @(posedge clk) begin
        if (f_past_valid && !rst) begin
            cover (full);
            cover (empty && $past(full));
        end
    end
`endif
endmodule

`default_nettype wire
