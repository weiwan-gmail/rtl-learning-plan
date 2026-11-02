// biquad_df1 — Direct Form I IIR biquad (Woods Ch5 / cascade section).
// y = (b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2) >>> 15
// Coeffs Q15; states 16-bit signed. Latency 1.
`timescale 1ns/1ps
module biquad_df1 (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x_in,
    input  wire signed [15:0] b0, b1, b2, a1, a2,
    output reg                out_valid,
    output reg  signed [15:0] y_out
);
    reg signed [15:0] x1, x2, y1, y2;
    wire signed [31:0] acc =
        $signed(b0) * $signed(x_in) +
        $signed(b1) * $signed(x1)   +
        $signed(b2) * $signed(x2)   -
        $signed(a1) * $signed(y1)   -
        $signed(a2) * $signed(y2);
    wire signed [15:0] y_n = acc[30:15]; // >>>15 arithmetic via slice of signed 32

    always @(posedge clk) begin
        if (rst) begin
            x1 <= 0; x2 <= 0; y1 <= 0; y2 <= 0;
            y_out <= 0; out_valid <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                y_out <= y_n;
                out_valid <= 1'b1;
                x2 <= x1; x1 <= x_in;
                y2 <= y1; y1 <= y_n;
            end
        end
    end
endmodule
