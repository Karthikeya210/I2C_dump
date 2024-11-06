`timescale 1ns / 1ps

module tb_convolution;

    parameter DATA_WIDTH = 16;
    parameter ACCUM_WIDTH = 32;

    reg clk;
    reg rst;
    reg signed [DATA_WIDTH-1:0] x_in;
    wire signed [ACCUM_WIDTH-1:0] y_out;
    wire signed [ACCUM_WIDTH-1:0] y_out_t;
    integer i;
    real sine_val;
        
    convolution uut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out),
        .y_out_t(y_out_t)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        x_in = 0;

        #10 rst = 0;


        for (i = 0; i < 100; i = i + 1) begin
            sine_val = $sin(2 * 3.14159 * i / 20); 
            x_in = $rtoi(sine_val * 32767);        
            #10;
        end
        
        x_in = 16'hFFFF;

        #500 $finish;
    end

    initial begin
        $dumpfile("my_designf.vcd");
        $dumpvars(0, tb_convolution);
    end

endmodule

