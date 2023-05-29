`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/07 16:19:24
// Design Name: 
// Module Name: tb_diffcode
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


module tb_diffcode(

    );
    parameter clk_period_data = 5000; // 200Kbps £¨5000£©
    reg clk;
    initial begin
        clk = 0;
        forever
            #(clk_period_data/2) clk = ~ clk;
    end
    
    reg rstn;
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end

    reg [1:0] data;
    wire [1:0] in_data, out_encode, out_decode;
    wire valid_encode;
    assign in_data = data;
    
    initial begin
        data = 2'b00;
        
        #(clk_period_data)
        data = 2'b01;
        #(clk_period_data)
        data = 2'b11;
        #(clk_period_data)
        data = 2'b10;
        #(clk_period_data)
        data = 2'b01;
        #(clk_period_data)
        data = 2'b00;
        #(clk_period_data)
        data = 2'b10;
    end
    diff_encode tb_encoder(
        .rstn (rstn),
        .clk (clk),
        .in_data (in_data),
        .out_data (out_encode),
        .valid_diff_encode (valid_encode)
    );
    
    diff_decode tb_decoder(
        .rstn (valid_encode),
        .clk (clk),
        .in_code (out_encode),
        .out_code (out_decode)
    );
endmodule
