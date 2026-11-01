// vga_timing: classic 640x480@60 VGA raster counters.
// Pixel clock is abstract (TB/board supplies clk). Syncs are active-low.
// Defaults: H 640+16+96+48=800, V 480+10+2+33=525.
// Counters registered; hsync/vsync/de/x/y combinational from counters (aligned).
module vga_timing #(
    parameter H_RES   = 640,
    parameter H_FP    = 16,
    parameter H_SYNC  = 96,
    parameter H_BP    = 48,
    parameter V_RES   = 480,
    parameter V_FP    = 10,
    parameter V_SYNC  = 2,
    parameter V_BP    = 33
) (
    input  wire        clk,
    input  wire        rst,   // sync active-high
    output wire        hsync, // active low
    output wire        vsync, // active low
    output wire        de,    // 1 in visible area
    output wire [9:0]  x,     // 0..H_RES-1 when de, else 0
    output wire [9:0]  y      // 0..V_RES-1 when de, else 0
);
    localparam integer H_TOTAL  = H_RES + H_FP + H_SYNC + H_BP; // 800
    localparam integer V_TOTAL  = V_RES + V_FP + V_SYNC + V_BP; // 525
    localparam integer H_SYNC_S = H_RES + H_FP;                 // 656
    localparam integer H_SYNC_E = H_SYNC_S + H_SYNC;            // 752
    localparam integer V_SYNC_S = V_RES + V_FP;                 // 490
    localparam integer V_SYNC_E = V_SYNC_S + V_SYNC;            // 492

    reg [9:0] h_cnt;
    reg [9:0] v_cnt;

    wire h_last = (h_cnt == H_TOTAL - 1);
    wire v_last = (v_cnt == V_TOTAL - 1);

    always @(posedge clk) begin
        if (rst) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
        end else if (h_last) begin
            h_cnt <= 10'd0;
            if (v_last)
                v_cnt <= 10'd0;
            else
                v_cnt <= v_cnt + 10'd1;
        end else begin
            h_cnt <= h_cnt + 10'd1;
        end
    end

    assign hsync = ~((h_cnt >= H_SYNC_S) && (h_cnt < H_SYNC_E));
    assign vsync = ~((v_cnt >= V_SYNC_S) && (v_cnt < V_SYNC_E));
    assign de    = (h_cnt < H_RES) && (v_cnt < V_RES);
    assign x     = (h_cnt < H_RES) ? h_cnt : 10'd0;
    assign y     = (v_cnt < V_RES) ? v_cnt : 10'd0;
endmodule
