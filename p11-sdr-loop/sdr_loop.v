// sdr_loop — teaching TX→RX loopback stub (Track B / A3 lite).
// Chain: NCO tone (or DC inject) → fir4 → cic_decim (N=2,R=4,M=1).
// Reuses ../p3-fir-nco/{nco,fir4}.v and ../p7-cic/cic_decim.v (no RTL copy).
// No Vivado / no MathWorks IP; sim-only teaching path (not a full QPSK modem).
module sdr_loop #(
    parameter integer PH_W  = 32,
    parameter integer IN_W  = 16,
    parameter integer OUT_W = 20,
    parameter integer N     = 2,
    parameter integer R     = 4,
    parameter integer M     = 1
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire [PH_W-1:0]          freq_word,
    // src_is_dc=1: feed dc_val into FIR (skip NCO). Else NCO → FIR.
    input  wire                     src_is_dc,
    input  wire signed [IN_W-1:0]   dc_val,
    output wire                     out_valid,
    output wire signed [OUT_W-1:0]  dout
);
    wire                     nco_valid;
    wire signed [IN_W-1:0]   nco_dout;

    wire                     fir_in_valid;
    wire signed [IN_W-1:0]   fir_din;
    wire                     fir_out_valid;
    wire signed [IN_W-1:0]   fir_dout;

    nco #(.PH_W(PH_W), .OUT_W(IN_W)) u_nco (
        .clk(clk), .rst(rst),
        .in_valid(in_valid & ~src_is_dc),
        .freq_word(freq_word),
        .out_valid(nco_valid),
        .dout(nco_dout)
    );

    assign fir_in_valid = src_is_dc ? in_valid : nco_valid;
    assign fir_din      = src_is_dc ? dc_val   : nco_dout;

    fir4 u_fir (
        .clk(clk), .rst(rst),
        .in_valid(fir_in_valid),
        .din(fir_din),
        .out_valid(fir_out_valid),
        .dout(fir_dout)
    );

    cic_decim #(
        .N(N), .R(R), .M(M), .IN_W(IN_W), .OUT_W(OUT_W)
    ) u_cic (
        .clk(clk), .rst(rst),
        .in_valid(fir_out_valid),
        .din(fir_dout),
        .out_valid(out_valid),
        .dout(dout)
    );
endmodule
