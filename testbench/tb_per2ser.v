`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/16 10:46:52
// Design Name: 
// Module Name: tb_per2ser
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


module tb_per2ser(
    );
    
    parameter clk_period_data = 5000; // 200Kbps £¨5000£©
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
    // generate the reset 
    reg rstn;
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end
    
    reg [1:0] data_par;
    initial begin
        data_par = 2'b00;
        
        #(clk_period_data)
        data_par = 2'b10; 
        #(clk_period_data)
        data_par = 2'b10;
        #(clk_period_data)
        data_par = 2'b11;
        #(clk_period_data)
        data_par = 2'b01;
        #(clk_period_data)
        data_par = 2'b10;
        #(clk_period_data)
        data_par = 2'b00;
        #(clk_period_data)
        data_par = 2'b11;
    end
    
    wire [1:0] par;
    assign par = data_par;
    wire data_ser, par2ser_valid;
    Par2Ser tb_Par2Ser(
        .clk_in (clk_data),
        .rstn (rstn),
        .data_par (par),
        .data_ser (data_ser),
        .par2ser_valid (par2ser_valid)
    );
endmodule
