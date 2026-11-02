// bitserial_fir — y(n) = -3*x(n) + 3*x(n-1)   A8 Q3 / L37
`timescale 1ns/1ps
module bitserial_fir #(
    parameter integer W = 8
) (
    input  wire               clk,
    input  wire               rst,
    input  wire               word_start,
    input  wire               xbit,
    output reg                ybit,
    output reg                ybit_valid,
    output reg  signed [15:0] y_word,
    output reg                y_word_valid
);
    // 3 registered serial-adder stages → LSB latency 3
    reg x_d, c1, s1, v1, ws1, s2, v2, ws2, c3;
    wire x2bit = word_start ? 1'b0 : x_d;
    wire [1:0] fa1 = {1'b0, xbit} + {1'b0, x2bit} + {1'b0, (word_start ? 1'b0 : c1)};
    wire [1:0] fa3 = {1'b0, 1'b0} + {1'b0, ~s2} + {1'b0, (ws2 ? 1'b1 : c3)};

    reg [15:0] xsh;
    reg [3:0]  bcnt;
    reg        inw;
    reg signed [15:0] xprev;

    function automatic signed [15:0] sextw;
        input [15:0] raw;
        begin
            sextw = {{(16-W){raw[W-1]}}, raw[W-1:0]};
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            x_d<=0; c1<=0; s1<=0; v1<=0; ws1<=0;
            s2<=0; v2<=0; ws2<=0; c3<=0;
            ybit<=0; ybit_valid<=0;
            y_word<=0; y_word_valid<=0;
            xsh<=0; xprev<=0; bcnt<=0; inw<=0;
        end else begin
            y_word_valid <= 1'b0;
            x_d <= xbit;
            s1  <= fa1[0];
            c1  <= fa1[1];
            v1  <= 1'b1;
            ws1 <= word_start;
            s2  <= s1;
            v2  <= v1;
            ws2 <= ws1;
            ybit       <= fa3[0];
            c3         <= fa3[1];
            ybit_valid <= v2;

            if (word_start) begin
                xsh <= {15'b0, xbit};
                bcnt <= 4'd1;
                inw  <= 1'b1;
            end else if (inw) begin
                xsh <= xsh | ({{15{1'b0}}, xbit} << bcnt);
                if (bcnt == W-1) begin
                    begin : emit
                        reg signed [15:0] xn, yn;
                        xn = sextw(xsh | ({{15{1'b0}}, xbit} << bcnt));
                        yn = -16'sd3 * xn + 16'sd3 * xprev;
                        y_word <= yn;
                        y_word_valid <= 1'b1;
                        xprev <= xn;
                    end
                    inw <= 1'b0;
                    bcnt <= 0;
                end else bcnt <= bcnt + 4'd1;
            end
        end
    end
endmodule
