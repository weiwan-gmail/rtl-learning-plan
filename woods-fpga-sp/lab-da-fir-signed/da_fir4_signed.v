// da_fir4_signed — 4-tap FIR via signed Distributed Arithmetic (Woods Ch6 Eq.6.13+).
// Coeffs H=[1,2,2,1]. Input: signed 8-bit (din[7:0] as 2's complement).
// Bit-serial: bits 0..6 positive weight; bit 7 (sign) subtracted with weight 2^7.
`timescale 1ns/1ps
module da_fir4_signed (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,   // use [7:0] as signed sample
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    function automatic signed [15:0] da_lut;
        input [3:0] addr;
        reg signed [15:0] s;
        begin
            s = 16'sd0;
            if (addr[3]) s = s + 16'sd1;
            if (addr[2]) s = s + 16'sd2;
            if (addr[1]) s = s + 16'sd2;
            if (addr[0]) s = s + 16'sd1;
            da_lut = s;
        end
    endfunction

    reg signed [7:0] x0, x1, x2, x3;
    reg              busy;
    reg [2:0]        bit_i;
    reg signed [15:0] acc;

    wire [3:0] slice = {x0[bit_i], x1[bit_i], x2[bit_i], x3[bit_i]};
    wire signed [15:0] term = da_lut(slice) <<< bit_i;

    always @(posedge clk) begin
        if (rst) begin
            x0 <= 0; x1 <= 0; x2 <= 0; x3 <= 0;
            busy <= 0; bit_i <= 0; acc <= 0;
            out_valid <= 0; dout <= 0;
        end else begin
            out_valid <= 1'b0;
            if (!busy) begin
                if (in_valid) begin
                    x3 <= x2; x2 <= x1; x1 <= x0;
                    x0 <= din[7:0];
                    acc <= 16'sd0; bit_i <= 3'd0; busy <= 1'b1;
                end
            end else begin
                if (bit_i == 3'd7) begin
                    // sign bit: subtract
                    dout <= acc - term;
                    out_valid <= 1'b1;
                    busy <= 1'b0; bit_i <= 3'd0;
                end else begin
                    acc <= acc + term;
                    bit_i <= bit_i + 3'd1;
                end
            end
        end
    end
endmodule
