// array_mult8 — 8x8 → 16 unsigned array-style multiplier (Ch3 §3.3.4 teaching).
// Combinational partial products + shift-add tree; registered out (LATENCY=1).
`timescale 1ns/1ps
module array_mult8 (
    input  wire        clk,
    input  wire        rst,
    input  wire        in_valid,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg         out_valid,
    output reg  [15:0] product
);
    wire [15:0] pp0 = b[0] ? {8'b0, a}       : 16'b0;
    wire [15:0] pp1 = b[1] ? {7'b0, a, 1'b0} : 16'b0;
    wire [15:0] pp2 = b[2] ? {6'b0, a, 2'b0} : 16'b0;
    wire [15:0] pp3 = b[3] ? {5'b0, a, 3'b0} : 16'b0;
    wire [15:0] pp4 = b[4] ? {4'b0, a, 4'b0} : 16'b0;
    wire [15:0] pp5 = b[5] ? {3'b0, a, 5'b0} : 16'b0;
    wire [15:0] pp6 = b[6] ? {2'b0, a, 6'b0} : 16'b0;
    wire [15:0] pp7 = b[7] ? {1'b0, a, 7'b0} : 16'b0;
    wire [15:0] prod_c = pp0+pp1+pp2+pp3+pp4+pp5+pp6+pp7;

    always @(posedge clk) begin
        if (rst) begin out_valid <= 0; product <= 0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin product <= prod_c; out_valid <= 1'b1; end
        end
    end
endmodule
