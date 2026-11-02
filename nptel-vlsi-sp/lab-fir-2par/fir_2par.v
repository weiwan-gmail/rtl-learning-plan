// fir_2par — 2-parallel / polyphase FIR, H=[1,2,2,1] (L29–L30).
// Each cycle: even/odd inputs xe=x(2k), xo=x(2k+1) → ye=y(2k), yo=y(2k+1).
`timescale 1ns/1ps
module fir_2par (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] xe,
    input  wire signed [15:0] xo,
    output reg                out_valid,
    output reg  signed [31:0] ye,
    output reg  signed [31:0] yo
);
    localparam signed [15:0] H0=16'sd1, H1=16'sd2, H2=16'sd2, H3=16'sd1;
    // delays: xe_d = xe[k-1], xo_d = xo[k-1], xo_d2 = xo[k-2]
    reg signed [15:0] xe_d, xo_d, xo_d2;
    always @(posedge clk) begin
        if (rst) begin
            xe_d<=0; xo_d<=0; xo_d2<=0; ye<=0; yo<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                // y(2k)   = h0 xe(k) + h1 xo(k-1) + h2 xe(k-1) + h3 xo(k-2)
                // y(2k+1) = h0 xo(k) + h1 xe(k)   + h2 xo(k-1) + h3 xe(k-1)
                ye <= $signed(H0)*xe + $signed(H1)*xo_d + $signed(H2)*xe_d + $signed(H3)*xo_d2;
                yo <= $signed(H0)*xo + $signed(H1)*xe   + $signed(H2)*xo_d + $signed(H3)*xe_d;
                out_valid <= 1'b1;
                xo_d2 <= xo_d;
                xo_d  <= xo;
                xe_d  <= xe;
            end
        end
    end
endmodule
