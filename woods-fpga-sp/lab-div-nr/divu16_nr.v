// divu16_restoring — unsigned 16÷16 restoring divider (Woods Ch3).
// File kept under lab-div-nr name; algorithm is classic restoring
// (non-restoring variant is noted in README as related).
// start→done: 16 iterations. den==0 → div_by_zero, quot=FFFF, rem=numer.
`timescale 1ns/1ps
module divu16_nr (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [15:0] numer,
    input  wire [15:0] denom,
    output reg         done,
    output reg         div_by_zero,
    output reg  [15:0] quot,
    output reg  [15:0] rem
);
    localparam S_IDLE = 1'b0, S_RUN = 1'b1;
    reg        state;
    reg [4:0]  i;
    reg [15:0] q;
    reg [15:0] r;
    reg [15:0] d;
    reg [15:0] nleft;

    wire [16:0] shifted = {r, nleft[15]};
    wire [16:0] sub     = shifted - {1'b0, d};
    wire        ge      = (shifted >= {1'b0, d});

    always @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE; done <= 0; div_by_zero <= 0;
            quot <= 0; rem <= 0; i <= 0; q <= 0; r <= 0; d <= 0; nleft <= 0;
        end else begin
            done <= 1'b0;
            if (state == S_IDLE) begin
                if (start) begin
                    if (denom == 16'd0) begin
                        quot <= 16'hFFFF; rem <= numer;
                        div_by_zero <= 1'b1; done <= 1'b1;
                    end else begin
                        div_by_zero <= 1'b0;
                        d <= denom; nleft <= numer; r <= 16'd0; q <= 16'd0;
                        i <= 5'd0; state <= S_RUN;
                    end
                end
            end else begin
                // one restoring iteration
                if (ge) begin
                    r <= sub[15:0];
                    q <= {q[14:0], 1'b1};
                end else begin
                    r <= shifted[15:0];
                    q <= {q[14:0], 1'b0};
                end
                nleft <= {nleft[14:0], 1'b0};
                if (i == 5'd15) begin
                    // final rem/quot already computed this cycle into r/q regs —
                    // need to capture AFTER update: use combo results for done
                    quot <= ge ? {q[14:0], 1'b1} : {q[14:0], 1'b0};
                    rem  <= ge ? sub[15:0] : shifted[15:0];
                    done <= 1'b1;
                    state <= S_IDLE;
                end else i <= i + 5'd1;
            end
        end
    end
endmodule
