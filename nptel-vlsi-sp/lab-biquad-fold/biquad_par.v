// biquad_par — fully-parallel DF-I biquad (Woods-style). Q15. LATENCY=1.
`timescale 1ns/1ps
module biquad_par (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x_in,
    input  wire signed [15:0] b0, b1, b2, a1, a2,
    output reg                out_valid,
    output reg  signed [15:0] y_out
);
    reg signed [15:0] x1, x2, y1, y2;
    wire signed [31:0] acc =
        $signed(b0)*$signed(x_in) + $signed(b1)*$signed(x1) + $signed(b2)*$signed(x2)
      - $signed(a1)*$signed(y1)   - $signed(a2)*$signed(y2);
    wire signed [15:0] yn = acc[30:15];
    always @(posedge clk) begin
        if (rst) begin
            x1<=0; x2<=0; y1<=0; y2<=0; y_out<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                y_out <= yn; out_valid <= 1'b1;
                x2<=x1; x1<=x_in; y2<=y1; y1<=yn;
            end
        end
    end
endmodule
