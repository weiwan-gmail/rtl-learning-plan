// fft8 — 8-point radix-2 DIT FFT (Woods Ch2 §2.3.2 teaching DUT).
// Data: signed 16-bit. Twiddles: Q15. Each butterfly output >>>1 (overall /8).
// Flow: accept 8 natural-order samples (in_valid while in_ready) stored
// bit-reversed; 12 cycles of butterflies (3 stages × 4); stream 8 bins out.
`timescale 1ns/1ps
module fft8 (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] din_re,
    input  wire signed [15:0] din_im,
    output reg                in_ready,
    output reg                out_valid,
    output reg  signed [15:0] dout_re,
    output reg  signed [15:0] dout_im,
    output reg                done
);
    localparam signed [15:0] ONE_Q15  = 16'sd32767;
    localparam signed [15:0] COS_PI4  = 16'sd23170;

    reg signed [15:0] xr [0:7];
    reg signed [15:0] xi [0:7];

    localparam S_LOAD = 2'd0;
    localparam S_STG  = 2'd1;
    localparam S_OUT  = 2'd2;

    reg [1:0] state;
    reg [2:0] load_cnt, out_cnt;
    reg [1:0] stage, bfly;

    function automatic [2:0] bitrev3;
        input [2:0] a;
        bitrev3 = {a[0], a[1], a[2]};
    endfunction

    // index pair
    reg [2:0] ia, ib;
    always @(*) begin
        case (stage)
            2'd0: begin ia = {bfly, 1'b0}; ib = {bfly, 1'b1}; end
            2'd1: begin ia = {bfly[1], 1'b0, bfly[0]}; ib = {bfly[1], 1'b1, bfly[0]}; end
            default: begin ia = {1'b0, bfly}; ib = {1'b1, bfly}; end
        endcase
    end

    reg signed [15:0] wr, wi;
    always @(*) begin
        wr = ONE_Q15; wi = 16'sd0;
        case (stage)
            2'd0: begin wr = ONE_Q15; wi = 16'sd0; end
            2'd1: begin
                if (bfly[0] == 1'b0) begin wr = ONE_Q15; wi = 16'sd0; end
                else begin wr = 16'sd0; wi = -ONE_Q15; end
            end
            default: begin
                case (bfly)
                    2'd0: begin wr = ONE_Q15; wi = 16'sd0; end
                    2'd1: begin wr = COS_PI4; wi = -COS_PI4; end
                    2'd2: begin wr = 16'sd0;  wi = -ONE_Q15; end
                    default: begin wr = -COS_PI4; wi = -COS_PI4; end
                endcase
            end
        endcase
    end

    // Combinational butterfly from current xr/xi[ia,ib]
    wire signed [15:0] ar = xr[ia];
    wire signed [15:0] ai = xi[ia];
    wire signed [15:0] br = xr[ib];
    wire signed [15:0] bi = xi[ib];
    wire signed [31:0] p_rr = br * wr;
    wire signed [31:0] p_ii = bi * wi;
    wire signed [31:0] p_ri = br * wi;
    wire signed [31:0] p_ir = bi * wr;
    wire signed [15:0] pr = (p_rr - p_ii) >>> 15;
    wire signed [15:0] pi = (p_ri + p_ir) >>> 15;
    wire signed [16:0] s_r = {ar[15], ar} + {pr[15], pr};
    wire signed [16:0] s_i = {ai[15], ai} + {pi[15], pi};
    wire signed [16:0] d_r = {ar[15], ar} - {pr[15], pr};
    wire signed [16:0] d_i = {ai[15], ai} - {pi[15], pi};
    wire signed [15:0] a_r_n = s_r >>> 1;
    wire signed [15:0] a_i_n = s_i >>> 1;
    wire signed [15:0] b_r_n = d_r >>> 1;
    wire signed [15:0] b_i_n = d_i >>> 1;

    integer k;
    always @(posedge clk) begin
        if (rst) begin
            state <= S_LOAD;
            load_cnt <= 0; out_cnt <= 0; stage <= 0; bfly <= 0;
            in_ready <= 1'b1; out_valid <= 1'b0; done <= 1'b0;
            dout_re <= 0; dout_im <= 0;
            for (k = 0; k < 8; k = k + 1) begin
                xr[k] <= 0; xi[k] <= 0;
            end
        end else begin
            out_valid <= 1'b0;
            done <= 1'b0;
            case (state)
                S_LOAD: begin
                    in_ready <= 1'b1;
                    if (in_valid) begin
                        xr[bitrev3(load_cnt)] <= din_re;
                        xi[bitrev3(load_cnt)] <= din_im;
                        if (load_cnt == 3'd7) begin
                            load_cnt <= 0;
                            stage <= 0;
                            bfly <= 0;
                            in_ready <= 1'b0;
                            state <= S_STG;
                        end else
                            load_cnt <= load_cnt + 3'd1;
                    end
                end
                S_STG: begin
                    xr[ia] <= a_r_n;
                    xi[ia] <= a_i_n;
                    xr[ib] <= b_r_n;
                    xi[ib] <= b_i_n;
                    if (bfly == 2'd3) begin
                        bfly <= 0;
                        if (stage == 2'd2) begin
                            out_cnt <= 0;
                            state <= S_OUT;
                        end else
                            stage <= stage + 2'd1;
                    end else
                        bfly <= bfly + 2'd1;
                end
                S_OUT: begin
                    out_valid <= 1'b1;
                    dout_re <= xr[out_cnt];
                    dout_im <= xi[out_cnt];
                    if (out_cnt == 3'd7) begin
                        done <= 1'b1;
                        state <= S_LOAD;
                        in_ready <= 1'b1;
                        out_cnt <= 0;
                    end else
                        out_cnt <= out_cnt + 3'd1;
                end
            endcase
        end
    end
endmodule
