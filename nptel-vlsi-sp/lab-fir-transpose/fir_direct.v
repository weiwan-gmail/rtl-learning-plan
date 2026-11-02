// fir_direct — 4-tap linear-phase FIR, direct form. y = 1*x + 2*x1 + 2*x2 + 1*x3
// Q0 signed 16-bit taps; 32-bit accumulator. LATENCY=1.
`timescale 1ns/1ps
module fir_direct (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [31:0] dout
);
    localparam signed [15:0] H0 = 16'sd1, H1 = 16'sd2, H2 = 16'sd2, H3 = 16'sd1;
    reg signed [15:0] x1, x2, x3;
    wire signed [31:0] y_c =
        $signed(H0)*$signed(din) + $signed(H1)*$signed(x1) +
        $signed(H2)*$signed(x2)  + $signed(H3)*$signed(x3);

    always @(posedge clk) begin
        if (rst) begin
            x1 <= 0; x2 <= 0; x3 <= 0; dout <= 0; out_valid <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= y_c;
                out_valid <= 1'b1;
                x3 <= x2; x2 <= x1; x1 <= din;
            end
        end
    end
endmodule
