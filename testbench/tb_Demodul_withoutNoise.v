`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/13 10:44:16
// Design Name: 
// Module Name: tb_Demodul_withoutNoise
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_Demodul_withoutNoise(
    output [34:0] i_data,
    output [34:0] q_data,
    output syn_out,
    output [1:0] input_data,
    output [1:0] diff_out,
    output [1:0] data_demodule_out,
    output [31:0] correct_num,
    output [31:0] error_num
    );

    reg rstn;
    reg [1:0] data_parallel;
    assign input_data = data_parallel;
    
    parameter clk_period_dds = 100;  // clock frequancy is 10MHz
    reg clk_dds;
    initial begin
        clk_dds = 0;
        forever
            #(clk_period_dds/2) clk_dds = ~ clk_dds;
    end
    
    // generate the clock for input data
    parameter clk_period_data = 10000; // 200Kbps £¨5000 for 1 bit£©
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
    parameter clk_period_test = 312; // clock for time syncronization
    reg clk_test;
    initial begin
        clk_test = 0;
        forever
            #(clk_period_test/2) clk_test = ~clk_test;
    end
    
   // generate the reset 
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end
    
    // test simulation
    reg [2:0] counter;
    initial begin
        data_parallel = 2'b00;
        counter = 3'b000;
        forever @(negedge clk_data) begin
            if(counter == 3'b000) begin
                data_parallel <= 2'b11;
                counter <= counter + 1;
            end
            else if(counter == 3'b001) begin
                data_parallel <= 2'b10;
                counter <= counter + 1;
            end
            else if(counter == 3'b010) begin
                data_parallel = 2'b01;
                counter <= counter + 1;
            end
            else if(counter == 3'b011) begin
                data_parallel = 2'b01;
                counter <= counter + 1;
            end
            else if(counter == 3'b100) begin
                data_parallel = 2'b00;
                counter <= counter + 1;
            end
            else if(counter == 3'b101) begin
                data_parallel = 2'b10;
                counter <= counter + 1;
            end
            else if(counter == 3'b110) begin
                data_parallel = 2'b11;
                counter <= counter + 1;
            end
            else if(counter == 3'b111) begin
                data_parallel = 2'b10;
                counter <= counter + 1;
            end
        end
    end
    
    wire [8:0] data_QPSK;
    //wire [1:0] parallel_data;
    wire data_valid;
    reg ready;
    always @(*) begin
        if(data_valid) begin
            ready = 1;
        end
        else begin
            ready = 0;
        end
    end
    
    Modul_QPSK u_111(
        .clk_dds (clk_dds),
        .clk_data (clk_data),
        .rstn (rstn),
        .in_data (input_data),
        .diff_out (diff_out),
        .data_modul_out (data_QPSK), 
        .data_valid (data_valid)
    );
    /*
    wire [8:0] noise, out_channel;
    powerLine_channel channel(
        .clk (clk_dds),
        .in_channel (data_QPSK),
        .noise (noise),
        .out_channel (out_channel)
    );
    */
    Demodul_QPSK u_222(
        .clk_dds (clk_dds),
        .clk_bitsync (clk_test),
        .rstn (ready),
        .data_modul_in (data_QPSK),
        .i_data (i_data),
        .q_data (q_data),
        .data_demodule_out (data_demodule_out),
        .syn_out (syn_out)
    );
    
    reg [2:0] counter_start;
    reg error_start;
    wire error_rstn;
    assign error_rstn = error_start;
    initial begin
        counter_start = 3'b000;
        error_start = 0;
    end
    always @(negedge syn_out) begin
        if(counter_start != 3'b010) begin
            counter_start <= counter_start + 1;
            error_start <= 0;
        end
        else begin
            error_start <= 1;
        end
    end
    
    error_counter error(
        .demodule_out (data_demodule_out),
        .clk (syn_out),
        .rstn (error_rstn),
        .error_num (error_num),
        .correct_num (correct_num)
    );
endmodule
