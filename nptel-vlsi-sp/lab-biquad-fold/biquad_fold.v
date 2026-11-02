// biquad_fold — folding factor N=5: one mul + one add time-muxed (L21–L22).
// Same DF-I equation as biquad_par; 5 clocks per output sample.
`timescale 1ns/1ps
module biquad_fold (
    input  wire               clk,
    input  wire               rst,
    input  wire               in_valid,
    input  wire signed [15:0] x_in,
    input  wire signed [15:0] b0, b1, b2, a1, a2,
    output reg                out_valid,
    output reg  signed [15:0] y_out,
    output wire               busy
);
    reg signed [15:0] x1, x2, y1, y2, xhold;
    reg signed [31:0] acc;
    reg [2:0] phase; // 0 idle, 1..5 working
    assign busy = (phase != 0);

    wire signed [15:0] yn = acc[30:15];

    always @(posedge clk) begin
        if (rst) begin
            x1<=0; x2<=0; y1<=0; y2<=0; xhold<=0; acc<=0;
            phase<=0; y_out<=0; out_valid<=0;
        end else begin
            out_valid <= 1'b0;
            case (phase)
                3'd0: begin
                    if (in_valid) begin
                        xhold <= x_in;
                        acc   <= $signed(b0) * $signed(x_in); // cycle 1: b0*x
                        phase <= 3'd1;
                    end
                end
                3'd1: begin
                    acc   <= acc + $signed(b1)*$signed(x1);
                    phase <= 3'd2;
                end
                3'd2: begin
                    acc   <= acc + $signed(b2)*$signed(x2);
                    phase <= 3'd3;
                end
                3'd3: begin
                    acc   <= acc - $signed(a1)*$signed(y1);
                    phase <= 3'd4;
                end
                3'd4: begin
                    begin : last
                        reg signed [31:0] accn;
                        reg signed [15:0] ynew;
                        accn = acc - $signed(a2)*$signed(y2);
                        ynew = accn[30:15];
                        acc <= accn;
                        y_out <= ynew;
                        out_valid <= 1'b1;
                        x2 <= x1; x1 <= xhold;
                        y2 <= y1; y1 <= ynew;
                        phase <= 3'd0;
                    end
                end
                default: phase <= 3'd0;
            endcase
        end
    end
endmodule
