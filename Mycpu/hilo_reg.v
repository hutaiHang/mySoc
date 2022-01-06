`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/03 20:06:01
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(
    input wire clk,rst,we,
    input wire[63:0] hilo_i,
    output reg[31:0] hi,
    output reg[31:0] lo
    );
    always @(negedge clk) begin
		if(rst) begin
			// hi_o <= `ZeroWord;
			// lo_o <= `ZeroWord;
			hi <= 32'h00000000;
			lo <= 32'h00000000;
		end else if (we) begin
			// hi_o <= hi;
			// lo_o <= lo;
			hi <= hilo_i[63:32];
			lo <= hilo_i[31:0];
		end
	end
endmodule
