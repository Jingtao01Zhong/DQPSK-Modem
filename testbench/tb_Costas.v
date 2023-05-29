`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/20 16:08:40
// Design Name: 
// Module Name: tb_Costas
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


module tb_Costas(
    output [34:0] out_i_data,
    output [34:0] out_q_data,
    output [34:0] out_PhaseDection,
    output [34:0] loop_filter_out
    );  
    reg rstn;
    reg [1:0] data_parallel;
    wire [1:0] input_data;
    assign input_data = data_parallel;
    
    parameter clk_period_dds = 100;  // clock frequancy is 10MHz
    reg clk_dds;
    initial begin
        clk_dds = 0;
        forever
            #(clk_period_dds/2) clk_dds = ~ clk_dds;
    end
    
    // generate the clock for input data
    parameter clk_period_data = 10000; // 200Kbps
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
   // generate the reset 
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end
    
    // test simulation
    reg [2:0] counter;
    initial begin
        data_parallel = 2'b00;
        counter = 3'b000;
        forever @(negedge clk_data) begin
            if(counter == 3'b000) begin
                data_parallel <= 2'b11;
                counter <= counter + 1;
            end
            else if(counter == 3'b001) begin
                data_parallel <= 2'b10;
                counter <= counter + 1;
            end
            else if(counter == 3'b010) begin
                data_parallel = 2'b01;
                counter <= counter + 1;
            end
            else if(counter == 3'b011) begin
                data_parallel = 2'b01;
                counter <= counter + 1;
            end
            else if(counter == 3'b100) begin
                data_parallel = 2'b00;
                counter <= counter + 1;
            end
            else if(counter == 3'b101) begin
                data_parallel = 2'b10;
                counter <= counter + 1;
            end
            else if(counter == 3'b110) begin
                data_parallel = 2'b11;
                counter <= counter + 1;
            end
            else if(counter == 3'b111) begin
                data_parallel = 2'b10;
                counter <= counter + 1;
            end
        end
    end
    
    wire [8:0] data_QPSK;
    wire [1:0] parallel_data;
    wire data_valid;
    reg ready;

    always @(*) begin
        if(data_valid) begin
            ready = 1;
        end
        else begin
            ready = 0;
        end
    end
    wire [1:0] diff_out;
    Modul_QPSK u_000(
        .clk_dds (clk_dds),
        .clk_data (clk_data),
        .rstn (rstn),
        .in_data (input_data),
        .diff_out (diff_out),
        .data_modul_out (data_QPSK), 
        .data_valid (data_valid)
    );
    
    
    reg [39:0] frequency_control;
    always @(*) begin
        frequency_control = loop_filter_out;
    end
    //wire [39:0] phase_control;
    wire s_axis_config_tready;
    wire [39:0] S_AXIS_CONFIG_tdata;
    wire [15:0] M_AXIS_DATA_c_tdata;
    wire M_AXIS_DATA_c_tvalid;
    wire [15:0] M_AXIS_PHASE_c_tdata;
    wire M_AXIS_PHASE_c_tvalid;
    assign S_AXIS_CONFIG_tdata = {{5{frequency_control[34]}},frequency_control};
    dds_compiler_costas dds_costas_tb(
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
    
    
    wire [8:0] mult_in_wire;
    reg [8:0] mult_in_reg;
    assign mult_in_wire = mult_in_reg;
    always @(*) begin
        if(in_pop) begin
            mult_in_reg = fifo_out;
        end
        else begin
            mult_in_reg = 0; 
        end
    end
    wire signed [16:0] multiplier_I, multiplier_Q;  // mixing
    mult_gen_0 mult_I(
        .CLK (clk_dds),
        .A (mult_in_wire),
        .B (cos_wave_costas),
        .P (multiplier_I)
    );
    
    mult_gen_0 mult_Q(
        .CLK (clk_dds),
        .A (mult_in_wire),
        .B (sin_wave_costas),
        .P (multiplier_Q)     // output is a signed number
    );
    
    // FIR filter
    wire fir_s_tready_0;
    wire signed [39:0] fir_m_tdata_0;
    wire fir_m_tvalid_0;
    fir_compiler_0 fir_I_tb(
        .aclk (clk_dds),
        .s_axis_data_tdata ({{7{multiplier_I[16]}},multiplier_I}), // input, signed number 
        .s_axis_data_tready (fir_s_tready_0),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (fir_m_tdata_0), // output, signed number
        .m_axis_data_tvalid (fir_m_tvalid_0)
    );
    
    wire fir_s_tready_1;
    wire signed [39:0] fir_m_tdata_1;
    wire fir_m_tvalid_1;
    fir_compiler_0 fir_Q_tb(
         .aclk (clk_dds),
        .s_axis_data_tdata ({{7{multiplier_Q[16]}},multiplier_Q}), // input
        .s_axis_data_tready (fir_s_tready_1),
        .s_axis_data_tvalid (ready),
        .m_axis_data_tdata (fir_m_tdata_1), // output, signed number
        .m_axis_data_tvalid (fir_m_tvalid_1)
    );
    
    assign out_i_data = fir_m_tdata_0[34:0];
    assign out_q_data = fir_m_tdata_1[34:0];
    //wire [39:0] out_PhaseDection;
    PhaseDetection u_1_tb(
        .rstn (fir_s_tready_1),
        .clk (clk_dds),
        .fir_I (out_i_data),
        .fir_Q (out_q_data),
        .out_phase (out_PhaseDection)
    );
    
    LoopFilter loopfilter_tb(
        .clk (clk_dds),
        .rstn (rstn),
        .in_data (out_PhaseDection),
        .loop_filter_out (loop_filter_out)
    );
endmodule
