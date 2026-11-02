// fir_3par — 3-parallel FIR H=[1,2,1] (L31).
// Inputs x0=x(3k), x1=x(3k+1), x2=x(3k+2) → y0,y1,y2 in one cycle.
`timescale 1ns/1ps
module fir_3par (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x0, x1, x2,
    output reg                out_valid,
    output reg  signed [31:0] y0, y1, y2
);
    localparam signed [15:0] H0=16'sd1, H1=16'sd2, H2=16'sd1;
    reg signed [15:0] x1d, x2d; // x1[k-1], x2[k-1]
    always @(posedge clk) begin
        if (rst) begin
            x1d<=0; x2d<=0; y0<=0; y1<=0; y2<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                // y(3k)   = h0 x0[k] + h1 x2[k-1] + h2 x1[k-1]
                // y(3k+1) = h0 x1[k] + h1 x0[k]   + h2 x2[k-1]
                // y(3k+2) = h0 x2[k] + h1 x1[k]   + h2 x0[k]
                y0 <= $signed(H0)*x0 + $signed(H1)*x2d + $signed(H2)*x1d;
                y1 <= $signed(H0)*x1 + $signed(H1)*x0  + $signed(H2)*x2d;
                y2 <= $signed(H0)*x2 + $signed(H1)*x1  + $signed(H2)*x0;
                out_valid <= 1'b1;
                x1d <= x1;
                x2d <= x2;
            end
        end
    end
endmodule
