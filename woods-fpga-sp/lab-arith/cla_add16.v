// cla_add16 — 16-bit carry-lookahead adder (Woods Ch3 §3.3 teaching DUT).
// Pure combo + registered output (LATENCY=1 when in_valid).
`timescale 1ns/1ps
module cla_add16 (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] a,
    input  wire signed [15:0] b,
    input  wire               cin,
    output reg                out_valid,
    output reg  signed [15:0] sum,
    output reg                cout
);
    // 4-bit CLA block
    function automatic [4:0] cla4; // {cout, sum[3:0]}
        input [3:0] x, y;
        input cin0;
        reg [3:0] p, g, s;
        reg c1, c2, c3, c4;
        begin
            p = x ^ y;
            g = x & y;
            c1 = g[0] | (p[0] & cin0);
            c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin0);
            c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin0);
            c4 = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0])
               | (p[3] & p[2] & p[1] & p[0] & cin0);
            s[0] = p[0] ^ cin0;
            s[1] = p[1] ^ c1;
            s[2] = p[2] ^ c2;
            s[3] = p[3] ^ c3;
            cla4 = {c4, s};
        end
    endfunction

    wire [4:0] r0 = cla4(a[3:0],   b[3:0],   cin);
    wire [4:0] r1 = cla4(a[7:4],   b[7:4],   r0[4]);
    wire [4:0] r2 = cla4(a[11:8],  b[11:8],  r1[4]);
    wire [4:0] r3 = cla4(a[15:12], b[15:12], r2[4]);
    wire [15:0] sum_c = {r3[3:0], r2[3:0], r1[3:0], r0[3:0]};
    wire        cout_c = r3[4];

    always @(posedge clk) begin
        if (rst) begin
            out_valid <= 0; sum <= 0; cout <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                sum <= sum_c;
                cout <= cout_c;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
