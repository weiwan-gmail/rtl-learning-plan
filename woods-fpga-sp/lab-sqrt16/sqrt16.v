// sqrt16 — unsigned digit-by-digit restoring square root (Woods Ch3).
// radicand[15:0] → root[7:0]; rem = radicand - root^2.
// 8 iterations after start.
`timescale 1ns/1ps
module sqrt16 (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [15:0] radicand,
    output reg         done,
    output reg  [7:0]  root,
    output reg  [15:0] rem
);
    localparam S_IDLE = 1'b0, S_RUN = 1'b1;
    reg        state;
    reg [3:0]  i;
    reg [15:0] rad;
    reg [7:0]  q;
    reg [15:0] r;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; done <= 0; root <= 0; rem <= 0;
            i <= 0; rad <= 0; q <= 0; r <= 0;
        end else begin
            done <= 1'b0;
            if (state == S_IDLE) begin
                if (start) begin
                    rad <= radicand; q <= 8'd0; r <= 16'd0; i <= 4'd0;
                    state <= S_RUN;
                end
            end else begin
                begin : step
                    reg [17:0] acc, subtrahend, diff;
                    reg [7:0]  qn;
                    acc = {r, rad[15:14]};
                    subtrahend = {6'b0, q, 2'b01}; // (q<<2)|1
                    if (acc >= subtrahend) begin
                        diff = acc - subtrahend;
                        qn = {q[6:0], 1'b1};
                    end else begin
                        diff = acc;
                        qn = {q[6:0], 1'b0};
                    end
                    r <= diff[15:0];
                    q <= qn;
                    rad <= {rad[13:0], 2'b00};
                    if (i == 4'd7) begin
                        root <= qn;
                        rem <= diff[15:0];
                        done <= 1'b1;
                        state <= S_IDLE;
                    end else i <= i + 4'd1;
                end
            end
        end
    end
endmodule
