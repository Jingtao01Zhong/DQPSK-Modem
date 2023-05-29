`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/17 15:53:57
// Design Name: 
// Module Name: tb_shape_filter
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


module tb_shape_filter(
    output [23:0] out_I_shape
    );

    
    parameter clk_period_dds = 100;  // clock frequancy is 10MHz
    reg clk_dds;
    initial begin
        clk_dds = 0;
        forever
            #(clk_period_dds/2) clk_dds = ~ clk_dds;
    end
    
    // generate the clock for input data
    parameter clk_period_data = 10000; // 200Kbps £¨5000£©
    reg clk_data;
    initial begin
        clk_data = 0;
        forever
            #(clk_period_data/2) clk_data = ~ clk_data;
    end
    
    reg rstn;
    initial begin
        rstn = 1'b0;
        #(clk_period_data)
        rstn = 1'b1; 
    end
    
    reg [1:0] I_shape;
    wire [1:0] in_I_shape;
    assign in_I_shape = I_shape;
    initial begin
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b01;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b01;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b01;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b01;
        #clk_period_data
        
        I_shape = 2'b11;
        #clk_period_data
        
        I_shape = 2'b11;
    end
    
    wire fir_s_I_tready, fir_m_I_tvalid;
    //wire [23:0] out_I_shape;
    fir_compiler_shape fir_I_shape(
        .aclk (clk_dds),
        .s_axis_data_tdata ({{6{in_I_shape[1]}},in_I_shape}),
        .s_axis_data_tready (fir_s_I_tready),
        .s_axis_data_tvalid (rstn),
        .m_axis_data_tdata (out_I_shape),
        .m_axis_data_tvalid (fir_m_I_tvalid)
    );

endmodule
