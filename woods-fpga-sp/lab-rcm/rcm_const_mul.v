// rcm_const_mul — reduced-coefficient / MCM-style constant multiplies (Ch3 §3.4).
// Implements several fixed coeffs with shift-add/sub only (no general multiplier):
//   c=7  → (x<<3)-x
//   c=5  → (x<<2)+x
//   c=9  → (x<<3)+x
//   c=15 → (x<<4)-x
//   c=6  → (x<<2)+(x<<1)
`timescale 1ns/1ps
module rcm_const_mul (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x,
    input  wire [2:0]         sel,  // 0:7, 1:5, 2:9, 3:15, 4:6
    output reg                out_valid,
    output reg  signed [31:0] y
);
    reg signed [31:0] y_c;
    always @* begin
        case (sel)
            3'd0: y_c = ($signed({x, 3'b0})) - x;           // 8x - x = 7x
            3'd1: y_c = ($signed({x, 2'b0})) + x;           // 4x + x = 5x
            3'd2: y_c = ($signed({x, 3'b0})) + x;           // 8x + x = 9x
            3'd3: y_c = ($signed({x, 4'b0})) - x;           // 16x - x = 15x
            3'd4: y_c = ($signed({x, 2'b0})) + ($signed({x, 1'b0})); // 4x+2x=6x
            default: y_c = 32'sd0;
        endcase
    end
    always @(posedge clk) begin
        if (rst) begin out_valid <= 0; y <= 0; end
        else begin
            out_valid <= 1'b0;
            if (in_valid) begin y <= y_c; out_valid <= 1'b1; end
        end
    end
endmodule
