// iir_lookahead — clustered 2-step look-ahead of y[n]=x[n]+y[n-1]:
//   y[n] = x[n] + x[n-1] + y[n-2]
// Two delays in the recursive loop ⇒ a pipeline register may sit on x[n]+x[n-1]
// without changing the sample rate (scattered look-ahead is identical at order 1).
`timescale 1ns/1ps
module iir_lookahead (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    reg signed [15:0] x1, y1, y2;
    wire signed [15:0] yn = din + x1 + y2;
    always @(posedge clk) begin
        if (rst) begin
            x1<=0; y1<=0; y2<=0; dout<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= yn;
                x1   <= din;
                y2   <= y1;
                y1   <= yn;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
