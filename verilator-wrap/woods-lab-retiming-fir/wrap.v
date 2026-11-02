`timescale 1ns/1ps
module wrap_retiming_fir (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output wire               ov_c, ov_p,
    output wire signed [31:0] y_c, y_p
);
    fir3_combo u_c (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_c),.dout(y_c));
    fir3_pipe  u_p (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_p),.dout(y_p));
endmodule
