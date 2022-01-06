`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,
	input wire [4:0] rsD,rtD,
	//execute stage
	output balE,jrE,jalE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] aluopE,
	input wire flushE,stallE,	

	//mem stage
	output memenM,
	output balM,jrM,jalM,
	output branchM,jumpM,
	output wire memtoregM,memwriteM,
				regwriteM,
	input wire flushM,stallM,

	//write back stage

	output wire memtoregW,regwriteW,
	input wire flushW,stallW,
	output wire hilowriteM,
	output wire invalidD,
	output wire cp0writeM,
	output wire is_in_delayslotF

    );
	
	//decode stage
	wire[1:0] aluopD;
	wire memenD,balD,jrD,jalD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,hilowriteD,cp0writeD;
	wire memenE,                                        branchE                    ,jumpE,hilowriteE,cp0writeE;
	wire                                regdstM,alusrcM                                             ;
    wire memenW,balW,jrW,jalW,          regdstW,alusrcW,branchW,memwriteW          ,jumpW,hilowriteW,cp0writeW;
	


	//execute stage
	wire memwriteE;
	
	assign is_in_delayslotF = (jumpD|jrD|jalD|branchD|balD);

	maindec md(
    clk,rst,
    flushE,flushM,flushW,
    stallE,stallM,stallW,
    opD,functD,
	rsD,rtD,
	memenD,balD,jrD,jalD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,hilowriteD,cp0writeD,
	memenE,balE,jrE,jalE,regwriteE,regdstE,alusrcE,branchE,memwriteE,memtoregE,jumpE,hilowriteE,cp0writeE,
	memenM,balM,jrM,jalM,regwriteM,regdstM,alusrcM,branchM,memwriteM,memtoregM,jumpM,hilowriteM,cp0writeM,
    memenW,balW,jrW,jalW,regwriteW,regdstW,alusrcW,branchW,memwriteW,memtoregW,jumpW,hilowriteW,cp0writeW,
    invalidD
		);

	aludec ad(
	clk,rst,flushE, stallE,
	rsD,
    opD,functD,
    aluopE
	);
endmodule
