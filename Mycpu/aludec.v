`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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

module aludec (
    input  wire clk, rst,flushE, stallE,
    input  wire [4:0]rsD,
    input  wire [5:0] op,funct,
    output wire[7:0]aluopE
);  
	reg [7:0]aluopD;
    always @(*) begin
		case(op)
			`EXE_R_TYPE://R-TYRE
				case (funct)
					`EXE_AND   : aluopD <= `EXE_AND_OP	 ;
					`EXE_OR    : aluopD <= `EXE_OR_OP	 ;
					`EXE_XOR   : aluopD <= `EXE_XOR_OP	 ;
					`EXE_NOR   : aluopD <= `EXE_NOR_OP	 ;
					`EXE_SLL   : aluopD <= `EXE_SLL_OP   ;
                    `EXE_SLLV  : aluopD <= `EXE_SLLV_OP  ;
                    `EXE_SRL   : aluopD <= `EXE_SRL_OP   ;
                    `EXE_SRLV  : aluopD <= `EXE_SRLV_OP  ;
                    `EXE_SRA   : aluopD <= `EXE_SRA_OP   ;
                    `EXE_SRAV  : aluopD <= `EXE_SRAV_OP  ;
                    `EXE_ADD   : aluopD <= `EXE_ADD_OP  ;
                    `EXE_ADDU  : aluopD <= `EXE_ADDU_OP ;
                    `EXE_SUB   : aluopD <= `EXE_SUB_OP  ;
                    `EXE_SUBU  : aluopD <= `EXE_SUBU_OP ;
                    `EXE_SLT   : aluopD <= `EXE_SLT_OP  ;
                    `EXE_SLTU  : aluopD <= `EXE_SLTU_OP ;
                    `EXE_MULT  : aluopD <= `EXE_MULT_OP ;
                    `EXE_MULTU : aluopD <= `EXE_MULTU_OP;
                    `EXE_DIV   : aluopD <= `EXE_DIV_OP  ;
                    `EXE_DIVU  : aluopD <= `EXE_DIVU_OP ;
                    `EXE_MFHI  : aluopD <= `EXE_MFHI_OP ;
                    `EXE_MTHI  : aluopD <= `EXE_MTHI_OP ;
                    `EXE_MFLO  : aluopD <= `EXE_MFLO_OP ;
                    `EXE_MTLO  : aluopD <= `EXE_MTLO_OP ;
                    `EXE_SYSCALL:aluopD <= `EXE_SYSCALL_OP;
                    `EXE_BREAK : aluopD <= `EXE_BREAK_OP;
				endcase
			`EXE_ANDI: aluopD <= `EXE_ANDI_OP;
			`EXE_ORI : aluopD <= `EXE_ORI_OP;
			`EXE_XORI: aluopD <= `EXE_XORI_OP;
			`EXE_LUI : aluopD <= `EXE_LUI_OP;
			//访存指令
			`EXE_LB    : aluopD <= `EXE_LB_OP ;
			`EXE_LBU   : aluopD <= `EXE_LBU_OP;
            `EXE_LH    : aluopD <= `EXE_LH_OP ;
            `EXE_LHU   : aluopD <= `EXE_LHU_OP;
            `EXE_LW    : aluopD <= `EXE_LW_OP ;
            `EXE_SB    : aluopD <= `EXE_SB_OP ;
            `EXE_SH    : aluopD <= `EXE_SH_OP ;
            `EXE_SW    : aluopD <= `EXE_SW_OP ;
            //算数运算指令
            `EXE_ADDI  : aluopD <= `EXE_ADDI_OP ;
            `EXE_ADDIU : aluopD <= `EXE_ADDIU_OP;
            `EXE_SLTI  : aluopD <= `EXE_SLTI_OP ;
            `EXE_SLTIU : aluopD <= `EXE_SLTIU_OP;

             6'b010000:
                case (rsD)
                    5'b00000: aluopD <= `EXE_MFC0_OP;
                    default : aluopD <= 8'b00000000;
                endcase           
			default : aluopD <= 8'b0;
		endcase
	end
	flopenrc #(8 ) aluopD2E(clk,rst,~stallE,flushE,aluopD,aluopE);
endmodule