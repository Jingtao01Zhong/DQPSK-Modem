`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/07 15:44:42
// Design Name: 
// Module Name: diff_decode
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


module diff_decode(
    input rstn,
    input clk,
    input [1:0] in_code,
    output [1:0] out_code
    );
    
    reg [1:0] result, num;
    always @(posedge clk or posedge rstn) begin
        if(!rstn) begin
            num <= 2'b00;
        end
        else begin
            num <= in_code;
            if(num[0] != num[1]) begin
                result[0] <= in_code[1] ^ num[1];
                result[1] <= in_code[0] ^ num[0];
            end
            else begin
                result[1] <= in_code[1] ^ num[1];
                result[0] <= in_code[0] ^ num[0];
            end 
        end
    end
    assign out_code = result;
endmodule
