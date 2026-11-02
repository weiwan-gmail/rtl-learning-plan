// sgr_step — Squared / unnormalized Givens teaching step (Woods Ch11 / SGR idea).
// Beyond lab-givens2 (needs c=a/r,s=b/r): here we KEEP (a,b) as "r·(c,s)" and
// apply the scaled rotation — NO sqrt, NO division:
//   [x'] = [ a  b] [x]     when (x,y)=(a,b) → (a²+b², 0) = (r², 0)
//   [y']   [-b  a] [y]
// Also outputs r2 = a*a+b*b (squared hypot). Latency 1.
// Full multi-tap QR-RLS array remains PLACEHOLDER; this is the SGR building block.
`timescale 1ns/1ps
module sgr_step (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] a, b,     // pivot column (unnormalized c,s)
    input  wire signed [15:0] x_in, y_in,
    output reg                out_valid,
    output reg  signed [31:0] x_out,    // wide: a*x+b*y fits 32
    output reg  signed [31:0] y_out,
    output reg  signed [31:0] r2_out
);
    wire signed [31:0] xn = $signed(a)*$signed(x_in) + $signed(b)*$signed(y_in);
    wire signed [31:0] yn = -$signed(b)*$signed(x_in) + $signed(a)*$signed(y_in);
    wire signed [31:0] r2 = $signed(a)*$signed(a) + $signed(b)*$signed(b);

    always @(posedge clk) begin
        if (rst) begin
            out_valid <= 0; x_out <= 0; y_out <= 0; r2_out <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                x_out <= xn;
                y_out <= yn;
                r2_out <= r2;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
