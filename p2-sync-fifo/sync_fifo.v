// sync_fifo: synchronous circular FIFO (parameterized WIDTH/DEPTH).
// Write ignored when full; read ignored when empty — no OV/UN corruption.
// Registered dout: valid one cycle after an accepted rd_en.
module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8   // >= 1
) (
    input  wire                     clk,
    input  wire                     rst,    // sync active-high
    input  wire                     wr_en,
    input  wire                     rd_en,
    input  wire [WIDTH-1:0]         din,
    output reg  [WIDTH-1:0]         dout,
    output wire                     full,
    output wire                     empty,
    output wire [$clog2(DEPTH):0]   count
);
    localparam ADDR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam CNT_W  = $clog2(DEPTH) + 1;
    localparam [ADDR_W-1:0] LAST = DEPTH - 1;

    reg [WIDTH-1:0]   mem [0:DEPTH-1];
    reg [ADDR_W-1:0]  wr_ptr;
    reg [ADDR_W-1:0]  rd_ptr;
    reg [CNT_W-1:0]   cnt;

    assign count = cnt;
    assign full  = (cnt == DEPTH[CNT_W-1:0]);
    assign empty = (cnt == {CNT_W{1'b0}});

    wire do_wr = wr_en & ~full;
    wire do_rd = rd_en & ~empty;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= {ADDR_W{1'b0}};
            rd_ptr <= {ADDR_W{1'b0}};
            cnt    <= {CNT_W{1'b0}};
            dout   <= {WIDTH{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {WIDTH{1'b0}};
        end else begin
            if (do_wr) begin
                mem[wr_ptr] <= din;
                wr_ptr <= (wr_ptr == LAST) ? {ADDR_W{1'b0}} : wr_ptr + 1'b1;
            end
            if (do_rd) begin
                dout   <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == LAST) ? {ADDR_W{1'b0}} : rd_ptr + 1'b1;
            end
            case ({do_wr, do_rd})
                2'b10:   cnt <= cnt + 1'b1;
                2'b01:   cnt <= cnt - 1'b1;
                default: cnt <= cnt;
            endcase
        end
    end
endmodule
