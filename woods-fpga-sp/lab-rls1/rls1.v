// rls1 — 1-tap RLS teaching DUT (Woods Ch2 §2.5).
// λ=1. P in Q(PSCALE), w in Q(WSCALE); real_w = w/WSCALE, real_P = p/PSCALE.
//   den  = PSCALE + x*x*p
//   k_q  = (p * x * PSCALE) / den
//   y    = (w * x) / WSCALE
//   e    = d - y
//   w   += (k_q * e * WSCALE) / PSCALE
//   p    = (p * PSCALE) / den
// Latency=1. HDL / = trunc toward 0 (see div_tz).
`timescale 1ns/1ps
module rls1 #(
    parameter integer PSCALE = 256,
    parameter integer WSCALE = 256,
    parameter integer PINIT  = 256*16
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] xin,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] yout,
    output reg  signed [15:0] eout,
    output reg  signed [15:0] w_out,   // real_w ≈ w_out (integer rounded)
    output reg  signed [31:0] w_q_out, // Q(WSCALE)
    output reg  signed [31:0] p_out
);
    reg signed [31:0] w_q;
    reg signed [31:0] p;

    function automatic signed [15:0] sat16;
        input signed [31:0] v;
        begin
            if (v > 32'sd32767) sat16 = 16'sd32767;
            else if (v < -32'sd32768) sat16 = -16'sd32768;
            else sat16 = v[15:0];
        end
    endfunction

    function automatic signed [31:0] div_tz;
        input signed [31:0] num, den;
        reg signed [31:0] a, b, q;
        begin
            if (den == 0) div_tz = 0;
            else begin
                a = (num < 0) ? -num : num;
                b = (den < 0) ? -den : den;
                q = a / b;
                div_tz = ((num < 0) ^ (den < 0)) ? -q : q;
            end
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            w_q <= 0; p <= PINIT;
            out_valid <= 0; yout <= 0; eout <= 0;
            w_out <= 0; w_q_out <= 0; p_out <= PINIT;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                begin : step
                    reg signed [31:0] den, k_q, y, e, wn, pn;
                    den = PSCALE + (xin * xin * p);
                    k_q = div_tz(p * xin * PSCALE, den);
                    y   = div_tz(w_q * xin, WSCALE);
                    e   = {{16{din[15]}}, din} - y;
                    wn  = w_q + div_tz(k_q * e * WSCALE, PSCALE);
                    pn  = div_tz(p * PSCALE, den);
                    if (pn < 1) pn = 1;
                    w_q <= wn;
                    p <= pn;
                    yout <= sat16(y);
                    eout <= sat16(e);
                    w_q_out <= wn;
                    p_out <= pn;
                    // report nearest int weight
                    w_out <= sat16(div_tz(wn, WSCALE));
                    // actually trunc toward nearest via +WSCALE/2 only for >=0
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
