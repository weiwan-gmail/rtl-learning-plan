`timescale 1ns/1ps
module tb_rns35;
    reg clk, rst, in_valid;
    reg [1:0] op;
    reg [5:0] bin_a, bin_b;
    reg [2:0] a5, a7, b5, b7;
    wire out_valid;
    wire [2:0] r5, r7;
    wire [5:0] bin_out;
    integer errors, n, i, j;
    reg [2:0] sa5, sa7, sb5, sb7;

    rns35 dut (
        .clk(clk), .rst(rst), .in_valid(in_valid), .op(op),
        .bin_a(bin_a), .bin_b(bin_b),
        .a5(a5), .a7(a7), .b5(b5), .b7(b7),
        .out_valid(out_valid), .r5(r5), .r7(r7), .bin_out(bin_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic do_op;
        input [1:0] o;
        input [5:0] ba, bb;
        input [2:0] xa5, xa7, xb5, xb7;
        begin
            @(negedge clk);
            op=o; bin_a=ba; bin_b=bb; a5=xa5; a7=xa7; b5=xb5; b7=xb7;
            in_valid=1;
            @(posedge clk); #1;
            if (!out_valid) begin errors=errors+1; $fatal(1,"nov"); end
            n=n+1;
            @(negedge clk); in_valid=0;
        end
    endtask

    initial begin
        errors=0; n=0; rst=1; in_valid=0;
        op=0; bin_a=0; bin_b=0; a5=0;a7=0;b5=0;b7=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);

        // encode + CRT roundtrip
        for (i=0; i<35; i=i+1) begin
            do_op(2'd0, i[5:0], 0, 0,0,0,0);
            if (r5 !== (i % 5) || r7 !== (i % 7)) begin
                $display("FAIL enc %0d got %0d,%0d", i, r5, r7);
                $fatal(1,"enc");
            end
            sa5=r5; sa7=r7;
            do_op(2'd3, 0, 0, sa5, sa7, 0, 0);
            if (bin_out !== i[5:0]) begin
                $display("FAIL crt %0d got %0d", i, bin_out);
                $fatal(1,"crt");
            end
        end

        // add / mul vs integer mod 35
        for (i=0; i<35; i=i+3) begin
            for (j=0; j<35; j=j+5) begin
                do_op(2'd0, i[5:0], 0, 0,0,0,0); sa5=r5; sa7=r7;
                do_op(2'd0, j[5:0], 0, 0,0,0,0); sb5=r5; sb7=r7;
                do_op(2'd1, 0, 0, sa5, sa7, sb5, sb7);
                if (r5 !== ((i+j)%5) || r7 !== ((i+j)%7)) $fatal(1,"add");
                do_op(2'd3, 0, 0, r5, r7, 0, 0);
                if (bin_out !== ((i+j)%35)) begin
                    $display("FAIL add crt %0d+%0d got %0d", i, j, bin_out);
                    $fatal(1,"addcrt");
                end
                do_op(2'd2, 0, 0, sa5, sa7, sb5, sb7);
                if (r5 !== ((i*j)%5) || r7 !== ((i*j)%7)) $fatal(1,"mul");
                do_op(2'd3, 0, 0, r5, r7, 0, 0);
                if (bin_out !== ((i*j)%35)) begin
                    $display("FAIL mul crt %0d*%0d got %0d exp %0d", i,j,bin_out,(i*j)%35);
                    $fatal(1,"mulcrt");
                end
            end
        end

        if (errors) $fatal(1,"err");
        $display("PASS rns35 n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999 M=35");
        $finish;
    end
endmodule
