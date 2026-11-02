`timescale 1ns/1ps
module wrap_p3_fir_nco (
    input  wire               clk,
    input  wire               rst,
    input  wire               fir_in_valid,
    input  wire signed [15:0] fir_din,
    output wire               fir_out_valid,
    output wire signed [15:0] fir_dout,
    input  wire               nco_in_valid,
    input  wire [31:0]        freq_word,
    output wire               nco_out_valid,
    output wire signed [15:0] nco_dout
);
    fir4 u_fir (
        .clk(clk),.rst(rst),.in_valid(fir_in_valid),.din(fir_din),
        .out_valid(fir_out_valid),.dout(fir_dout));
    nco u_nco (
        .clk(clk),.rst(rst),.in_valid(nco_in_valid),.freq_word(freq_word),
        .out_valid(nco_out_valid),.dout(nco_dout));
endmodule
