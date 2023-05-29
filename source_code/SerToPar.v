`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/28 15:03:19
// Design Name: 
// Module Name: SerToPar
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


module SerToPar(
    input clk,
    input rstn,
    input data_serial,
    output reg valid,
    output reg i_data_parallel,
    output reg q_data_parallel
    );
    reg flag;
    reg i_data_nxt;
    /*
    initial begin
        valid = 0;
    en*/
    always @(posedge clk) begin
        if(!rstn) begin
            valid <= 0;
            flag <= 0;
            i_data_parallel <= 0;
            q_data_parallel <= 0;
        end
        else begin
            if(!flag) begin // get data for I channel
                i_data_nxt <= data_serial;
                flag <= flag ^ 1'b1;
            end
            else begin // get data for Q channel
                q_data_parallel <= data_serial;
                i_data_parallel <= i_data_nxt;
                flag <= flag ^ 1'b1;
                valid <= 1;
            end
        end
    end
endmodule
