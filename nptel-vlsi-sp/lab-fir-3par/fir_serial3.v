// fir_serial3 — 3-tap FIR H=[1,2,1], one sample / cycle.
`timescale 1ns/1ps
module fir_serial3 (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [31:0] dout
);
    localparam signed [15:0] H0=16'sd1, H1=16'sd2, H2=16'sd1;
    reg signed [15:0] x1, x2;
    always @(posedge clk) begin
        if (rst) begin
            x1<=0; x2<=0; dout<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= $signed(H0)*din + $signed(H1)*x1 + $signed(H2)*x2;
                out_valid <= 1'b1;
                x2<=x1; x1<=din;
            end
        end
    end
endmodule
