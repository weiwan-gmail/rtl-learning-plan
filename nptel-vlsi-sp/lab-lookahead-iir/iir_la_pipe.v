// iir_la_pipe — look-ahead with the feed-forward add pipelined (LATENCY=2).
// Sample with 1-cycle bubbles (TB) so y2 lines up; bit-exact vs iir_plain.
`timescale 1ns/1ps
module iir_la_pipe (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    reg signed [15:0] x1, y1, y2, ff;
    reg               v1;
    always @(posedge clk) begin
        if (rst) begin
            x1<=0; y1<=0; y2<=0; ff<=0; v1<=0; dout<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            v1 <= in_valid;
            if (in_valid) begin
                ff <= din + x1;
                x1 <= din;
            end
            if (v1) begin
                begin : s2
                    reg signed [15:0] yn;
                    yn = ff + y2;
                    dout <= yn;
                    y2   <= y1;
                    y1   <= yn;
                    out_valid <= 1'b1;
                end
            end
        end
    end
endmodule
