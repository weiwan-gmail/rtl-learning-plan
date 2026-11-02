// csd_mul — CSD constant multiply for homework constants 29 and -19 (A7 Q5, A8 Q5).
//   29  =  32 - 4 + 1  = 100T01
//  -19  = -16 - 4 + 1  = T0T01
`timescale 1ns/1ps
module csd_mul (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x,
    input  wire               sel_m19, // 0: *29, 1: *(-19)
    output reg                out_valid,
    output reg  signed [31:0] y
);
    wire signed [31:0] xw = x;
    wire signed [31:0] y29  = (xw <<< 5) - (xw <<< 2) + xw;           // 32x-4x+x
    wire signed [31:0] ym19 = -(xw <<< 4) - (xw <<< 2) + xw;          // -16x-4x+x
    always @(posedge clk) begin
        if (rst) begin out_valid<=0; y<=0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                y <= sel_m19 ? ym19 : y29;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
