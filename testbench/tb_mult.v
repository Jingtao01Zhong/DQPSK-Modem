`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 22:03:41
// Design Name: 
// Module Name: tb_mult
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


module tb_mult(
    output [34:0] out_result
    );
    
    parameter clk_period_dds = 100;  // clock frequancy is 10MHz
    reg clk_dds;
    reg ready;
    initial begin
        clk_dds = 0;
        ready = 1;
        forever
            #(clk_period_dds/2) clk_dds = ~ clk_dds;
    end
    
    wire [7:0] sin_wave_0;
    wire [7:0] cos_wave_0;
    wire [15:0] M_AXIS_DATA_0_tdata;
    wire M_AXIS_DATA_0_tvalid;
    wire [31:0] M_AXIS_PHASE_0_tdata;
    wire M_AXIS_PHASE_0_tvalid;
    dds_compiler_test_1 dds_kkk(
        .aclk (clk_dds),
        .m_axis_data_tdata (M_AXIS_DATA_0_tdata),
        .m_axis_data_tvalid (M_AXIS_DATA_0_tvalid),
        .m_axis_phase_tdata (M_AXIS_PHASE_0_tdata),
        .m_axis_phase_tvalid (M_AXIS_PHASE_0_tvalid),
        .m_axis_data_tready (ready),
        .m_axis_phase_tready (ready)
    );
    assign sin_wave_0 = M_AXIS_DATA_0_tdata[15:8];
    assign cos_wave_0 = M_AXIS_DATA_0_tdata[7:0];

    wire [7:0] sin_wave_1;
    wire [7:0] cos_wave_1;
    wire [15:0] M_AXIS_DATA_1_tdata;
    wire M_AXIS_DATA_1_tvalid;
    wire [31:0] M_AXIS_PHASE_1_tdata;
    wire M_AXIS_PHASE_1_tvalid;
    dds_compiler_test dds_test(
        .aclk (clk_dds),
        .m_axis_data_tdata (M_AXIS_DATA_1_tdata),
        .m_axis_data_tvalid (M_AXIS_DATA_1_tvalid),
        .m_axis_phase_tdata (M_AXIS_PHASE_1_tdata),
        .m_axis_phase_tvalid (M_AXIS_PHASE_1_tvalid),
        .m_axis_data_tready (ready),
        .m_axis_phase_tready (ready)
    );
    assign sin_wave_1 = M_AXIS_DATA_1_tdata[15:8];
    assign cos_wave_1 = M_AXIS_DATA_1_tdata[7:0];
    
    //reg [16:0] mult;
    wire [16:0] fir_in;
    assign fir_in = {{9{cos_wave_1[7]}},cos_wave_1} + {{9{cos_wave_0[7]}},cos_wave_0};
    
    //assign fir_in = mult;
    wire fir_s_tready_0;
    wire signed [39:0] fir_m_tdata_0;
    wire fir_m_tvalid_0;
    fir_compiler_0 fir_test(
        .aclk (clk_dds),
        .s_axis_data_tdata (fir_in), // input, signed number 
        .s_axis_data_tready (fir_s_tready_0),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (fir_m_tdata_0),
        .m_axis_data_tvalid (fir_m_tvalid_0)
    );
    
    assign out_result = fir_m_tdata_0[34:0];
endmodule
