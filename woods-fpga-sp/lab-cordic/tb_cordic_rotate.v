`timescale 1ns/1ps
// Bit-exact TB vs integer golden matching cordic_rotate.v
module tb_cordic_rotate;
    reg clk, rst, start;
    reg  signed [15:0] x_in, y_in, z_in;
    wire done;
    wire signed [15:0] x_out, y_out, z_out;

    integer errors, n_vec;

    // same atan table
    function automatic signed [15:0] atan_lut;
        input integer i;
        begin
            case (i)
                0: atan_lut = 16'sd6434; 1: atan_lut = 16'sd3798;
                2: atan_lut = 16'sd2007; 3: atan_lut = 16'sd1019;
                4: atan_lut = 16'sd511;  5: atan_lut = 16'sd256;
                6: atan_lut = 16'sd128;  7: atan_lut = 16'sd64;
                8: atan_lut = 16'sd32;   9: atan_lut = 16'sd16;
                10: atan_lut = 16'sd8;  11: atan_lut = 16'sd4;
                12: atan_lut = 16'sd2;  13: atan_lut = 16'sd1;
                default: atan_lut = 16'sd0;
            endcase
        end
    endfunction

    task automatic golden;
        input  signed [15:0] xin, yin, zin;
        output signed [15:0] xg, yg, zg;
        integer i;
        reg signed [15:0] x, y, z, xs, ys, at;
        begin
            x = xin; y = yin; z = zin;
            for (i = 0; i < 16; i = i + 1) begin
                xs = x >>> i;
                ys = y >>> i;
                at = atan_lut(i);
                if (z[15]) begin
                    x = x + ys; y = y - xs; z = z + at;
                end else begin
                    x = x - ys; y = y + xs; z = z - at;
                end
            end
            xg = x; yg = y; zg = z;
        end
    endtask

    cordic_rotate dut (
        .clk(clk), .rst(rst), .start(start),
        .x_in(x_in), .y_in(y_in), .z_in(z_in),
        .done(done), .x_out(x_out), .y_out(y_out), .z_out(z_out)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    task automatic run_one;
        input signed [15:0] xin, yin, zin;
        reg signed [15:0] xg, yg, zg;
        begin
            golden(xin, yin, zin, xg, yg, zg);
            @(negedge clk);
            x_in = xin; y_in = yin; z_in = zin; start = 1'b1;
            @(posedge clk);
            @(negedge clk); start = 1'b0;
            wait (done === 1'b1);
            @(posedge clk); // sample outputs after done edge
            #1;
            if (x_out !== xg || y_out !== yg || z_out !== zg) begin
                $display("FAIL vec=%0d got=(%0d,%0d,%0d) exp=(%0d,%0d,%0d)",
                         n_vec, x_out, y_out, z_out, xg, yg, zg);
                errors = errors + 1;
                $fatal(1, "bit-exact");
            end
            n_vec = n_vec + 1;
            // drain done
            @(negedge clk);
        end
    endtask

    initial begin
        errors = 0; n_vec = 0;
        rst = 1; start = 0; x_in = 0; y_in = 0; z_in = 0;
        repeat (4) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // cos/sin style: x=Kinv*gain scale, y=0, z=angle → approx (cos,sin)*gain
        // Use x=9949 ≈ 0.607253 * 16384 (Q1.14 unit), y=0
        run_one(16'sd9949, 16'sd0, 16'sd0);          // angle 0
        run_one(16'sd9949, 16'sd0, 16'sd6434);       // ~pi/4
        run_one(16'sd9949, 16'sd0, -16'sd6434);      // -pi/4
        run_one(16'sd9949, 16'sd0, 16'sd3217);       // ~pi/8
        run_one(16'sd4000, 16'sd3000, 16'sd1000);    // general rotate
        run_one(-16'sd2000, 16'sd1500, -16'sd2000);
        run_one(16'sd100, 16'sd0, 16'sd100);
        run_one(16'sd8000, -16'sd1000, 16'sd500);

        if (errors != 0) $fatal(1, "errors");
        $display("PASS cordic_rotate n_vec=%0d mismatches=0", n_vec);
        $display("METRIC RMSE=0 SNR_dB=999");
        $finish;
    end
endmodule
