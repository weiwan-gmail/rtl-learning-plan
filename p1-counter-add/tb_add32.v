`timescale 1ns/1ps
// Self-checking TB for add32: directed edges + random; cout/ovf checked.
module tb_add32;
    reg  [31:0] a, b;
    wire [31:0] sum;
    wire        cout, ovf;

    integer i;
    integer errors;
    reg [32:0] ref_ext;
    reg [31:0] ref_sum;
    reg        ref_cout;
    reg        ref_ovf;
    reg signed [31:0] sa, sb, ssum;

    add32 dut (
        .a   (a),
        .b   (b),
        .sum (sum),
        .cout(cout),
        .ovf (ovf)
    );

    task check_one;
        input [31:0] ta, tb;
        input [8*40-1:0] tag;
        begin
            a = ta;
            b = tb;
            #1;
            ref_ext  = {1'b0, ta} + {1'b0, tb};
            ref_sum  = ref_ext[31:0];
            ref_cout = ref_ext[32];
            sa   = ta;
            sb   = tb;
            ssum = ref_sum;
            ref_ovf = (sa[31] == sb[31]) && (ssum[31] != sa[31]);

            if (sum !== ref_sum) begin
                $display("FAIL sum [%0s] a=%h b=%h got=%h exp=%h", tag, ta, tb, sum, ref_sum);
                errors = errors + 1;
                $fatal(1, "ASSERT sum_%0s", tag);
            end
            if (cout !== ref_cout) begin
                $display("FAIL cout [%0s] a=%h b=%h got=%b exp=%b", tag, ta, tb, cout, ref_cout);
                errors = errors + 1;
                $fatal(1, "ASSERT cout_%0s", tag);
            end
            if (ovf !== ref_ovf) begin
                $display("FAIL ovf [%0s] a=%h b=%h got=%b exp=%b", tag, ta, tb, ovf, ref_ovf);
                errors = errors + 1;
                $fatal(1, "ASSERT ovf_%0s", tag);
            end
        end
    endtask

    initial begin
        errors = 0;

        // directed edges
        check_one(32'h0000_0000, 32'h0000_0000, "zero_zero");
        check_one(32'h0000_0001, 32'h0000_0001, "one_one");
        check_one(32'hFFFF_FFFF, 32'h0000_0001, "max_plus_1");      // cout=1, sum=0
        check_one(32'hFFFF_FFFF, 32'hFFFF_FFFF, "max_plus_max");    // cout=1
        check_one(32'h7FFF_FFFF, 32'h0000_0001, "signed_pos_ovf");  // ovf=1
        check_one(32'h8000_0000, 32'hFFFF_FFFF, "signed_neg_ovf");  // ovf=1 (MIN + -1)
        check_one(32'h7FFF_FFFF, 32'h7FFF_FFFF, "pos_pos_ovf");
        check_one(32'h8000_0000, 32'h8000_0000, "neg_neg_ovf");
        check_one(32'h0000_0005, 32'hFFFF_FFFB, "five_plus_m5");    // 5 + (-5) = 0
        check_one(32'h1234_5678, 32'h1111_1111, "mid_pattern");

        // random coverage
        for (i = 0; i < 2000; i = i + 1) begin
            check_one($random, $random, "rand");
        end

        if (errors == 0)
            $display("PASS tb_add32 directed=10 random=2000 errors=0");
        else
            $fatal(1, "tb_add32 FAILED errors=%0d", errors);
        $finish;
    end
endmodule
