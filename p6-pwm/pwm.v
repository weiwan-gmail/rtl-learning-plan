// pwm — counter-compare PWM generator (teaching DUT for P6 / N5).
// Style: free-running counter 0 .. PERIOD-1; pwm_out high while cnt < DUTY.
// PERIOD==0 treated as 1 to avoid div-by-zero hang; DUTY>=PERIOD => always high;
// DUTY==0 => always low (when PERIOD>0).
module pwm #(
    parameter integer W = 16
) (
    input  wire             clk,
    input  wire             rst,
    input  wire [W-1:0]     period,   // clocks per PWM cycle (>=1 meaningful)
    input  wire [W-1:0]     duty,     // high time in clocks
    output reg              pwm_out
);
    reg [W-1:0] cnt;
    wire [W-1:0] period_eff = (period == {W{1'b0}}) ? {{(W-1){1'b0}}, 1'b1} : period;
    wire         wrap       = (cnt >= period_eff - {{(W-1){1'b0}}, 1'b1});
    wire         high       = (cnt < duty);

    always @(posedge clk) begin
        if (rst) begin
            cnt     <= {W{1'b0}};
            pwm_out <= 1'b0;
        end else begin
            cnt     <= wrap ? {W{1'b0}} : (cnt + {{(W-1){1'b0}}, 1'b1});
            pwm_out <= high;
        end
    end
endmodule
