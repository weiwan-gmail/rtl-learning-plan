`timescale 1ns/1ps
module tb_sqrt16;
    reg clk, rst, start;
    reg [15:0] radicand;
    wire done;
    wire [7:0] root;
    wire [15:0] rem;
    integer errors, n, k, eq, er;

    sqrt16 dut (
        .clk(clk), .rst(rst), .start(start), .radicand(radicand),
        .done(done), .root(root), .rem(rem)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic run_one;
        input [15:0] x;
        integer rq, rr;
        begin
            // golden digit-by-digit
            begin : g
                integer rad, q, r, i, bits, acc, sub;
                rad=x; q=0; r=0;
                for (i=0;i<8;i=i+1) begin
                    bits = (rad >> 14) & 3;
                    acc = (r << 2) | bits;
                    sub = (q << 2) | 1;
                    if (acc >= sub) begin r = acc - sub; q = (q << 1) | 1; end
                    else begin r = acc; q = (q << 1); end
                    rad = (rad << 2) & 32'hFFFF;
                end
                rq=q; rr=r;
            end
            @(negedge clk); radicand=x; start=1;
            @(posedge clk); @(negedge clk); start=0;
            wait(done===1'b1); @(posedge clk); #1;
            if (root !== rq[7:0] || rem !== rr[15:0] || (root*root+rem) !== x) begin
                $display("FAIL x=%0d got root=%0d rem=%0d exp %0d/%0d", x, root, rem, rq, rr);
                errors=errors+1; $fatal(1,"sqrt");
            end
            n=n+1;
            @(negedge clk);
        end
    endtask

    initial begin
        errors=0; n=0; rst=1; start=0; radicand=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        run_one(0); run_one(1); run_one(4); run_one(9);
        run_one(15); run_one(16); run_one(255); run_one(256);
        run_one(1000); run_one(322); run_one(65535); run_one(65025);
        for (k=0;k<80;k=k+1) run_one((k*7919)&16'hFFFF);
        if (errors) $fatal(1,"err");
        $display("PASS sqrt16 n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
