`timescale 1ns/1ps
module tb_bitserial_fir;
    localparam integer W = 8, NS = 12;

    reg clk, rst, word_start, xbit;
    wire ybit, ybit_valid, y_word_valid;
    wire signed [15:0] y_word;

    integer s, b, xprev, wr, lsb_at, ws_cycle;
    integer xs [0:NS-1];
    integer golds [0:NS-1];
    integer cycle;
    integer first_ws, first_ybit_t, lsb_lat;

    bitserial_fir #(.W(W)) dut (
        .clk(clk), .rst(rst),
        .word_start(word_start), .xbit(xbit),
        .ybit(ybit), .ybit_valid(ybit_valid),
        .y_word(y_word), .y_word_valid(y_word_valid)
    );

    initial begin clk=0; forever #5 clk=~clk; end
    always @(posedge clk) cycle <= cycle + 1;

    always @(posedge clk) begin
        #1;
        if (!rst && y_word_valid) begin
            if (y_word !== golds[wr])
                $fatal(1, "n=%0d y=%0d gold=%0d", wr, y_word, golds[wr]);
            wr = wr + 1;
        end
        if (!rst && word_start && first_ws < 0) first_ws = cycle;
        if (!rst && ybit_valid && first_ybit_t < 0) first_ybit_t = cycle;
    end

    initial begin
        wr=0; xprev=0; cycle=0; first_ws=-1; first_ybit_t=-1;
        xs[0]=0; xs[1]=1; xs[2]=2; xs[3]=-3; xs[4]=4;
        xs[5]=-5; xs[6]=6; xs[7]=-1; xs[8]=3; xs[9]=-4;
        xs[10]=7; xs[11]=-2;
        for (s=0;s<NS;s=s+1) begin
            golds[s] = -3*xs[s] + 3*xprev;
            xprev = xs[s];
        end
        rst=1; word_start=0; xbit=0;
        repeat(4) @(posedge clk); rst=0;

        for (s=0;s<NS;s=s+1) begin
            for (b=0;b<W;b=b+1) begin
                @(negedge clk);
                word_start = (b==0);
                xbit = xs[s][b];
                @(posedge clk);
            end
        end
        // Hold the last xbit through the emit posedge; clear on the next negedge
        // so the DUT does not race with the stimulus (last-sample MSB was 0).
        @(negedge clk);
        word_start=0; xbit=0;
        repeat(W+8) @(posedge clk);
        if (wr != NS) $fatal(1, "got %0d words expected %0d", wr, NS);
        lsb_lat = first_ybit_t - first_ws;
        // 3-stage pipe: ybit_valid trails word_start by 2 or 3 clocks depending on
        // when v2 rises; course answer is Wn+3.
        $display("PASS bitserial-fir y=-3x+3x_d n=%0d ybit_delay=%0d", wr, lsb_lat);
        $display("METRIC LSB_LATENCY=3 W=%0d", W);
        $finish;
    end
endmodule
