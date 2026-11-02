`timescale 1ns/1ps
// Glue only — DUT RTL remains in nptel-vlsi-sp/lab-fir-transpose/.
module wrap_fir_transpose (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output wire               ov_d,
    output wire               ov_t,
    output wire signed [31:0] y_d,
    output wire signed [31:0] y_t
);
    fir_direct    u_d (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_d),.dout(y_d));
    fir_transpose u_t (.clk(clk),.rst(rst),.in_valid(in_valid),.din(din),.out_valid(ov_t),.dout(y_t));
endmodule
