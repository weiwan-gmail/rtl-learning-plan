`timescale 1ns/1ps
module wrap_biquad_fold (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_p,
    input  wire               in_f,
    input  wire signed [15:0] xp,
    input  wire signed [15:0] xf,
    input  wire signed [15:0] b0, b1, b2, a1, a2,
    output wire               ov_p,
    output wire               ov_f,
    output wire               busy,
    output wire signed [15:0] yp, yf
);
    biquad_par  u_p (.clk(clk),.rst(rst),.in_valid(in_p),.x_in(xp),
                     .b0(b0),.b1(b1),.b2(b2),.a1(a1),.a2(a2),
                     .out_valid(ov_p),.y_out(yp));
    biquad_fold u_f (.clk(clk),.rst(rst),.in_valid(in_f),.x_in(xf),
                     .b0(b0),.b1(b1),.b2(b2),.a1(a1),.a2(a2),
                     .out_valid(ov_f),.y_out(yf),.busy(busy));
endmodule
