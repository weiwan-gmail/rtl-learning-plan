// vga_tri — wire P8 tri_raster FB into P4 VGA timing (sim-only teaching top).
// Strategy: classic 640x480@60 timing; nearest-neighbor scale FB 64x48 -> active
// (SCALE=10). During de, RGB comes from FB[y/10][x/10]; blanking forces black.
// Raster fill is independent (start/done); scanout reads async rd_data.
module vga_tri #(
    parameter integer H_RES   = 640,
    parameter integer H_FP    = 16,
    parameter integer H_SYNC  = 96,
    parameter integer H_BP    = 48,
    parameter integer V_RES   = 480,
    parameter integer V_FP    = 10,
    parameter integer V_SYNC  = 2,
    parameter integer V_BP    = 33,
    parameter integer FB_W    = 64,
    parameter integer FB_H    = 48,
    parameter integer CORD_W  = 8,
    parameter integer COLOR_W = 1
) (
    input  wire                     clk,
    input  wire                     rst,
    // triangle fill control (same handshake as P8)
    input  wire                     start,
    input  wire                     do_clear,
    input  wire [CORD_W-1:0]        x0,
    input  wire [CORD_W-1:0]        y0,
    input  wire [CORD_W-1:0]        x1,
    input  wire [CORD_W-1:0]        y1,
    input  wire [CORD_W-1:0]        x2,
    input  wire [CORD_W-1:0]        y2,
    input  wire [COLOR_W-1:0]       color,
    output wire                     busy,
    output wire                     done,
    // VGA outs
    output wire                     hsync,
    output wire                     vsync,
    output wire                     de,
    output wire [9:0]               x,
    output wire [9:0]               y,
    output wire [7:0]               r,
    output wire [7:0]               g,
    output wire [7:0]               b
);
    localparam integer SCALE_X = H_RES / FB_W; // 10
    localparam integer SCALE_Y = V_RES / FB_H; // 10

    wire [11:0]            rd_addr;
    wire [COLOR_W-1:0]     rd_data;
    wire [7:0]             fb_x;
    wire [7:0]             fb_y;
    wire                   pix_on;

    vga_timing #(
        .H_RES(H_RES), .H_FP(H_FP), .H_SYNC(H_SYNC), .H_BP(H_BP),
        .V_RES(V_RES), .V_FP(V_FP), .V_SYNC(V_SYNC), .V_BP(V_BP)
    ) u_timing (
        .clk(clk), .rst(rst),
        .hsync(hsync), .vsync(vsync), .de(de),
        .x(x), .y(y)
    );

    tri_raster #(
        .W(FB_W), .H(FB_H), .CORD_W(CORD_W), .COLOR_W(COLOR_W)
    ) u_tri (
        .clk(clk), .rst(rst),
        .start(start), .do_clear(do_clear),
        .x0(x0), .y0(y0), .x1(x1), .y1(y1), .x2(x2), .y2(y2),
        .color(color),
        .busy(busy), .done(done),
        .rd_addr(rd_addr), .rd_data(rd_data)
    );

    // Nearest-neighbor: map VGA coord -> FB coord (combinational)
    assign fb_x = x / SCALE_X[7:0];
    assign fb_y = y / SCALE_Y[7:0];
    assign rd_addr = fb_y * FB_W[7:0] + fb_x;
    assign pix_on  = de & (rd_data != {COLOR_W{1'b0}});

    assign r = pix_on ? 8'hFF : 8'h00;
    assign g = pix_on ? 8'hFF : 8'h00;
    assign b = pix_on ? 8'hFF : 8'h00;
endmodule
