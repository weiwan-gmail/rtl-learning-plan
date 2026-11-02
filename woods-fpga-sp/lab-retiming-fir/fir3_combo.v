// fir3_combo — 3-tap FIR, no pipeline inside MAC (Woods Ch8 "before retiming").
// y = h0*x + h1*x1 + h2*x2, then register output. Comb path = 3 mul + 2 add.
`timescale 1ns/1ps
module fir3_combo #(
    parameter signed [15:0] H0 = 16'sd1,
    parameter signed [15:0] H1 = 16'sd2,
    parameter signed [15:0] H2 = 16'sd1
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [31:0] dout
);
    reg signed [15:0] x1, x2;
    wire signed [31:0] y_c =
        $signed(H0)*$signed(din) + $signed(H1)*$signed(x1) + $signed(H2)*$signed(x2);
    always @(posedge clk) begin
        if (rst) begin x1<=0; x2<=0; dout<=0; out_valid<=0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= y_c; out_valid <= 1'b1;
                x2 <= x1; x1 <= din;
            end
        end
    end
endmodule
