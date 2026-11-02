// fir3_pipe — same SFG after cut-set retiming / pipelining (Ch8).
// Pipeline: mul regs then add tree. Latency=3 (vs 1 for combo). Same bit-exact y.
`timescale 1ns/1ps
module fir3_pipe #(
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
    // stage1: products
    reg signed [31:0] p0, p1, p2;
    reg               v1;
    // stage2: first add
    reg signed [31:0] s01;
    reg signed [31:0] p2d;
    reg               v2;
    // stage3: final add → dout

    always @(posedge clk) begin
        if (rst) begin
            x1<=0;x2<=0; p0<=0;p1<=0;p2<=0; v1<=0;
            s01<=0;p2d<=0;v2<=0; dout<=0; out_valid<=0;
        end else begin
            // delay line + stage1
            v1 <= in_valid;
            if (in_valid) begin
                p0 <= $signed(H0)*$signed(din);
                p1 <= $signed(H1)*$signed(x1);
                p2 <= $signed(H2)*$signed(x2);
                x2 <= x1; x1 <= din;
            end
            // stage2
            v2 <= v1;
            s01 <= p0 + p1;
            p2d <= p2;
            // stage3
            out_valid <= v2;
            if (v2) dout <= s01 + p2d;
        end
    end
endmodule
