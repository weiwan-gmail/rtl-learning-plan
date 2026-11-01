// nco — minimal phase-accumulator NCO (original teaching stub).
// Each in_valid: phase <= phase + freq_word; dout = signed MSBs of new phase
// (sawtooth via MSB truncation — no sine LUT; enough to show NCO plumbing).
// LATENCY = 1: in_valid @ capture edge N → out_valid/dout after that edge.
module nco #(
    parameter integer PH_W  = 32,
    parameter integer OUT_W = 16
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    in_valid,
    input  wire [PH_W-1:0]         freq_word,
    output reg                     out_valid,
    output reg  signed [OUT_W-1:0] dout
);
    reg [PH_W-1:0] phase;
    wire [PH_W-1:0] phase_next = phase + freq_word;

    always @(posedge clk) begin
        if (rst) begin
            phase     <= {PH_W{1'b0}};
            out_valid <= 1'b0;
            dout      <= {OUT_W{1'b0}};
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                phase <= phase_next;
                dout  <= phase_next[PH_W-1 -: OUT_W];
            end
        end
    end
endmodule
