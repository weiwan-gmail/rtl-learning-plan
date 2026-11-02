// givens_apply — 2x2 Givens nulling form (Woods Ch11 QR):
//   [x'] = [ c  s] [x]     with c=x/r, s=y/r, r=hypot(x,y)
//   [y']   [-s  c] [y]  →  (r, 0)
// Q15 c,s; outs are (·)>>15. Latency 1.
`timescale 1ns/1ps
module givens_apply (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] c, s,
    input  wire signed [15:0] x_in, y_in,
    output reg                out_valid,
    output reg  signed [15:0] x_out, y_out
);
    wire signed [31:0] xn = $signed(c)*$signed(x_in) + $signed(s)*$signed(y_in);
    wire signed [31:0] yn = -$signed(s)*$signed(x_in) + $signed(c)*$signed(y_in);
    always @(posedge clk) begin
        if (rst) begin out_valid<=0; x_out<=0; y_out<=0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                x_out <= xn[30:15];
                y_out <= yn[30:15];
                out_valid <= 1'b1;
            end
        end
    end
endmodule
