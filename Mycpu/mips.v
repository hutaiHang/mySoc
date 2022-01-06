`timescale 1ns / 1ps


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[3:0] mem_wenM,
	output wire[31:0] aluoutM_addr,writedataM,
	input wire[31:0] readdataM,
	output wire memenM,
	output wire [31:0] pcW,
	output wire regwriteW,
	output wire [31:0] resultW,
	output wire [4:0] writeregW
    );
	
	wire [5:0] opD,functD;
	wire [31:0] instrD;
	wire stallD,flushD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM;
	wire linkD;
	wire jrD;
	wire [7:0] alucontrolE;
	wire stallE,flushE;
	wire equalD;
	wire sign_extdE;

	wire stallM,flushM;
	wire write_hiloM;
	wire stallW,flushW;
	wire write_hiloW;
	wire jwriteD;

	wire [31:0] WB_pc;
	wire WB_wen;
	wire [4:0] WB_wnum;// 多少regfile
	wire [31:0] WB_data;

	wire [39:0] ascii;
	instdec instdec(instrF,ascii);

	controller c(
		clk,rst,
		//decode stage
		opD,functD,
		instrD,
		flushD,stallD,
		equalD,
		pcsrcD,branchD,jumpD,
		linkD,
		jrD,
		jwriteD,
		//execute stage
		flushE,stallE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		sign_extdE,
		//mem stage
		flushM,stallM,
		memtoregM,memwriteM,
		regwriteM,write_hiloM,
		memenM,
		//write back stage
		flushW,stallW,
		memtoregW,regwriteW,write_hiloW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		linkD,
		jrD,
		jwriteD,
		equalD,
		opD,functD,
		instrD,
		stallD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		sign_extdE,
		flushE,stallE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM_addr,writedataM,
		readdataM,
		write_hiloM,
		stallM,flushM,
		mem_wenM,
		//writeback stage
		memtoregW,
		regwriteW,
		pcW,
		resultW,
		writeregW,
		// HILO
		write_hiloW,
		stallW,flushW
	    );
	
endmodule
