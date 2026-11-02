// da_fir4 — 4-tap FIR via Distributed Arithmetic (Woods Ch6 §6.5 teaching DUT).
// Coeffs fixed H = [1, 2, 2, 1]. Input: unsigned 8-bit samples on din[7:0]
// (din[15:8] ignored). Output: signed 16-bit y = sum H_i * x_i (exact for
// 8-bit unsigned inputs; max = (1+2+2+1)*255 = 1530).
//
// Bit-serial DA: after accepting a sample, spends 8 clocks accumulating
// LUT(bit-slice) << bit. Latency from in_valid to out_valid ≈ 1 + 8 cycles.
// in_valid ignored while busy.
`timescale 1ns/1ps
module da_fir4 (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,   // use [7:0] as unsigned sample
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    // LUT: addr = {x0[b],x1[b],x2[b],x3[b]} → sum of H for bits=1
    // H0=1,H1=2,H2=2,H3=1
    function automatic signed [15:0] da_lut;
        input [3:0] addr;
        reg signed [15:0] s;
        begin
            s = 16'sd0;
            if (addr[3]) s = s + 16'sd1; // H0
            if (addr[2]) s = s + 16'sd2; // H1
            if (addr[1]) s = s + 16'sd2; // H2
            if (addr[0]) s = s + 16'sd1; // H3
            da_lut = s;
        end
    endfunction

    reg [7:0] x0, x1, x2, x3;
    reg       busy;
    reg [2:0] bit_i;
    reg signed [15:0] acc;

    wire [3:0] slice = {x0[bit_i], x1[bit_i], x2[bit_i], x3[bit_i]};

    always @(posedge clk) begin
        if (rst) begin
            x0 <= 0; x1 <= 0; x2 <= 0; x3 <= 0;
            busy <= 0; bit_i <= 0; acc <= 0;
            out_valid <= 0; dout <= 0;
        end else begin
            out_valid <= 1'b0;
            if (!busy) begin
                if (in_valid) begin
                    x3 <= x2;
                    x2 <= x1;
                    x1 <= x0;
                    x0 <= din[7:0];
                    acc <= 16'sd0;
                    bit_i <= 3'd0;
                    busy <= 1'b1;
                end
            end else begin
                // acc += LUT(slice) << bit_i
                acc <= acc + (da_lut(slice) <<< bit_i);
                if (bit_i == 3'd7) begin
                    dout <= acc + (da_lut(slice) <<< bit_i);
                    out_valid <= 1'b1;
                    busy <= 1'b0;
                    bit_i <= 3'd0;
                end else begin
                    bit_i <= bit_i + 3'd1;
                end
            end
        end
    end
endmodule
