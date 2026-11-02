// cordic_vector — circular vectoring-mode CORDIC (Woods Ch3 §3.4.4).
// Rotates (x,y) toward x-axis: di = (y<0)? +1 : -1
//   x' = x - di*(y>>>i); y' = y + di*(x>>>i); z' = z - di*atan(2^-i)
// After NITER: x≈K*mag, y≈0, z≈z_in+atan2(y_in,x_in)
`timescale 1ns/1ps
module cordic_vector #(
    parameter integer NITER = 16
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               start,
    input  wire signed [15:0] x_in,
    input  wire signed [15:0] y_in,
    input  wire signed [15:0] z_in,
    output reg                done,
    output reg  signed [15:0] x_out,
    output reg  signed [15:0] y_out,
    output reg  signed [15:0] z_out
);
    function automatic signed [15:0] atan_lut;
        input [3:0] i;
        case (i)
            4'd0:  atan_lut = 16'sd6434;
            4'd1:  atan_lut = 16'sd3798;
            4'd2:  atan_lut = 16'sd2007;
            4'd3:  atan_lut = 16'sd1019;
            4'd4:  atan_lut = 16'sd511;
            4'd5:  atan_lut = 16'sd256;
            4'd6:  atan_lut = 16'sd128;
            4'd7:  atan_lut = 16'sd64;
            4'd8:  atan_lut = 16'sd32;
            4'd9:  atan_lut = 16'sd16;
            4'd10: atan_lut = 16'sd8;
            4'd11: atan_lut = 16'sd4;
            4'd12: atan_lut = 16'sd2;
            4'd13: atan_lut = 16'sd1;
            default: atan_lut = 16'sd0;
        endcase
    endfunction

    localparam S_IDLE = 1'b0, S_RUN = 1'b1;
    reg state;
    reg [3:0] iter;
    reg signed [15:0] x, y, z;

    wire signed [15:0] x_sh = x >>> iter;
    wire signed [15:0] y_sh = y >>> iter;
    wire               yneg = y[15];
    wire signed [15:0] atan = atan_lut(iter);
    // vectoring: di = +1 if y<0 else -1
    // di=+1: x-=y_sh; y+=x_sh; z-=atan
    // di=-1: x+=y_sh; y-=x_sh; z+=atan
    wire signed [15:0] x_n = yneg ? (x - y_sh) : (x + y_sh);
    wire signed [15:0] y_n = yneg ? (y + x_sh) : (y - x_sh);
    wire signed [15:0] z_n = yneg ? (z - atan) : (z + atan);

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; done <= 0; iter <= 0;
            x <= 0; y <= 0; z <= 0;
            x_out <= 0; y_out <= 0; z_out <= 0;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE: if (start) begin
                    x <= x_in; y <= y_in; z <= z_in;
                    iter <= 0; state <= S_RUN;
                end
                S_RUN: begin
                    x <= x_n; y <= y_n; z <= z_n;
                    if (iter == NITER[3:0] - 4'd1) begin
                        x_out <= x_n; y_out <= y_n; z_out <= z_n;
                        done <= 1'b1; state <= S_IDLE; iter <= 0;
                    end else iter <= iter + 4'd1;
                end
            endcase
        end
    end
endmodule
