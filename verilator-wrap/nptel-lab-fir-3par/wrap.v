`timescale 1ns/1ps
module wrap_fir_3par (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_p,
    input  wire signed [15:0] x0, x1, x2,
    output wire               ov_p,
    output wire signed [31:0] y0, y1, y2
);
    fir_3par u_p (.clk(clk),.rst(rst),.in_valid(in_p),.x0(x0),.x1(x1),.x2(x2),
                  .out_valid(ov_p),.y0(y0),.y1(y1),.y2(y2));
endmodule
