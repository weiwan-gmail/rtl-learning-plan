`timescale 1ns/1ps
module tb_fir_2par;
    reg clk, rst, in_s, in_p;
    reg signed [15:0] din, xe, xo;
    wire ov_s, ov_p;
    wire signed [31:0] ys, ye, yo;
    integer k, n, hx0, hx1, hx2, hx3, exp;
    integer serial_q [0:255], wr, rd;

    fir_serial u_s (.clk(clk),.rst(rst),.in_valid(in_s),.din(din),.out_valid(ov_s),.dout(ys));
    fir_2par   u_p (.clk(clk),.rst(rst),.in_valid(in_p),.xe(xe),.xo(xo),.out_valid(ov_p),.ye(ye),.yo(yo));

    initial begin clk=0; forever #5 clk=~clk; end

    task automatic step_serial;
        input signed [15:0] s;
        begin
            hx3=hx2; hx2=hx1; hx1=hx0; hx0=s;
            exp = 1*hx0 + 2*hx1 + 2*hx2 + 1*hx3;
            serial_q[wr]=exp; wr=wr+1;
            @(negedge clk); din=s; in_s=1; in_p=0;
            @(posedge clk); #1;
            if (!ov_s || ys !== exp) $fatal(1, "serial mismatch");
            n=n+1;
            @(negedge clk); in_s=0;
        end
    endtask

    initial begin
        n=0; wr=0; rd=0; hx0=0; hx1=0; hx2=0; hx3=0;
        rst=1; in_s=0; in_p=0; din=0; xe=0; xo=0;
        repeat(3) @(posedge clk); rst=0; @(posedge clk);

        // build a serial golden stream of 32 samples
        for (k=0;k<32;k=k+1) step_serial(k-16);
        // reset delay lines by re-simulating 2-par from the same sequence
        rst=1; repeat(2) @(posedge clk); rst=0; @(posedge clk);
        begin : par
            integer i;
            integer seq [0:31];
            integer gx0,gx1,gx2,gx3, ge, go;
            for (i=0;i<32;i=i+1) seq[i]=i-16;
            gx0=0; gx1=0; gx2=0; gx3=0;
            // walk serial state in lockstep with 2-par (pairs)
            for (i=0;i<32;i=i+2) begin
                xe = seq[i];
                xo = seq[i+1];
                @(negedge clk); in_p=1; in_s=0;
                @(posedge clk); #1;
                if (!ov_p) $fatal(1, "2par no out");
                // golden even/odd from running 4-tap
                gx3=gx2; gx2=gx1; gx1=gx0; gx0=seq[i];
                ge = 1*gx0+2*gx1+2*gx2+1*gx3;
                gx3=gx2; gx2=gx1; gx1=gx0; gx0=seq[i+1];
                go = 1*gx0+2*gx1+2*gx2+1*gx3;
                if (ye !== ge || yo !== go)
                    $fatal(1, "2par i=%0d ye=%0d/%0d yo=%0d/%0d", i, ye, ge, yo, go);
                @(negedge clk); in_p=0;
            end
        end
        $display("PASS fir-2par serial vs even/odd polyphase bit-exact n_serial=%0d", n);
        $display("METRIC PARALLEL=2 SAME_BITEXACT=1");
        $finish;
    end
endmodule
