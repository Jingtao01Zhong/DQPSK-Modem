`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/27 15:40:38
// Design Name: 
// Module Name: Modul_QPSK
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

module Modul_QPSK(
    input clk_dds,
    input clk_data,
    input rstn,
    input [1:0] in_data,  // baseband signal
    output [1:0] diff_out,
    output [8:0] data_modul_out, // modulated signal
    output data_valid
    );
    
    /*
    wire valid_ser2per;
    wire i_data, q_data;
    SerToPar ser2par(
        .clk (clk_data),
        .rstn (rstn),
        .data_serial (in_data),
        .valid (valid_ser2per),
        .i_data_parallel (i_data),
        .q_data_parallel (q_data)
    );
    */
    wire valid_diff_encode;
    diff_encode encoder(
        .rstn (rstn),
        .clk (clk_data),
        .in_data (in_data),
        .out_data (diff_out),
        .valid_diff_encode (valid_diff_encode)
    );
    reg ready;
    always @(*) begin // generate the ready signal for both dds
        if(!rstn) begin
            ready = 0;
        end
        else begin
            if(valid_diff_encode) begin
                ready = 1;
            end
            else ready = 0;
        end
    end
    
    //dds_0, generate the positive sin & cos wave
    wire [7:0] sin_wave_negative;
    wire [7:0] cos_wave_positive;
    wire [15:0] M_AXIS_DATA_0_tdata;
    wire M_AXIS_DATA_0_tvalid;
    wire [31:0] M_AXIS_PHASE_0_tdata;
    wire M_AXIS_PHASE_0_tvalid;
    dds_compiler_0 dds_0(
        .aclk (clk_dds),
        .m_axis_data_tdata (M_AXIS_DATA_0_tdata),
        .m_axis_data_tvalid (M_AXIS_DATA_0_tvalid),
        .m_axis_phase_tdata (M_AXIS_PHASE_0_tdata),
        .m_axis_phase_tvalid (M_AXIS_PHASE_0_tvalid),
        .m_axis_data_tready (ready),
        .m_axis_phase_tready (ready)
    );
    assign sin_wave_negative = M_AXIS_DATA_0_tdata[15:8];
    assign cos_wave_positive = M_AXIS_DATA_0_tdata[7:0];
    
    wire i_data, q_data;
    assign i_data = diff_out[1];
    assign q_data = diff_out[0];
    reg [1:0] in_I_shape, in_Q_shape;
    always @(*) begin
        if(ready) begin
            if(i_data) begin
                in_I_shape = 2'b01;
            end
            else begin
                in_I_shape = 2'b11;         
            end
            if(q_data) begin
                in_Q_shape = 2'b01;
            end
            else begin
                in_Q_shape = 2'b11;
            end
        end
        else begin
            in_I_shape = 2'b11;
            in_Q_shape = 2'b11;
        end
    end
    
    wire fir_s_I_tready, fir_m_I_tvalid, fir_s_Q_tready, fir_m_Q_tvalid;
    wire [23:0] I_shape, Q_shape;
    fir_compiler_shape fir_I_shape(
        .aclk (clk_dds),
        .s_axis_data_tdata ({{6{in_I_shape[1]}},in_I_shape}),
        .s_axis_data_tready (fir_s_I_tready),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (I_shape),
        .m_axis_data_tvalid (fir_m_I_tvalid)
    );
    
    fir_compiler_shape fir_Q_shape(
        .aclk (clk_dds),
        .s_axis_data_tdata ({{6{in_Q_shape[1]}},in_Q_shape}),
        .s_axis_data_tready (fir_s_Q_tready),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (Q_shape),
        .m_axis_data_tvalid (fir_m_Q_tvalid)
    );
    
    wire [26:0] I_signal, Q_signal;
    mult_gen_1 mult_i_shape(
        .CLK (clk_dds),
        .A (cos_wave_positive),
        .B (I_shape[18:0]),
        .P (I_signal)
    );
    
    mult_gen_1 mult_q_shape(
        .CLK (clk_dds),
        .A (sin_wave_negative),
        .B (Q_shape[18:0]),
        .P (Q_signal)
    );
    
    assign data_valid = ready;
    reg [26:0] data_modul;
    assign data_modul_out = {data_modul[26],data_modul[23:16]};
    always @(*) begin
        data_modul = I_signal + Q_signal;
    end

endmodule
