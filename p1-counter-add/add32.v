// add32: 32-bit adder (unsigned + signed views of the same bits).
// - sum  = a + b (mod 2^32)
// - cout = unsigned carry out of bit 31
// - ovf  = signed two's-complement overflow (same-sign inputs, opposite-sign sum)
module add32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] sum,
    output wire        cout,
    output wire        ovf
);
    wire [32:0] ext;
    assign ext  = {1'b0, a} + {1'b0, b};
    assign sum  = ext[31:0];
    assign cout = ext[32];
    // signed overflow: MSB(a)==MSB(b) and MSB(sum)!=MSB(a)
    assign ovf  = (a[31] == b[31]) && (sum[31] != a[31]);
endmodule
