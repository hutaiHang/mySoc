`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
`include "defines.vh"
`include "defines2.vh"

module maindec(
    input wire clk,rst,
    input wire flushE,flushM,flushW,
    input wire stallE,stallM,stallW,
    input  wire [5:0] op,funct,
	input wire [4:0] rsD,rtD,
	output wire memenD,balD,jrD,jalD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,hilowriteD,cp0writeD,
	output wire memenE,balE,jrE,jalE,regwriteE,regdstE,alusrcE,branchE,memwriteE,memtoregE,jumpE,hilowriteE,cp0writeE,
	output wire memenM,balM,jrM,jalM,regwriteM,regdstM,alusrcM,branchM,memwriteM,memtoregM,jumpM,hilowriteM,cp0writeM,
    output wire memenW,balW,jrW,jalW,regwriteW,regdstW,alusrcW,branchW,memwriteW,memtoregW,jumpW,hilowriteW,cp0writeW,
    output reg invalid
	);

	parameter CONTROL_LENTH = 13;

	reg  [CONTROL_LENTH - 1:0] controlsD;
	wire [CONTROL_LENTH - 1:0] controlsE,controlsM,controlsW;
	assign {memenD,balD,jrD,jalD,regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,hilowriteD,cp0writeD} = controlsD;
	assign {memenE,balE,jrE,jalE,regwriteE,regdstE,alusrcE,branchE,memwriteE,memtoregE,jumpE,hilowriteE,cp0writeE} = controlsE;
	assign {memenM,balM,jrM,jalM,regwriteM,regdstM,alusrcM,branchM,memwriteM,memtoregM,jumpM,hilowriteM,cp0writeM} = controlsM;
	assign {memenW,balW,jrW,jalW,regwriteW,regdstW,alusrcW,branchW,memwriteW,memtoregW,jumpW,hilowriteW,cp0writeW} = controlsW;	
	//controlsD = {regwriteD,regdstD,alusrcD,branchD,memwriteD,memtoregD,jumpD,hilowriteD}
	always @(*) begin
	    invalid <= 1'b0;
		case(op)
			`EXE_R_TYPE://R-TYRE
				case (funct)
					//logic
					`EXE_AND   : controlsD <= 13'b0000110000000 ;
					`EXE_OR    : controlsD <= 13'b0000110000000 ;
					`EXE_XOR   : controlsD <= 13'b0000110000000 ;
					`EXE_NOR   : controlsD <= 13'b0000110000000 ;
					`EXE_SLL   : controlsD <= 13'b0000110000000 ;
					`EXE_SLLV  : controlsD <= 13'b0000110000000 ;
					`EXE_SRL   : controlsD <= 13'b0000110000000 ;
					`EXE_SRLV  : controlsD <= 13'b0000110000000 ;
					`EXE_SRA   : controlsD <= 13'b0000110000000 ;
					`EXE_SRAV  : controlsD <= 13'b0000110000000 ;
					`EXE_ADD   : controlsD <= 13'b0000110000000 ;
                    `EXE_ADDU  : controlsD <= 13'b0000110000000 ;
                    `EXE_SUB   : controlsD <= 13'b0000110000000 ;
                    `EXE_SUBU  : controlsD <= 13'b0000110000000 ;
                    `EXE_SLT   : controlsD <= 13'b0000110000000 ;
                    `EXE_SLTU  : controlsD <= 13'b0000110000000 ;
                    `EXE_MULT  : controlsD <= 13'b0000010000010 ;
                    `EXE_MULTU : controlsD <= 13'b0000010000010 ;
                    `EXE_DIV   : controlsD <= 13'b0000010000010 ;
                    `EXE_DIVU  : controlsD <= 13'b0000010000010 ;

                    `EXE_MFHI  : controlsD <= 13'b0000110000000 ;
                    `EXE_MTHI  : controlsD <= 13'b0000000000010 ;
                    `EXE_MFLO  : controlsD <= 13'b0000110000000 ;
                    `EXE_MTLO  : controlsD <= 13'b0000000000010 ;

					`EXE_JR    : controlsD <= 13'b0010000000100;
                    `EXE_JALR  : controlsD <= 13'b0010110000000;
                    `EXE_SYSCALL:controlsD <= 13'b0000000000000;
                    `EXE_BREAK : controlsD <= 13'b0000000000000;
                    default:invalid <= 1'b1;
				endcase
			//logic imm
			`EXE_ANDI  : controlsD <= 13'b0000101000000 ;
			`EXE_ORI   : controlsD <= 13'b0000101000000 ;
			`EXE_XORI  : controlsD <= 13'b0000101000000 ;
			`EXE_LUI   : controlsD <= 13'b0000101000000 ;
			//璁垮瓨鎸囦护
			`EXE_LB    : controlsD <= 13'b1000101001000 ;
			`EXE_LBU   : controlsD <= 13'b1000101001000 ;
            `EXE_LH    : controlsD <= 13'b1000101001000 ;
            `EXE_LHU   : controlsD <= 13'b1000101001000 ;
            `EXE_LW    : controlsD <= 13'b1000101001000 ;
            `EXE_SB    : controlsD <= 13'b1000001010000 ;
            `EXE_SH    : controlsD <= 13'b1000001010000 ;
            `EXE_SW    : controlsD <= 13'b1000001010000 ;
            //绠楁暟杩愮畻鎸囦护
            `EXE_ADDI  : controlsD <= 13'b0000101000000 ;
            `EXE_ADDIU : controlsD <= 13'b0000101000000 ;
            `EXE_SLTI  : controlsD <= 13'b0000101000000 ;
            `EXE_SLTIU : controlsD <= 13'b0000101000000 ;


            `EXE_BEQ   : controlsD <= 13'b0000000100000; // BEQ
            `EXE_BNE   : controlsD <= 13'b0000000100000; // BNE
            `EXE_BGTZ  : controlsD <= 13'b0000000100000; // BGTZ
            `EXE_BLEZ  : controlsD <= 13'b0000000100000; // BLEZ  
            6'b000001:     // BGEZ,BLTZ,BGEZAL,BLTZAL
                case(rtD)
                    `EXE_BGEZ : controlsD  <= 13'b0000000100000;
                    `EXE_BLTZ : controlsD  <= 13'b0000000100000;
                    `EXE_BGEZAL: controlsD <= 13'b0100100100000;
                    `EXE_BLTZAL: controlsD <= 13'b0100100100000;
                    default:invalid <= 1'b1;
                endcase
            // jump
            `EXE_J     : controlsD <= 13'b0000000000100; // J     
            `EXE_JAL   : controlsD <= 13'b0001100000000; 
            
            `SPECIAL3_INST:
                case(rsD)
                    `MFC0: controlsD <= 13'b0000100000000;
                    `MTC0: controlsD <= 13'b0000000000001;
                   default:controlsD <= 13'b0000000000000;//illegal op
                endcase

			default: begin
			     controlsD <= 13'b0000000000000;//illegal op
			     invalid <= 1'b1;
			end
		endcase
	end
	flopenrc #(CONTROL_LENTH) dff1E(clk,rst,~stallE,flushE,controlsD,controlsE);
    flopenrc #(CONTROL_LENTH) dff1M(clk,rst,~stallM,flushM,controlsE,controlsM);
    flopenrc #(CONTROL_LENTH) dff1W(clk,rst,~stallW,flushW,controlsM,controlsW);  // W閿熼樁璁规嫹閿熷眾甯稿埛閿熸枻鎷? 
endmodule

