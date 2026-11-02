`timescale 1ns/1ps
module wrap_cordic (
    input  wire               clk,
    input  wire               rst,
    input  wire               start,
    input  wire signed [15:0] x_in, y_in, z_in,
    output wire               done_r, done_v,
    output wire signed [15:0] xr, yr, zr, xv, yv, zv
);
    cordic_rotate u_r (
        .clk(clk),.rst(rst),.start(start),
        .x_in(x_in),.y_in(y_in),.z_in(z_in),
        .done(done_r),.x_out(xr),.y_out(yr),.z_out(zr));
    cordic_vector u_v (
        .clk(clk),.rst(rst),.start(start),
        .x_in(x_in),.y_in(y_in),.z_in(z_in),
        .done(done_v),.x_out(xv),.y_out(yv),.z_out(zv));
endmodule
