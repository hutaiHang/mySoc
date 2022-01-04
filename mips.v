`timescale 1ns / 1ps


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM 
    );
	
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [7:0] alucontrolE;
	wire flushE,equalD;
	wire sign_extdE;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,
		pcsrcD,branchD,equalD,jumpD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		sign_extdE,
		//mem stage
		memtoregM,memwriteM,
		regwriteM,
		//write back stage
		memtoregW,regwriteW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		sign_extdE,
		flushE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedataM,
		readdataM,
		//writeback stage
		memtoregW,
		regwriteW
	    );
	
endmodule
