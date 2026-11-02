// fir_transpose — same 4-tap linear-phase FIR in transposed form.
// Broadcast x to 4 muls; delay between adders. Bit-exact vs fir_direct.
`timescale 1ns/1ps
module fir_transpose (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [31:0] dout
);
    localparam signed [15:0] H0 = 16'sd1, H1 = 16'sd2, H2 = 16'sd2, H3 = 16'sd1;
    reg signed [31:0] r1, r2, r3;
    wire signed [31:0] p0 = $signed(H0)*$signed(din);
    wire signed [31:0] p1 = $signed(H1)*$signed(din);
    wire signed [31:0] p2 = $signed(H2)*$signed(din);
    wire signed [31:0] p3 = $signed(H3)*$signed(din);
    wire signed [31:0] y_c = p0 + r1;

    always @(posedge clk) begin
        if (rst) begin
            r1 <= 0; r2 <= 0; r3 <= 0; dout <= 0; out_valid <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= y_c;
                out_valid <= 1'b1;
                r1 <= p1 + r2;
                r2 <= p2 + r3;
                r3 <= p3;
            end
        end
    end
endmodule
