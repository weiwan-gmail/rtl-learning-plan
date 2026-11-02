`timescale 1ns/1ps
module tb_cordic_vector;
    reg clk, rst, start;
    reg signed [15:0] x_in, y_in, z_in;
    wire done;
    wire signed [15:0] x_out, y_out, z_out;
    integer errors, n_vec;

    function automatic signed [15:0] atan_lut;
        input integer i;
        case (i)
            0: atan_lut=16'sd6434; 1: atan_lut=16'sd3798;
            2: atan_lut=16'sd2007; 3: atan_lut=16'sd1019;
            4: atan_lut=16'sd511;  5: atan_lut=16'sd256;
            6: atan_lut=16'sd128;  7: atan_lut=16'sd64;
            8: atan_lut=16'sd32;   9: atan_lut=16'sd16;
            10: atan_lut=16'sd8;  11: atan_lut=16'sd4;
            12: atan_lut=16'sd2;  13: atan_lut=16'sd1;
            default: atan_lut=16'sd0;
        endcase
    endfunction

    task automatic golden;
        input signed [15:0] xin, yin, zin;
        output signed [15:0] xg, yg, zg;
        integer i;
        reg signed [15:0] x, y, z, xs, ys, at;
        begin
            x=xin; y=yin; z=zin;
            for (i=0;i<16;i=i+1) begin
                xs=x>>>i; ys=y>>>i; at=atan_lut(i);
                if (y[15]) begin x=x-ys; y=y+xs; z=z-at; end
                else begin x=x+ys; y=y-xs; z=z+at; end
            end
            xg=x; yg=y; zg=z;
        end
    endtask

    cordic_vector dut (
        .clk(clk), .rst(rst), .start(start),
        .x_in(x_in), .y_in(y_in), .z_in(z_in),
        .done(done), .x_out(x_out), .y_out(y_out), .z_out(z_out)
    );
    initial begin clk=0; forever #5 clk=~clk; end

    task automatic run_one;
        input signed [15:0] xin, yin, zin;
        reg signed [15:0] xg, yg, zg;
        begin
            golden(xin,yin,zin,xg,yg,zg);
            @(negedge clk); x_in=xin; y_in=yin; z_in=zin; start=1;
            @(posedge clk); @(negedge clk); start=0;
            wait(done===1'b1); @(posedge clk); #1;
            if (x_out!==xg || y_out!==yg || z_out!==zg) begin
                $display("FAIL got=(%0d,%0d,%0d) exp=(%0d,%0d,%0d)",
                         x_out,y_out,z_out,xg,yg,zg);
                errors=errors+1; $fatal(1,"bit-exact");
            end
            n_vec=n_vec+1; @(negedge clk);
        end
    endtask

    initial begin
        errors=0; n_vec=0; rst=1; start=0; x_in=0; y_in=0; z_in=0;
        repeat(4) @(posedge clk); rst=0; @(posedge clk);
        run_one(16'sd10000, 16'sd0, 16'sd0);
        run_one(16'sd8000, 16'sd8000, 16'sd0);
        run_one(16'sd8000, -16'sd8000, 16'sd0);
        run_one(16'sd5000, 16'sd3000, 16'sd0);
        run_one(16'sd1000, 16'sd2000, 16'sd100);
        run_one(-16'sd4000, 16'sd2000, 16'sd0); // note: quadrant via signs
        run_one(16'sd3000, -16'sd1000, -16'sd500);
        if (errors) $fatal(1,"err");
        $display("PASS cordic_vector n_vec=%0d mismatches=0", n_vec);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
