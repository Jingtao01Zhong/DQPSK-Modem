`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/25 14:40:01
// Design Name: 
// Module Name: diff_encode
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


module diff_encode(
    input rstn,
    input clk,
    input [1:0] in_data,
    output [1:0] out_data,
    output valid_diff_encode
    );
    reg [1:0] result;
    reg valid;
    assign out_data = result;
    assign valid_diff_encode = valid;
    
    always @(posedge clk) begin
        if(!rstn) begin
            result <= 2'b00;
            valid <= 0;
        end
        else begin
            valid <= 1;
            // when in_data == 2'b10, phase change is 315
            if((in_data == 2'b10) && (result == 2'b00)) 
                result <= 2'b10;
            else if((in_data == 2'b10) && (result == 2'b10))
                result <= 2'b11;
            else if((in_data == 2'b10) && (result == 2'b11))
                result <= 2'b01;
            else if((in_data == 2'b10) && (result == 2'b01))
                result <= 2'b00;
            
            // whne in_data == 2'b11, phase change is 45
            else if((in_data == 2'b11) && (result == 2'b00))
                result <= 2'b11;
            else if((in_data == 2'b11) && (result == 2'b10))
                result <= 2'b01;
            else if((in_data == 2'b11) && (result == 2'b11))
                result <= 2'b00;
            else if((in_data == 2'b11) && (result == 2'b01))
                result <= 2'b10;
            
            // when in_data == 2'b01, phase change is 135
            else if((in_data == 2'b01) && (result == 2'b00))
                result <= 2'b01;
            else if((in_data == 2'b01) && (result == 2'b10))
                result <= 2'b00;
            else if((in_data == 2'b01) && (result == 2'b11))
                result <= 2'b10;
            else if((in_data == 2'b01) && (result == 2'b01))
                result <= 2'b11;
            
            // when in_data == 2'b00, phase change is 225
            else if((in_data == 2'b00) && (result == 2'b00))
                result <= 2'b00;
            else if((in_data == 2'b00) && (result == 2'b10))
                result <= 2'b10;
            else if((in_data == 2'b00) && (result == 2'b11))
                result <= 2'b11;
            else if((in_data == 2'b00) && (result == 2'b01))
                result <= 2'b01;
        end
    end
endmodule
