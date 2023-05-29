`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/09 18:18:04
// Design Name: 
// Module Name: Demodul_QPSK
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


module Demodul_QPSK(
    input clk_dds,
    input clk_bitsync,
    input rstn,
    input [8:0] data_modul_in,
    output [34:0] i_data,
    output [34:0] q_data,
    output [1:0] data_demodule_out,
    output syn_out
    );
    
    wire fir_s_tready_2;
    wire signed [31:0] fir_m_tdata_2;
    wire fir_m_tvalid_0;
    fir_compiler_receiver fir_receiver(
        .aclk (clk_dds),
        .s_axis_data_tdata ({{7{data_modul_in}},data_modul_in}), // input, signed number 
        .s_axis_data_tready (fir_s_tready_2),
        .s_axis_data_tvalid (rstn),
        .m_axis_data_tdata (fir_m_tdata_2), // output, signed number
        .m_axis_data_tvalid (fir_m_tvalid_2)
    );
    wire [8:0] in_costas;
    assign in_costas =  fir_m_tdata_2[25:17];
    
    wire valid_costas;
    PolarCosta Costas(
        .clk_dds (clk_dds),
        .data_valid (rstn),
        .in_costas (in_costas),
        .out_i_data (i_data),
        .out_q_data (q_data),
        .valid_costas (valid_costas)
   ); 
   
   BitSync BitSync(
        .rstn (rstn),
        .clk (clk_bitsync),
        .data_in (i_data[34]),
        .syn_out (syn_out)
    );
    
    reg i_demodul, q_demodul;
    always @(*) begin
        i_demodul = ~i_data[34];
        q_demodul = ~q_data[34];
    end
    
    wire [1:0] data_per;
    assign data_per = {i_demodul,q_demodul};
    
    wire clk_decoder = ~syn_out;
    diff_decode decoder(
        .rstn (rstn),
        .clk (clk_decoder),
        .in_code (data_per),
        .out_code (data_demodule_out)
    );
endmodule
