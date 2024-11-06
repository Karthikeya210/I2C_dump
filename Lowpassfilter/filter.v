module convolution (
    input clk,              
    input rst,              
    input signed [15:0] x_in,           
    output reg signed [31:0] y_out ,
    output reg signed [31:0] y_out_t 
);

    parameter FILTER_LENGTH = 39; 

    reg signed [15:0] x_buffer [0:FILTER_LENGTH-1];
    reg signed [15:0] h_lut [0:FILTER_LENGTH-1];  
    reg signed [63:0] accumulator;
         
    integer i;

    initial begin // Updated LUT
        h_lut[0] = 16'h01B; 
        h_lut[1] = 16'h023;
        h_lut[2] = 16'h033; 
        h_lut[3] = 16'h04C;
        h_lut[4] = 16'h072; 
        h_lut[5] = 16'h0A4;
        h_lut[6] = 16'h0E5; 
        h_lut[7] = 16'h135;
        h_lut[8] = 16'h191; 
        h_lut[9] = 16'h1FA;
        h_lut[10] = 16'h26B; 
        h_lut[11] = 16'h2E1;
        h_lut[12] = 16'h359; 
        h_lut[13] = 16'h3CD;
        h_lut[14] = 16'h439; 
        h_lut[15] = 16'h499;
        h_lut[16] = 16'h4E9; 
        h_lut[17] = 16'h524;
        h_lut[18] = 16'h549; 
        h_lut[19] = 16'h555;
        h_lut[20] = 16'h549; 
        h_lut[21] = 16'h524; 
        h_lut[22] = 16'h4E9;
        h_lut[23] = 16'h499; 
        h_lut[24] = 16'h439;
        h_lut[25] = 16'h3CD; 
        h_lut[26] = 16'h359;
        h_lut[27] = 16'h2E1; 
        h_lut[28] = 16'h26B;
        h_lut[29] = 16'h1FA; 
        h_lut[30] = 16'h191;
        h_lut[31] = 16'h135; 
        h_lut[32] = 16'h0E5;
        h_lut[33] = 16'h0A4; 
        h_lut[34] = 16'h072;
        h_lut[35] = 16'h04C; 
        h_lut[36] = 16'h033;
        h_lut[37] = 16'h023;
        h_lut[38] = 16'h01B;
    end

    always @(posedge clk, posedge rst) begin
        if (rst == 1) begin
            y_out <= 0;
            for (i = 0; i < FILTER_LENGTH; i = i + 1) begin
                x_buffer[i] <= 0;
            end
        end else begin
            if (x_in != 16'hFFFF) begin
                for (i = FILTER_LENGTH-1; i > 0; i = i - 1) begin
                    x_buffer[i] <= x_buffer[i-1];
                end
                x_buffer[0] <= x_in; 
                if (x_buffer[0][15] == 1) begin
                	x_buffer[0] = ~x_buffer[0] + 1;
                end
                y_out_t <= x_buffer[0];
            end else begin
                for (i = FILTER_LENGTH-1; i > 0; i = i - 1) begin
                    x_buffer[i] <= x_buffer[i-1];
                end
                x_buffer[0] <= 16'h0000;       
            end      	

            accumulator = 0;
            for (i = 0; i < FILTER_LENGTH; i = i + 1) begin
                accumulator = accumulator + (x_buffer[i] * h_lut[i]);
            end

            y_out <= accumulator[31:0];
        end
    end

endmodule

