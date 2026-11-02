// iir_plain — y[n] = x[n] + y[n-1]  (integrator, a=1). LATENCY=1. Streaming OK.
`timescale 1ns/1ps
module iir_plain (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din,
    output reg                out_valid,
    output reg  signed [15:0] dout
);
    always @(posedge clk) begin
        if (rst) begin dout<=0; out_valid<=0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                dout <= din + dout;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
