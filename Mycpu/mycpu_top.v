`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mycpu_top(
	input wire clk,resetn,
	input wire [5:0] int, 

    output wire        inst_sram_en   ,
    output wire [3 :0] inst_sram_wen  ,
    output wire [31:0] inst_sram_addr ,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    // data sram
    output wire        data_sram_en   ,
    output wire [3 :0] data_sram_wen  ,
    output wire [31:0] data_sram_addr ,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata,

    output [31:0] debug_wb_pc      ,
    output [3 :0] debug_wb_rf_wen  ,
    output [4 :0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata,
    input wire [5:0]ext_int


    );
	
	wire[31:0] pcF,pcconvertF;
	wire[31:0] instrF;

	wire [4:0] rsD,rtD;
	wire [5:0] opD,functD;
	wire equalD,flushD,stallD;

	wire flushE,stallE;
	wire [7:0] alucontrolE;

	wire memwriteM;
	wire[31:0] aluoutM,aluoutconvertM,writedataM;
	wire[31:0] readdataM;
	wire[3:0] data_sram_wenM;
	wire flushM,stallM;
	wire hilowriteM;
	
	wire[31:0] pcW,pcconvertW;
	wire[31:0] resultW;
	wire[4:0]  writeregW;
	wire flushW,stallW;



	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire invalidD;
	wire cp0writeM;
	wire is_in_delayslotF;
	wire except;


    assign inst_sram_en    = 1'b1;
    assign inst_sram_wen   = 4'b0;
    assign inst_sram_addr  = pcconvertF;
    assign inst_sram_wdata = 32'b0;
    assign instrF = inst_sram_rdata;
    // data sram
    assign data_sram_en    = 1'b1;
    assign data_sram_wen   = data_sram_wenM;
    assign data_sram_addr  = aluoutconvertM;
    assign data_sram_wdata = writedataM;
    assign readdataM = data_sram_rdata;

    assign debug_wb_pc       = pcW;
    assign debug_wb_rf_wen   = {4{regwriteW}};
    assign debug_wb_rf_wnum  = writeregW;
    assign debug_wb_rf_wdata = resultW;

	mmu mm1(
		.inst_vaddr(pcF),
    	.inst_paddr(pcconvertF),
  	  	.data_vaddr(aluoutM),
   		.data_paddr(aluoutconvertM)
	);
   	controller c(
		.clk(~clk),.rst(~resetn),
		//decode stage
		.opD(opD),.functD(functD),
		.rsD(rsD),.rtD(rtD),
		//execute stage
		.balE(balE),.jrE(jrE),.jalE(jalE),
		.memtoregE(memtoregE),.alusrcE(alusrcE),
		.regdstE(regdstE),.regwriteE(regwriteE),	
		.aluopE(alucontrolE),
		.flushE(flushE),.stallE(stallE),

		//mem stage
		.memenM(memenM),
		.balM(balM),.jrM(jrM),.jalM(jalM),
		.branchM(branchM),.jumpM(jumpM),
		.memtoregM(memtoregM),.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		.flushM(flushM),.stallM(stallM),
		//write back stage

		.memtoregW(memtoregW),.regwriteW(regwriteW),
		.flushW(flushW),.stallW(stallW),
		.hilowriteM(hilowriteM),
		.invalidD(invalidD),
		.cp0writeM(cp0writeM),
		.is_in_delayslotF(is_in_delayslotF)
		);
	datapath dp(
		.clk(~clk),.rst(~resetn),
		//fetch stage
		.pcF(pcF),
		.instrF(instrF),
		//decode stage
		.opD(opD),.functD(functD),
		.rsD(rsD),.rtD(rtD),
		//execute stage
		.balE(balE),.jrE(jrE),.jalE(jalE),
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),.regdstE(regdstE),
		.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
		.flushE(flushE),.stallE(stallE),
		//mem stage
		.balM(balM),.jrM(jrM),.jalM(jalM),
		.branchM(branchM),.jumpM(jumpM),
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.aluoutM(aluoutM),.writedataM(writedataM),
		.readdataM(readdataM),
		.flushM(flushM),.stallM(stallM),
		//writeback stage
		.pcW(pcW),
		.writeregW(writeregW),
		.resultW(resultW),
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		.flushW(flushW),.stallW(stallW),
		.data_sram_wenM(data_sram_wenM),
		.hilowriteM(hilowriteM),
		.invalidD(invalidD),
		.cp0writeM(cp0writeM),
		.ext_int(ext_int),
		.is_in_delayslotF(is_in_delayslotF),
		.except_logicM(except)
	    ); 
	
endmodule
