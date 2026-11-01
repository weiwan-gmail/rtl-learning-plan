// cic_decim — N-stage CIC decimate-by-R (teaching DUT for P7 / N6).
// Original RTL (no ZipCPU / Xilinx IP). Fixed teaching params default:
//   N=2 stages, R=4, M=1 differential delay.
//
// Structure (Hogenauer):
//   integrators @ input rate  -> keep every R-th sample -> combs @ output rate
// Same-cycle integrator cascade (combinational next + one register bank).
// Comb: y = x - z^{-M} x, M=1 unrolled as single delay per stage.
//
// Bit growth: OUT_W >= IN_W + N*ceil(log2(R*M)); default IN_W=16, OUT_W=20
//   for N=2,R=4,M=1 (gain=(R*M)^N=16 → +4 bits).
//
// Latency (in_valid samples → first out_valid):
//   After reset, first R accepted samples produce one comb-section fire;
//   comb is registered → out_valid asserts 1 clk after the R-th sample edge.
//   So first output appears on the clock after the R-th in_valid sample
//   (R input samples + 1 registered comb stage). Integrators update that
//   same edge as the R-th sample before the comb sees them (NBA-safe wires).
module cic_decim #(
    parameter integer N     = 2,
    parameter integer R     = 4,
    parameter integer M     = 1,   // must be 1 in this teaching RTL
    parameter integer IN_W  = 16,
    parameter integer OUT_W = 20
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [IN_W-1:0]   din,
    output reg                      out_valid,
    output reg  signed [OUT_W-1:0]  dout
);
    // This minimal lab hard-codes N=2, M=1; parameters kept for docs/TB.
    // synthesis translate_off
    initial begin
        if (N != 2)  $fatal(1, "cic_decim teaching RTL requires N=2");
        if (M != 1)  $fatal(1, "cic_decim teaching RTL requires M=1");
        if (R < 2)   $fatal(1, "cic_decim requires R>=2");
    end
    // synthesis translate_on

    reg signed [OUT_W-1:0] i0, i1;
    reg signed [OUT_W-1:0] c_d0, c_d1;  // comb delays (M=1)
    reg [15:0]             dec_cnt;

    wire signed [OUT_W-1:0] din_ext = {{(OUT_W-IN_W){din[IN_W-1]}}, din};
    wire signed [OUT_W-1:0] i0_next = i0 + din_ext;
    wire signed [OUT_W-1:0] i1_next = i1 + i0_next;

    wire                    strobe  = in_valid && (dec_cnt == R[15:0] - 16'd1);

    wire signed [OUT_W-1:0] c0 = i1_next - c_d0;
    wire signed [OUT_W-1:0] c1 = c0 - c_d1;

    always @(posedge clk) begin
        if (rst) begin
            i0        <= {OUT_W{1'b0}};
            i1        <= {OUT_W{1'b0}};
            c_d0      <= {OUT_W{1'b0}};
            c_d1      <= {OUT_W{1'b0}};
            dec_cnt   <= 16'd0;
            out_valid <= 1'b0;
            dout      <= {OUT_W{1'b0}};
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                i0 <= i0_next;
                i1 <= i1_next;
                if (dec_cnt == R[15:0] - 16'd1)
                    dec_cnt <= 16'd0;
                else
                    dec_cnt <= dec_cnt + 16'd1;
            end
            if (strobe) begin
                c_d0      <= i1_next;
                c_d1      <= c0;
                dout      <= c1;
                out_valid <= 1'b1;
            end
        end
    end
endmodule
