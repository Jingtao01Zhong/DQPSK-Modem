`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/01 14:46:10
// Design Name: 
// Module Name: TestForModulator
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


module TestForModulator(
    output [1:0] in_data,
    output [8:0] data_out,
    output [1:0] diff_out,
    output data_valid
    //output [15:0] add_out,
    //output [7:0] sin_out,
    //output [7:0] cos_out
    );
   
    reg rstn;
    reg [1:0] data_parallel;
    assign in_data = data_parallel;
    
    parameter clk_period_dds = 100;  // clock frequancy is 10MHz
    reg clk_dds;
    initial begin
        clk_dds = 0;
        forever
            #(clk_period_dds/2) clk_dds = ~ clk_dds;
    end
    
    // generate the clock for input data
    parameter clk_period_data = 5000; // 200Kbps
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
   // generate the reset 
    initial begin
        rstn = 1'b0;
        #(2*clk_period_data)
        rstn = 1'b1; 
    end
    
    // test simulation
    initial begin
        data_parallel = 2'b00;
        
        #(2*clk_period_data)
        data_parallel = 2'b11;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b11;
        #(clk_period_data)
        data_parallel = 2'b01;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b11;
        #(clk_period_data)
        data_parallel = 2'b00;
        #(clk_period_data)
        data_parallel = 2'b01;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b11;
        #(clk_period_data)
        data_parallel = 2'b01;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b00;
        #(clk_period_data)
        data_parallel = 2'b10;
        #(clk_period_data)
        data_parallel = 2'b11;
        #(clk_period_data)
        data_parallel = 2'b01;
    end
    
    Modul_QPSK u1(
        .clk_dds (clk_dds),
        .clk_data (clk_data),
        .rstn (rstn),
        .in_data (in_data),
        .diff_out (diff_out),
        .data_modul_out (data_out),
        .data_valid (data_valid)
    );
  
endmodule
