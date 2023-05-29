`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/14 21:52:50
// Design Name: 
// Module Name: Par2Ser
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


module Par2Ser(
    input clk_in,
    input rstn,
    input [1:0] data_par,
    output reg data_ser,
    output reg par2ser_valid
    );
    reg data_ser_reg;
    reg data_ser_nxt;
    always @(posedge clk_in) begin
        if(!rstn) begin
            par2ser_valid = 0;
        end
        else begin
            data_ser_reg <= data_par[1];
            data_ser_nxt <= data_par[0];
            par2ser_valid <= 1;
        end
    end
    /*
    always @(negedge clk_in) begin
        data_ser_reg <= data_ser_nxt;
    end
    */
    always @(*) begin
        if(clk_in) begin
            data_ser = data_ser_reg;
        end
        else begin
            data_ser = data_ser_nxt;
        end
    end
    //assign data_ser = data_ser_reg;
endmodule
