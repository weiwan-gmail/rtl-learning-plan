`timescale 1ns/1ps
// Self-checking TB for counter8: reset, enable stall, wrap FF->00.
module tb_counter8;
    reg        clk;
    reg        rst;
    reg        en;
    wire [7:0] q;

    integer cycle;
    integer errors;
    reg [7:0] expect_q;

    counter8 dut (
        .clk(clk),
        .rst(rst),
        .en (en),
        .q  (q)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100 MHz
    end

    task check;
        input [7:0] got;
        input [7:0] exp;
        input [8*48-1:0] tag;
        begin
            if (got !== exp) begin
                $display("FAIL [%0s] cycle=%0d got=%02h exp=%02h", tag, cycle, got, exp);
                errors = errors + 1;
                $fatal(1, "ASSERT %0s", tag);
            end
        end
    endtask

    initial begin
        errors   = 0;
        cycle    = 0;
        expect_q = 8'd0;
        rst      = 1'b1;
        en       = 1'b0;

        // hold reset a few cycles
        repeat (3) @(posedge clk);
        cycle = cycle + 3;
        @(negedge clk);
        check(q, 8'd0, "reset_hold");

        // deassert reset, still disabled
        rst = 1'b0;
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'd0, "en_low_stall");

        // enable and count 0..254
        en = 1'b1;
        expect_q = 8'd0;
        while (expect_q < 8'd255) begin
            @(posedge clk); cycle = cycle + 1;
            expect_q = expect_q + 8'd1;
            @(negedge clk);
            check(q, expect_q, "count_up");
        end
        // now q must be 255
        check(q, 8'hFF, "pre_wrap");

        // next rising edge: wrap FF -> 00
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'h00, "wrap_ff_to_00");

        // a few more after wrap
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'h01, "post_wrap_1");
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'h02, "post_wrap_2");

        // disable: must freeze
        en = 1'b0;
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'h02, "en_freeze");

        // sync reset mid-count
        rst = 1'b1;
        @(posedge clk); cycle = cycle + 1;
        @(negedge clk);
        check(q, 8'h00, "sync_rst");

        if (errors == 0)
            $display("PASS tb_counter8 cycles=%0d errors=0", cycle);
        else
            $fatal(1, "tb_counter8 FAILED errors=%0d", errors);
        $finish;
    end

    // safety timeout
    initial begin
        #100000;
        $fatal(1, "TIMEOUT tb_counter8");
    end
endmodule
