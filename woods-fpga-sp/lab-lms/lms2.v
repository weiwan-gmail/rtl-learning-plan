// lms2 — 2-tap LMS adaptive filter (Woods Ch2 §2.5.3 teaching DUT).
//   y  = (w0*x0 + w1*x1) >>> WSHIFT
//   e  = d - y
//   wi += (e * xi) >>> MUSHIFT     (mu folded into shift; default mu≈1/32)
// Latency=1.
`timescale 1ns/1ps
module lms2 #(
    parameter integer WSHIFT  = 0,
    parameter integer MUSHIFT = 5
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] xin,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] yout,
    output reg  signed [15:0] eout,
    output reg  signed [15:0] w0_out,
    output reg  signed [15:0] w1_out
);
    reg signed [15:0] x0, x1;
    reg signed [15:0] w0, w1;

    function automatic signed [15:0] sat16;
        input signed [31:0] v;
        begin
            if (v > 32'sd32767) sat16 = 16'sd32767;
            else if (v < -32'sd32768) sat16 = -16'sd32768;
            else sat16 = v[15:0];
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            x0 <= 0; x1 <= 0; w0 <= 0; w1 <= 0;
            out_valid <= 0; yout <= 0; eout <= 0;
            w0_out <= 0; w1_out <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                begin : step
                    reg signed [15:0] nx0, nx1;
                    reg signed [31:0] acc, y, e, dw0, dw1;
                    reg signed [15:0] yw, ew, nw0, nw1;
                    nx0 = xin;
                    nx1 = x0;
                    acc = (nx0 * w0) + (nx1 * w1);
                    y   = acc >>> WSHIFT;
                    yw  = sat16(y);
                    e   = {{16{din[15]}}, din} - {{16{yw[15]}}, yw};
                    ew  = sat16(e);
                    dw0 = (ew * nx0) >>> MUSHIFT;
                    dw1 = (ew * nx1) >>> MUSHIFT;
                    nw0 = sat16({{16{w0[15]}}, w0} + dw0);
                    nw1 = sat16({{16{w1[15]}}, w1} + dw1);
                    x0 <= nx0;
                    x1 <= nx1;
                    w0 <= nw0;
                    w1 <= nw1;
                    yout <= yw;
                    eout <= ew;
                    w0_out <= nw0;
                    w1_out <= nw1;
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
