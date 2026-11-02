// baugh_wooley8 — 8×8 signed Baugh–Wooley array (L38, A7 Q6).
`timescale 1ns/1ps
module baugh_wooley8 (
    input  wire        clk,
    input  wire        rst,
    input  wire        in_valid,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg         out_valid,
    output reg  [15:0] product
);
    wire [7:0] row [0:7];
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : ROWS
            for (j = 0; j < 8; j = j + 1) begin : COLS
                if (i == 7 && j == 7)
                    assign row[i][j] = a[i] & b[j];
                else if (i == 7 || j == 7)
                    assign row[i][j] = ~(a[i] & b[j]);
                else
                    assign row[i][j] = a[i] & b[j];
            end
        end
    endgenerate

    wire [15:0] s =
        {8'b0, row[0]} +
        {7'b0, row[1], 1'b0} +
        {6'b0, row[2], 2'b0} +
        {5'b0, row[3], 3'b0} +
        {4'b0, row[4], 4'b0} +
        {3'b0, row[5], 5'b0} +
        {2'b0, row[6], 6'b0} +
        {1'b0, row[7], 7'b0} +
        16'h8100; // Baugh–Wooley +1 at bit n=8 and bit 2n-1=15

    always @(posedge clk) begin
        if (rst) begin out_valid<=0; product<=0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin product <= s; out_valid <= 1'b1; end
        end
    end
endmodule
