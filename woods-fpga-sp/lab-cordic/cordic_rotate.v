// cordic_rotate — circular rotation-mode CORDIC (Woods Ch3 §3.4.4 teaching DUT).
// 16 iterative steps. x/y: signed 16-bit Q2.14-ish integers; z: angle in Q1.13
// (rad * 2^13). Rotation mode (circular m=1): di = (z<0)? -1 : +1
//   x' = x - di*(y>>>i);  y' = y + di*(x>>>i);  z' = z - di*atan(2^-i)
// Handshake: start loads inputs; done pulses with final x/y/z.
// CORDIC gain ≈1.64676 is NOT compensated (feed Xin*Kinv if you need unit gain).
`timescale 1ns/1ps
module cordic_rotate #(
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
    // atan(2^-i) * 2^13, rounded — must match check_cordic.py
    function automatic signed [15:0] atan_lut;
        input [3:0] i;
        begin
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
                4'd14: atan_lut = 16'sd0;
                default: atan_lut = 16'sd0;
            endcase
        end
    endfunction

    localparam S_IDLE = 1'b0;
    localparam S_RUN  = 1'b1;

    reg               state;
    reg [3:0]         iter;
    reg signed [15:0] x, y, z;

    wire signed [15:0] x_sh = x >>> iter;
    wire signed [15:0] y_sh = y >>> iter;
    wire               zneg = z[15];
    wire signed [15:0] atan = atan_lut(iter);

    wire signed [15:0] x_n = zneg ? (x + y_sh) : (x - y_sh);
    wire signed [15:0] y_n = zneg ? (y - x_sh) : (y + x_sh);
    wire signed [15:0] z_n = zneg ? (z + atan) : (z - atan);

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            done  <= 1'b0;
            iter  <= 4'd0;
            x     <= 16'sd0;
            y     <= 16'sd0;
            z     <= 16'sd0;
            x_out <= 16'sd0;
            y_out <= 16'sd0;
            z_out <= 16'sd0;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE: begin
                    if (start) begin
                        x     <= x_in;
                        y     <= y_in;
                        z     <= z_in;
                        iter  <= 4'd0;
                        state <= S_RUN;
                    end
                end
                S_RUN: begin
                    x <= x_n;
                    y <= y_n;
                    z <= z_n;
                    if (iter == NITER[3:0] - 4'd1) begin
                        x_out <= x_n;
                        y_out <= y_n;
                        z_out <= z_n;
                        done  <= 1'b1;
                        state <= S_IDLE;
                        iter  <= 4'd0;
                    end else begin
                        iter <= iter + 4'd1;
                    end
                end
            endcase
        end
    end
endmodule
