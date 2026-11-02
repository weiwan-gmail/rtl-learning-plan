`timescale 1ns/1ps
module tb_divu16;
    reg clk, rst, start;
    reg [15:0] numer, denom;
    wire done, div_by_zero;
    wire [15:0] quot, rem;
    integer errors, n, a, b;

    divu16_nr dut (
        .clk(clk), .rst(rst), .start(start),
        .numer(numer), .denom(denom),
        .done(done), .div_by_zero(div_by_zero),
        .quot(quot), .rem(rem)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic run_div;
        input [15:0] nn, dd;
        reg [15:0] eq, er;
        begin
            eq = nn / dd; er = nn % dd;
            @(negedge clk); numer=nn; denom=dd; start=1;
            @(posedge clk); @(negedge clk); start=0;
            wait(done===1'b1); @(posedge clk); #1;
            if (div_by_zero || quot !== eq || rem !== er) begin
                $display("FAIL %0d/%0d got q=%0d r=%0d dz=%0d exp q=%0d r=%0d",
                         nn, dd, quot, rem, div_by_zero, eq, er);
                errors=errors+1; $fatal(1,"div");
            end
            n=n+1;
            @(negedge clk);
        end
    endtask

    initial begin
        errors=0; n=0; rst=1; start=0; numer=0; denom=1;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);
        // div by zero
        @(negedge clk); numer=16'd42; denom=16'd0; start=1;
        @(posedge clk); @(negedge clk); start=0;
        wait(done===1'b1); @(posedge clk); #1;
        if (!div_by_zero || quot !== 16'hFFFF || rem !== 16'd42) $fatal(1,"dz");
        n=n+1; @(negedge clk);

        run_div(16'd0, 16'd1);
        run_div(16'd1, 16'd1);
        run_div(16'd100, 16'd7);
        run_div(16'd65535, 16'd255);
        run_div(16'd65535, 16'd1);
        run_div(16'd256, 16'd16);
        run_div(16'd12345, 16'd678);
        for (a=1;a<40;a=a+1)
            for (b=1;b<20;b=b+1)
                run_div((a*97+b)&16'hFFFF, b);
        if (errors) $fatal(1,"err");
        $display("PASS divu16_restoring n=%0d mismatches=0", n);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
