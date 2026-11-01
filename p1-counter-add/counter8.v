// counter8: 8-bit free-running counter with sync reset and enable.
// Wrap: 8'hFF + 1 -> 8'h00 (unsigned modulo 256).
module counter8 (
    input  wire       clk,
    input  wire       rst,   // sync active-high
    input  wire       en,
    output reg  [7:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= 8'd0;
        else if (en)
            q <= q + 8'd1;  // wraps naturally
    end
endmodule
