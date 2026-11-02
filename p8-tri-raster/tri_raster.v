// tri_raster — integer edge-function fill of ONE triangle into a tiny FB.
// Teaching DUT for P8 / Track C I6. Original RTL (no external IP).
//
// Defaults: 64x48 screen, 8-bit coords, 1-bit color.
// Sample at integer pixel (x,y). Include if all three edge functions
// share the triangle orientation sign (CCW => all E>=0; CW => all E<=0).
// Degenerate (area==0): fill nothing. Only scans [0,W) x [0,H) => clip.
//
// Handshake: pulse start (while !busy); busy high until done pulses 1 cycle.
// do_clear=1 clears FB to 0 before fill. rd_addr/rd_data = async FB read.
module tri_raster #(
    parameter integer W       = 64,
    parameter integer H       = 48,
    parameter integer CORD_W  = 8,
    parameter integer COLOR_W = 1
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     start,
    input  wire                     do_clear,
    input  wire [CORD_W-1:0]        x0,
    input  wire [CORD_W-1:0]        y0,
    input  wire [CORD_W-1:0]        x1,
    input  wire [CORD_W-1:0]        y1,
    input  wire [CORD_W-1:0]        x2,
    input  wire [CORD_W-1:0]        y2,
    input  wire [COLOR_W-1:0]       color,
    output reg                      busy,
    output reg                      done,
    input  wire [11:0]              rd_addr,
    output wire [COLOR_W-1:0]       rd_data
);
    // ADDR covers W*H=3072 -> 12 bits; keep fixed for -g2005 friendliness
    localparam integer FB_SZ  = W * H;
    localparam integer ADDR_W = 12;

    localparam [1:0] ST_IDLE  = 2'd0;
    localparam [1:0] ST_CLEAR = 2'd1;
    localparam [1:0] ST_SCAN  = 2'd2;
    localparam [1:0] ST_DONE  = 2'd3;

    reg [1:0] state;
    reg [COLOR_W-1:0] fb [0:FB_SZ-1];

    reg [CORD_W-1:0] lx0, ly0, lx1, ly1, lx2, ly2;
    reg [COLOR_W-1:0] lcolor;

    reg [ADDR_W-1:0] clr_addr;
    reg [7:0]        sx, sy;

    // Zero-extend coords to signed 16-bit for edge math
    wire signed [15:0] ax0 = {8'd0, lx0};
    wire signed [15:0] ay0 = {8'd0, ly0};
    wire signed [15:0] ax1 = {8'd0, lx1};
    wire signed [15:0] ay1 = {8'd0, ly1};
    wire signed [15:0] ax2 = {8'd0, lx2};
    wire signed [15:0] ay2 = {8'd0, ly2};
    wire signed [15:0] px  = {8'd0, sx};
    wire signed [15:0] py  = {8'd0, sy};

    // E(a->b, p) = (px-ax)*(by-ay) - (py-ay)*(bx-ax)  (32-bit signed products)
    // area = E(v0->v1, v2)
    wire signed [31:0] area =
        (ax2 - ax0) * (ay1 - ay0) - (ay2 - ay0) * (ax1 - ax0);

    wire signed [31:0] e0 =
        (px - ax1) * (ay2 - ay1) - (py - ay1) * (ax2 - ax1);
    wire signed [31:0] e1 =
        (px - ax2) * (ay0 - ay2) - (py - ay2) * (ax0 - ax2);
    wire signed [31:0] e2 =
        (px - ax0) * (ay1 - ay0) - (py - ay0) * (ax1 - ax0);

    wire inside_pos = (area > 0) && (e0 >= 0) && (e1 >= 0) && (e2 >= 0);
    wire inside_neg = (area < 0) && (e0 <= 0) && (e1 <= 0) && (e2 <= 0);
    wire inside     = inside_pos | inside_neg;

    wire [ADDR_W-1:0] pix_addr = sy * W[7:0] + sx;

    assign rd_data = fb[rd_addr];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            state    <= ST_IDLE;
            busy     <= 1'b0;
            done     <= 1'b0;
            clr_addr <= {ADDR_W{1'b0}};
            sx       <= 8'd0;
            sy       <= 8'd0;
            lx0 <= 0; ly0 <= 0; lx1 <= 0; ly1 <= 0; lx2 <= 0; ly2 <= 0;
            lcolor <= {COLOR_W{1'b0}};
            for (i = 0; i < FB_SZ; i = i + 1)
                fb[i] <= {COLOR_W{1'b0}};
        end else begin
            done <= 1'b0;
            case (state)
                ST_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        lx0 <= x0; ly0 <= y0;
                        lx1 <= x1; ly1 <= y1;
                        lx2 <= x2; ly2 <= y2;
                        lcolor   <= color;
                        busy     <= 1'b1;
                        sx       <= 8'd0;
                        sy       <= 8'd0;
                        clr_addr <= {ADDR_W{1'b0}};
                        if (do_clear)
                            state <= ST_CLEAR;
                        else
                            state <= ST_SCAN;
                    end
                end
                ST_CLEAR: begin
                    fb[clr_addr] <= {COLOR_W{1'b0}};
                    if (clr_addr == FB_SZ - 1) begin
                        clr_addr <= {ADDR_W{1'b0}};
                        sx       <= 8'd0;
                        sy       <= 8'd0;
                        state    <= ST_SCAN;
                    end else begin
                        clr_addr <= clr_addr + 1'b1;
                    end
                end
                ST_SCAN: begin
                    if (inside)
                        fb[pix_addr] <= lcolor;
                    if (sx == W - 1) begin
                        sx <= 8'd0;
                        if (sy == H - 1)
                            state <= ST_DONE;
                        else
                            sy <= sy + 8'd1;
                    end else begin
                        sx <= sx + 8'd1;
                    end
                end
                ST_DONE: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= ST_IDLE;
                end
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule
