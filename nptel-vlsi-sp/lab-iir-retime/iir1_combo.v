// iir1_combo — 1st-order IIR, long combinational MAC (before retiming).
//   y[n] = sat( (B0*x[n] + B1*x[n-1] + A1*y[n-1]) >>> SHIFT )
// Default B0=B1=A1=1, SHIFT=1 → leaky averager. LATENCY=1.
`timescale 1ns/1ps
module iir1_combo #(
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
            x1 <= 0; y1 <= 0; dout <= 0; out_valid <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                begin : c
                    reg signed [31:0] acc, sh;
                    acc = din*B0 + x1*B1 + y1*A1;
                    sh  = acc >>> SHIFT;
                    dout <= sat16(sh);
                    y1   <= sat16(sh);
                    x1   <= din;
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
