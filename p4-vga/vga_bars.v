// vga_bars: 8 classic color bars across active pixels (combinational).
// When de=0, RGB forced black. Bar width = H_RES/8 (80 px for 640).
module vga_bars #(
    parameter H_RES = 640
) (
    input  wire        de,
    input  wire [9:0]  x,
    input  wire [9:0]  y,   // unused; kept for pattern variants
    output reg  [7:0]  r,
    output reg  [7:0]  g,
    output reg  [7:0]  b
);
    // 640/8 = 80; use /80 so bar index is x[9:0]/80
    wire [2:0] bar = x / (H_RES / 8);

    always @(*) begin
        if (!de) begin
            r = 8'h00; g = 8'h00; b = 8'h00;
        end else begin
            case (bar)
                3'd0: begin r = 8'hFF; g = 8'hFF; b = 8'hFF; end // white
                3'd1: begin r = 8'hFF; g = 8'hFF; b = 8'h00; end // yellow
                3'd2: begin r = 8'h00; g = 8'hFF; b = 8'hFF; end // cyan
                3'd3: begin r = 8'h00; g = 8'hFF; b = 8'h00; end // green
                3'd4: begin r = 8'hFF; g = 8'h00; b = 8'hFF; end // magenta
                3'd5: begin r = 8'hFF; g = 8'h00; b = 8'h00; end // red
                3'd6: begin r = 8'h00; g = 8'h00; b = 8'hFF; end // blue
                default: begin r = 8'h00; g = 8'h00; b = 8'h00; end // black
            endcase
        end
    end
endmodule
