// dlms1 — Delayed-LMS D=1 on the weight update (same μ as lms2).
`timescale 1ns/1ps
module dlms2 #(
    parameter integer MUSHIFT = 6,
    parameter integer D       = 1
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] xin,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] yout,
    output reg  signed [15:0] eout,
    output reg  signed [15:0] w0_out,
    output reg  signed [15:0] w1_out
);
    reg signed [15:0] w0, e_d, x_d;
    function automatic signed [15:0] sat16;
        input signed [31:0] v;
        begin
            if (v > 32'sd32767) sat16 = 16'sd32767;
            else if (v < -32'sd32768) sat16 = -32'sd32768;
            else sat16 = v[15:0];
        end
    endfunction
    always @(posedge clk) begin
        if (rst) begin
            w0 <= 0; e_d <= 0; x_d <= 0;
            out_valid <= 0; yout <= 0; eout <= 0; w0_out <= 0; w1_out <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                begin : step
                    reg signed [15:0] yw, ew, nw;
                    reg signed [31:0] y, e, dw;
                    y  = (xin * w0);
                    yw = sat16(y);
                    e  = {{16{din[15]}}, din} - {{16{yw[15]}}, yw};
                    ew = sat16(e);
                    dw = (e_d * x_d) >>> MUSHIFT;
                    nw = sat16({{16{w0[15]}}, w0} + dw);
                    w0 <= nw;
                    e_d <= ew; x_d <= xin;
                    yout <= yw; eout <= ew; w0_out <= nw; w1_out <= 0;
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
