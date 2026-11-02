`timescale 1ns/1ps
module wrap_arith (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] a, b,
    input  wire               cin,
    input  wire [7:0]         ma, mb,
    output wire               out_valid, cout, mout_valid,
    output wire signed [15:0] sum,
    output wire [15:0]        product
);
    cla_add16 u_add (
        .clk(clk),.rst(rst),.in_valid(in_valid),
        .a(a),.b(b),.cin(cin),.out_valid(out_valid),.sum(sum),.cout(cout));
    array_mult8 u_mul (
        .clk(clk),.rst(rst),.in_valid(in_valid),
        .a(ma),.b(mb),.out_valid(mout_valid),.product(product));
endmodule
