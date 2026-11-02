// rns35 — Residue Number System add/mul mod (5,7) (Woods Ch3 §LNS/RNS).
// Dynamic range M=35. Operates on residue pairs (a5,a7), (b5,b7).
//   add: ((a5+b5)%5, (a7+b7)%7)
//   mul: ((a5*b5)%5, (a7*b7)%7)
// Also binary→RNS encoder and CRT decoder for 0..34.
`timescale 1ns/1ps
module rns35 (
    input  wire       clk,
    input  wire       rst,
    input  wire       in_valid,
    input  wire [1:0] op,       // 0:enc 1:add 2:mul 3:crt
    input  wire [5:0] bin_a,    // 0..34 for enc / CRT channel A packed later
    input  wire [5:0] bin_b,
    // For add/mul: residues packed in bin_a/bin_b as {2'b0,r5[2:0],r7[2:0]} wait — use explicit:
    input  wire [2:0] a5, a7, b5, b7,
    output reg        out_valid,
    output reg  [2:0] r5, r7,
    output reg  [5:0] bin_out
);
    // mod 5 / mod 7 via subtract loops (tiny, combo)
    function automatic [2:0] mod5;
        input [5:0] v;
        reg [5:0] t;
        begin
            t = v;
            if (t >= 30) t = t - 30;
            if (t >= 15) t = t - 15;
            if (t >= 10) t = t - 10;
            if (t >= 5)  t = t - 5;
            mod5 = t[2:0];
        end
    endfunction
    function automatic [2:0] mod7;
        input [6:0] v;
        reg [6:0] t;
        begin
            t = v;
            if (t >= 28) t = t - 28;
            if (t >= 14) t = t - 14;
            if (t >= 7)  t = t - 7;
            mod7 = t[2:0];
        end
    endfunction

    // CRT: x = sum r_i * M_i * y_i mod M, M=35
    // M1=M/5=7, y1=7^{-1} mod 5=3 (since 21≡1 mod 5)
    // M2=M/7=5, y2=5^{-1} mod 7=3 (since 15≡1 mod 7)
    // x = (r5*7*3 + r7*5*3) mod 35 = (21*r5 + 15*r7) mod 35
    function automatic [5:0] crt;
        input [2:0] s5, s7;
        reg [9:0] acc;
        begin
            acc = s5 * 21 + s7 * 15; // 21*s5+15*s7, max 21*4+15*6=174
            if (acc >= 175) acc = acc - 175;
            if (acc >= 140) acc = acc - 140;
            if (acc >= 105) acc = acc - 105;
            if (acc >= 70)  acc = acc - 70;
            if (acc >= 35)  acc = acc - 35;
            crt = acc[5:0];
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            out_valid <= 0; r5 <= 0; r7 <= 0; bin_out <= 0;
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                out_valid <= 1'b1;
                case (op)
                    2'd0: begin // encode bin_a
                        r5 <= mod5(bin_a);
                        r7 <= mod7({1'b0, bin_a});
                        bin_out <= bin_a;
                    end
                    2'd1: begin // add
                        r5 <= mod5({3'b0, a5} + {3'b0, b5});
                        r7 <= mod7({4'b0, a7} + {4'b0, b7});
                        bin_out <= 0;
                    end
                    2'd2: begin // mul
                        r5 <= mod5(a5 * b5); // 3x3 fits mod5's [5:0]
                        r7 <= mod7({1'b0, a7} * {1'b0, b7}); // widen before mod7
                        bin_out <= 0;
                    end
                    default: begin // CRT decode from a5,a7
                        r5 <= a5; r7 <= a7;
                        bin_out <= crt(a5, a7);
                    end
                endcase
            end
        end
    end
endmodule
