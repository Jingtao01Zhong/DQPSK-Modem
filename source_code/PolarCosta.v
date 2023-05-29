`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/10 15:22:03
// Design Name: 
// Module Name: PolarCosta
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
module PolarCosta(
    input clk_dds,
    input data_valid,
    input [8:0] in_costas,
    output [34:0] out_i_data,
    output [34:0] out_q_data,
    output valid_costas
    //output [15:0] out_carrier_recovery
    );
    
    reg ready;
    always @(*) begin
        if(data_valid) begin
            ready = 1;
        end
        else begin
            ready = 0;
        end
    end
    
    wire [34:0] loop_filter_out;
    wire [34:0] phase_control;
    wire s_axis_config_tready;
    wire [34:0] S_AXIS_CONFIG_tdata;
    wire [15:0] M_AXIS_DATA_c_tdata;
    wire M_AXIS_DATA_c_tvalid;
    wire [15:0] M_AXIS_PHASE_c_tdata;
    wire M_AXIS_PHASE_c_tvalid;
    assign phase_control = loop_filter_out;
    assign S_AXIS_CONFIG_tdata = phase_control;
    dds_compiler_costas dds_costas(
        .aclk (clk_dds),
        .s_axis_config_tdata (S_AXIS_CONFIG_tdata),
        .s_axis_config_tvalid (ready),
        .m_axis_data_tdata (M_AXIS_DATA_c_tdata),
        .m_axis_data_tvalid (M_AXIS_DATA_c_tvalid),
        .m_axis_phase_tdata (M_AXIS_PHASE_c_tdata),
        .m_axis_phase_tvalid (M_AXIS_PHASE_c_tvalid),
        .m_axis_data_tready (ready),
        .m_axis_phase_tready (ready),
        .s_axis_config_tready (s_axis_config_tready)
    );
    
    wire [7:0] sin_wave_costas;
    wire [7:0] cos_wave_costas;
    assign sin_wave_costas = M_AXIS_DATA_c_tdata[15:8];
    assign cos_wave_costas = M_AXIS_DATA_c_tdata[7:0];
   
    wire signed [16:0] multiplier_I, multiplier_Q;  // mixing
    mult_gen_0 mult_I(
        .CLK (clk_dds),
        .A (in_costas),
        .B (cos_wave_costas),
        .P (multiplier_I)
    );
    
    mult_gen_0 mult_Q(
        .CLK (clk_dds),
        .A (in_costas),
        .B (sin_wave_costas),
        .P (multiplier_Q)     // output is a signed number
    );
    
    // FIR filter
    wire fir_s_tready_0;
    wire signed [39:0] fir_m_tdata_0;
    wire fir_m_tvalid_0;
    fir_compiler_0 fir_I(
        .aclk (clk_dds),
        .s_axis_data_tdata (multiplier_I), // input, signed number 
        .s_axis_data_tready (fir_s_tready_0),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (fir_m_tdata_0), // output, signed number
        .m_axis_data_tvalid (fir_m_tvalid_0)
    );
    
    wire fir_s_tready_1;
    wire signed [39:0] fir_m_tdata_1;
    wire fir_m_tvalid_1;
    fir_compiler_0 fir_Q(
         .aclk (clk_dds),
        .s_axis_data_tdata (multiplier_Q), // input
        .s_axis_data_tready (fir_s_tready_1),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (fir_m_tdata_1), // output, signed number
        .m_axis_data_tvalid (fir_m_tvalid_1)
    );
    
    assign out_i_data = fir_m_tdata_0[34:0];
    assign out_q_data = fir_m_tdata_1[34:0];
    
    wire [34:0] out_phase;
    PhaseDetection PhaseDetection(
        .rstn (fir_s_tready_1),
        .clk (clk_dds),
        .fir_I (out_i_data),
        .fir_Q (out_q_data),
        .out_phase (out_phase)
    );
    
    
    LoopFilter LoopFilter(
        .clk (clk_dds),
        .rstn (fir_s_tready_1),
        .in_data (out_phase),
        .loop_filter_out (loop_filter_out)
    );
endmodule

module PhaseDetection(
    input rstn,
    input clk,
    input signed [34:0] fir_I,
    input signed [34:0] fir_Q,
    output signed [34:0] out_phase
);
    reg signed [34:0] syn_I, syn_Q;
    always @(*) begin
        if(!fir_I[34]) begin
            syn_Q = fir_Q;
        end
        else begin
            syn_Q = -fir_Q;
        end
        
        if(!fir_Q[34]) begin
            syn_I = fir_I;
        end
        else begin
            syn_I = -fir_I;
        end
    end
    reg signed [35:0] out_phase_nxt;
    always @(posedge clk) begin
        if(!rstn) begin
            out_phase_nxt <= 0;
        end
        else begin
            out_phase_nxt <= {syn_Q[34],syn_Q} - {syn_I[34],syn_I};
        end
    end
    assign out_phase = out_phase_nxt[35:1];
endmodule

module LoopFilter(
    input clk,
    input rstn,
    input [34:0] in_data,
    output [34:0] loop_filter_out
);
    wire [34:0] initial_frequency;
    assign initial_frequency = 35'd3453153706; //5K 
    reg [2:0] count;
    reg signed [34:0] sum, loop_out;
    integer t;
    always @(posedge clk) begin
        if(!rstn) begin
            count <= 3'b000;
            sum <= 35'd0;
            loop_out <= initial_frequency;
            t <= 0;
        end
        else begin
            t <= t + 1;
            if(t < 30000) begin
                count <= count + 3'b001;
                if(count == 3'b000) begin
                    sum <= sum + {{12{in_data[34]}},in_data[34:12]};
                end
                if(count == 3'b001)begin
                    loop_out <= initial_frequency + sum + {{5{in_data[34]}},in_data[34:5]};
                end
            end
            else begin
                count <= count + 3'b001;
                 if(count == 3'b000) begin
                    sum <= sum + {{17{in_data[34]}},in_data[34:17]};
                end
                if(count == 3'b001)begin
                    loop_out <= initial_frequency + sum + {{10{in_data[34]}},in_data[34:10]};
                end
            end
        end
    end
    
    assign loop_filter_out = loop_out;
endmodule