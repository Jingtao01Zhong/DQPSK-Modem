`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/05 10:56:12
// Design Name: 
// Module Name: BitSync
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


module BitSync(
    input rstn,
    input clk,
    input data_in,
    output syn_out
    );
    
    wire clk_d1, clk_d2;
    clk_trans clk_trans(
        .rstn (rstn),
        .clk (clk),
        .clk_d1 (clk_d1),
        .clk_d2 (clk_d2)
    );
    
    wire clk_i, clk_q, pd_bef, pd_aft;
    differpd differpd(
        .rstn (rstn),
        .clk (clk),
        .data_in (data_in),
        .clk_i (clk_i),
        .clk_q (clk_q),
        .pd_bef (pd_bef),
        .pd_aft (pd_aft)
    );
    
    wire pd_before, pd_after;
    monoflop monoflop_0(
        .rstn (rstn),
        .clk (clk),
        .data_in (pd_bef),
        .data_out (pd_before)
    );
    
    monoflop monoflop_1(
        .rstn (rstn),
        .clk (clk),
        .data_in (pd_aft),
        .data_out (pd_after)
    );
    
    control_divfreq divfreq(
        .rstn (rstn),
        .clk (clk),
        .clk_d1 (clk_d1),
        .clk_d2 (clk_d2),
        .pd_before (pd_before),
        .pd_after (pd_after),
        .clk_i (clk_i),
        .clk_q (clk_q)
    );
    
    assign syn_out = clk_i;
endmodule

module clk_trans(
    input rstn,
    input clk, 
    output clk_d1,
    output clk_d2
);
    reg [1:0] c;
    reg clkd1, clkd2;
    always @(posedge clk or posedge rstn) begin
        if(!rstn) begin
            c = 0;
            clkd1 <= 0;
            clkd2 <= 0;
        end
        else begin
            c = c + 1'b1;
            if(c == 0) begin
                clkd1 <= 1;
                clkd2 <= 0;
            end
            else if(c == 2)begin
                clkd1 <= 0;
                clkd2 <= 1;
            end
            else begin
                clkd1 <= 0;
                clkd2 <= 0;
            end
        end
    end

    assign clk_d1 = clkd1;
    assign clk_d2 = clkd2;
endmodule

module differpd(
    input rstn,
    input clk,
    input datain,
    input data_in,
    input clk_i,
    input clk_q,
    output pd_bef,
    output pd_aft
);
    reg din_d, din_edge;
    reg pdbef, pdaft;
    always @(posedge clk or posedge rstn) begin
        if(!rstn) begin
            din_d <= 0;
            din_edge <= 0;
            pdbef <= 0;
            pdaft <= 0;
        end
        else begin
            din_d <= data_in;
            din_edge <= data_in ^ din_d;
            pdbef <= din_edge & clk_i;
            pdaft <= din_edge & clk_q;
        end
    end
    assign pd_bef = pdbef;
    assign pd_aft = pdaft;
endmodule

module monoflop( // Monoflop
    input rstn,
    input clk,
    input data_in,
    output data_out
);
    reg [1:0] c;
    reg start, dtem;
    always @(posedge clk or posedge rstn) begin
        if(!rstn) begin
            c = 0;
            start = 0;
            dtem <= 0;
        end
        else begin
            if(data_in) begin
                start = 1'b1;
                dtem <= 1'b1;
            end
            if(start) begin
                dtem <= 1'b1;
                if(c < 3) begin
                    c = c + 2'b01;
                end 
                else begin
                    start = 0;
                end
            end
            else begin
                c = 0;
                dtem <= 0;
            end
        end
    end
    
    assign data_out = dtem;
endmodule

module control_divfreq(
    input rstn,
    input clk,
    input clk_d1,
    input clk_d2,
    input pd_before,
    input pd_after,
    output gate_open,
    output gate_close,
    output clk_i,
    output clk_q
);
    wire gate_open, gate_close, clk_in;
    assign gate_open = (~ pd_before) & clk_d1;
    assign gate_close = pd_after & clk_d2;
    assign clk_in = gate_open | gate_close;
    
    reg clki, clkq;
    reg [2:0] c;
    always @(posedge clk or posedge rstn) begin
        if(!rstn) begin
            c = 2'b00;
            clki <= 0;
            clkq <= 0;
            
        end
        else begin
            if(clk_in)
                c = c + 3'b001;
            clki <= ~c[2];
            clkq <= c[2];
        end
    end
    assign clk_i = clki;
    assign clk_q = clkq;
 
endmodule
/*
module syncout(
    input rstn,
    input clk,
    input clk_d2,
    input clk_i,
    input [34:0] data_in,
    output bit_sync,
    output [34:0] data_out
);

    reg clki, sync;
    always @(posedge clk) begin
        if(!rstn) begin
            sync <= 0;
            clki <= 0;
        end
        else begin
            clki <= clk_i;
            if((clki == 0) & (clk_i == 1))
                sync <= 1'b1;
            else
                sync <= 1'b0;
        end
    end
    assign bit_sync = sync;
endmodule
*/

