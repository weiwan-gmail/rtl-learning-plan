`timescale 1ns/1ps
module wrap_dlms (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] xin,
    input  wire signed [15:0] din,
    output wire               ov_l, ov_d,
    output wire signed [15:0] y_l, e_l, w0_l, w1_l,
    output wire signed [15:0] y_d, e_d, w0_d, w1_d
);
    lms2  #(.MUSHIFT(6)) u_l (
        .clk(clk),.rst(rst),.in_valid(in_valid),.xin(xin),.din(din),
        .out_valid(ov_l),.yout(y_l),.eout(e_l),.w0_out(w0_l),.w1_out(w1_l));
    dlms2 #(.MUSHIFT(6),.D(1)) u_d (
        .clk(clk),.rst(rst),.in_valid(in_valid),.xin(xin),.din(din),
        .out_valid(ov_d),.yout(y_d),.eout(e_d),.w0_out(w0_d),.w1_out(w1_d));
endmodule
