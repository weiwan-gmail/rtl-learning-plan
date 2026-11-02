`timescale 1ns/1ps
module wrap_lookahead (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_v,
    input  wire               in_p,
    input  wire signed [15:0] din,
    input  wire signed [15:0] dinp,
    output wire               ov, ovl, ovp,
    output wire signed [15:0] yp, yl, ypp
);
    iir_plain     u_p (.clk(clk),.rst(rst),.in_valid(in_v),.din(din),.out_valid(ov),.dout(yp));
    iir_lookahead u_l (.clk(clk),.rst(rst),.in_valid(in_v),.din(din),.out_valid(ovl),.dout(yl));
    iir_la_pipe   u_q (.clk(clk),.rst(rst),.in_valid(in_p),.din(dinp),.out_valid(ovp),.dout(ypp));
endmodule
