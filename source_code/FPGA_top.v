`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/18 21:11:58
// Design Name: 
// Module Name: FPGA_top
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


module FPGA_top(
    input clk_dds,
    input clk_data,
    input clk_bitsync,
    input in_data,
    output data_demodul_out,
    output out_clk_sync,
    output [8:0] data_modul_out
    );

    wire [1:0] parallel_data;
    wire [8:0] data_modul_out;
    wire data_valid;
    Modul_QPSK Modul_QPSK(
        .clk_dds (clk_dds),
        .clk_data (clk_data),
        .rstn (rstn),
        .in_data (in_data),
        .parallel_data (parallel_data),
        .data_modul_out (data_modul_out),
        .data_valid (data_valid)
    );
    
    wire demodul_valid;
    wire [34:0] i_data, q_data;
    //wire data_demodul_out;
    //wire syn_out;
    Demodul_QPSK Demodul_QPSK(
        .clk_dds (clk_dds),
        .clk_bitsync (clk_bitsync),
        .rstn (data_valid),
        .data_modul_in (data_modul_out),
        .valid (demodul_valid),
        .i_data (i_data),
        .q_data (q_data),
        .data_demodule_out (data_demodul_out),
        .syn_out (out_clk_sync)
    );
endmodule
