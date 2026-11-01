// fir4 — 4-tap streamed FIR (original minimal RTL).
//
// Ports: clk, rst (sync high), in_valid, din[15:0] (signed),
//        out_valid, dout[15:0] (signed, saturated).
// Coeffs: parameters H0..H3 (signed 16-bit integers). Default [1,2,2,1]
//         = simple lowpass-ish integer taps (not Q15; Q0 integers).
// Acc:    signed 34-bit sum of 16x16 products, then >>> SHIFT, then
//         saturate to signed 16-bit for dout.
//
// Pipeline LATENCY = 1:
//   in_valid/din sampled on rising edge N
//   → out_valid/dout valid on rising edge N+1
//   (delay-line update + MAC registered in one stage)
//
// When in_valid=0: delay line holds; out_valid=0; dout holds last value.
module fir4 #(
    parameter signed [15:0] H0    = 16'sd1,
    parameter signed [15:0] H1    = 16'sd2,
    parameter signed [15:0] H2    = 16'sd2,
    parameter signed [15:0] H3    = 16'sd1,
    parameter integer       SHIFT = 0
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    // x0 = newest sample, x3 = oldest
    reg signed [15:0] x0, x1, x2, x3;

    function automatic signed [15:0] mac_sat;
        input signed [15:0] a0, a1, a2, a3;
        reg   signed [31:0] p0, p1, p2, p3;
        reg   signed [33:0] acc, sh;
        begin
            p0  = a0 * H0;
            p1  = a1 * H1;
            p2  = a2 * H2;
            p3  = a3 * H3;
            acc = {{2{p0[31]}}, p0} + {{2{p1[31]}}, p1}
                + {{2{p2[31]}}, p2} + {{2{p3[31]}}, p3};
            sh  = acc >>> SHIFT;
            if (sh > 34'sd32767)
                mac_sat = 16'sd32767;
            else if (sh < -34'sd32768)
                mac_sat = -16'sd32768;
            else
                mac_sat = sh[15:0];
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            x0        <= 16'sd0;
            x1        <= 16'sd0;
            x2        <= 16'sd0;
            x3        <= 16'sd0;
            out_valid <= 1'b0;
            dout      <= 16'sd0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                // NBA: RHS x0..x2 are pre-update → MAC sees new taps
                // {din, x0, x1, x2} == post-update {x0,x1,x2,x3}
                x0   <= din;
                x1   <= x0;
                x2   <= x1;
                x3   <= x2;
                dout <= mac_sat(din, x0, x1, x2);
            end
        end
    end
endmodule
