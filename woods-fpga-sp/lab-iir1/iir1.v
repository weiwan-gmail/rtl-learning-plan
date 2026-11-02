// iir1 — first-order Direct-Form I teaching IIR (Woods Ch2 §2.4.2).
//   y[n] = ((B0 * x[n] + B1 * x[n-1] + A1 * y[n-1]) >>> SHIFT)
// Default: B0=1, B1=1, A1=1, SHIFT=1  →  y = (x + x_d1 + y_d1) >> 1
//          (simple lowpass / leaky averager; poles/zeros integer-friendly)
// Latency=1: in_valid/din @ edge N → out_valid/dout @ edge N+1
`timescale 1ns/1ps
module iir1 #(
    parameter signed [15:0] B0    = 16'sd1,
    parameter signed [15:0] B1    = 16'sd1,
    parameter signed [15:0] A1    = 16'sd1,
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
            if (v > 32'sd32767)       sat16 = 16'sd32767;
            else if (v < -32'sd32768) sat16 = -16'sd32768;
            else                      sat16 = v[15:0];
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            x1        <= 16'sd0;
            y1        <= 16'sd0;
            out_valid <= 1'b0;
            dout      <= 16'sd0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                // acc in 32-bit then arithmetic shift + sat
                // y = sat( (B0*din + B1*x1 + A1*y1) >>> SHIFT )
                begin : compute
                    reg signed [31:0] p0, p1, pa, acc, sh;
                    p0  = din * B0;
                    p1  = x1  * B1;
                    pa  = y1  * A1;
                    acc = p0 + p1 + pa;
                    sh  = acc >>> SHIFT;
                    dout <= sat16(sh);
                    x1   <= din;
                    y1   <= sat16(sh);
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
