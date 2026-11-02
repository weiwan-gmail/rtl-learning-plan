// iir1_pipe — same IIR after cut-set retiming / feed-forward pipelining (L8–L9).
// Stage1: products. Stage2: add + shift + sat. LATENCY=2. Bit-exact vs combo.
`timescale 1ns/1ps
module iir1_pipe #(
    parameter signed [15:0] B0 = 16'sd1,
    parameter signed [15:0] B1 = 16'sd1,
    parameter signed [15:0] A1 = 16'sd1,
    parameter integer       SHIFT = 1
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    reg signed [15:0] x1, y1;
    reg signed [31:0] p0, p1, pa;
    reg               v1;
    function automatic signed [15:0] sat16;
        input signed [31:0] v;
        begin
            if (v > 32'sd32767) sat16 = 16'sd32767;
            else if (v < -32'sd32768) sat16 = -32'sd32768;
            else sat16 = v[15:0];
        end
    endfunction
    always @(posedge clk) begin
        if (rst) begin
            x1 <= 0; y1 <= 0; p0 <= 0; p1 <= 0; pa <= 0; v1 <= 0;
            dout <= 0; out_valid <= 0;
        end else begin
            out_valid <= 1'b0;
            v1 <= in_valid;
            if (in_valid) begin
                p0 <= din * B0;
                p1 <= x1  * B1;
                pa <= y1  * A1;
                x1 <= din;
            end
            if (v1) begin
                begin : s2
                    reg signed [31:0] acc, sh;
                    reg signed [15:0] yn;
                    acc = p0 + p1 + pa;
                    sh  = acc >>> SHIFT;
                    yn  = sat16(sh);
                    dout <= yn;
                    y1   <= yn;
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
