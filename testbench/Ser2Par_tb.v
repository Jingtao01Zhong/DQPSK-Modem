`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/09 13:16:14
// Design Name: 
// Module Name: Ser2Par_tb
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


module Ser2Par_tb(

    );
    reg clk_data;
    reg rstn;
    reg in_data;
    wire data_valid;
    wire i_data,q_data;
    parameter clk_period_data = 2000;
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
      // generate the reset 
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end
    
    initial begin
        in_data = 1'b0;
        #(1.5*clk_period_data)
        in_data = 1'b1;
        #(clk_period_data)
        in_data = 1'b1;
        #(clk_period_data)
        in_data = 1'b0;
        #(clk_period_data)
        in_data = 1'b0;
        #(clk_period_data)
        in_data = 1'b1;
        #(clk_period_data)
        in_data = 1'b1;
    end
   
    SerToPar ser2par(
        .clk (clk_data),
        .rstn (rstn),
        .data_serial (in_data),
        .valid (data_valid),
        .i_data_parallel (i_data),
        .q_data_parallel (q_data)
    );
    
    reg [1:0] data_out;
    always @(*) begin
        data_out = {i_data,q_data};
    end
endmodule
