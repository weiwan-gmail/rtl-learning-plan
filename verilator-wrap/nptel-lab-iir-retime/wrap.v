`timescale 1ns/1ps
module wrap_iir_retime (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output wire               ov_c,
    output wire               ov_p,
    output wire signed [15:0] y_c,
    output wire signed [15:0] y_p
);
    iir1_combo u_c (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_c),.dout(y_c));
    iir1_pipe  u_p (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_p),.dout(y_p));
endmodule
