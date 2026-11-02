`timescale 1ns/1ps
module wrap_fir_2par (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_s,
    input  wire               in_p,
    input  wire signed [15:0] din,
    input  wire signed [15:0] xe,
    input  wire signed [15:0] xo,
    output wire               ov_s,
    output wire               ov_p,
    output wire signed [31:0] ys, ye, yo
);
    fir_serial u_s (.clk(clk),.rst(rst),.in_valid(in_s),.din(din),.out_valid(ov_s),.dout(ys));
    fir_2par   u_p (.clk(clk),.rst(rst),.in_valid(in_p),.xe(xe),.xo(xo),.out_valid(ov_p),.ye(ye),.yo(yo));
endmodule
