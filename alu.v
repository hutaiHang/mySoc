`timescale 1ns / 1ps
`include "defines.vh"
module alu(
	// input
	input wire[31:0] a,b,
	input wire[4:0] offset,
	input wire[7:0] op,
	// HILO Input
	input wire [31:0] hi_input,
	input wire [31:0] lo_input,

	// output
	// HILO Output
	output reg [31:0] hi_output,
	output reg [31:0] lo_output,
	// Old
	output reg[31:0] y,
	output reg overflow,//TODO 溢出信号暂未处理
	output wire zero
    );

wire[31:0] s,bout;
wire subfunc;
assign subfunc=op==`EXE_SUB_OP|op==`EXE_SUBU_OP|op==`EXE_SLT_OP|op==`EXE_SLTI_OP|op==`EXE_SLTU_OP|op==`EXE_SLTIU_OP;
assign bout = subfunc ? ~b : b;
assign s = a + bout + subfunc;

always @(*) begin
	hi_output <= hi_input;
	lo_output <= lo_input;
	case (op)
		//----------算数运算指令
		`EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:y <= s;
		`EXE_SUB_OP,`EXE_SUBU_OP:y <= s;
		//----------比较指令
		`EXE_SLT_OP,`EXE_SLTI_OP:y <= (a[31]&~b[31])?1:
											s[31]&~(~a[31]&b[31]);
		`EXE_SLTU_OP,`EXE_SLTIU_OP:y <=a<b;
		`EXE_AND_OP: y<= a&b;
		`EXE_OR_OP:  y<= a|b;
		`EXE_ANDI_OP: y<= a&b;// ANDI
		`EXE_LUI_OP:y<= {b[15:0],16'b0};//LUI
		`EXE_ORI_OP:y<= a|b;//ORI
		`EXE_XORI_OP:y<=a^b;//XORI
		`EXE_NOR_OP:y<= ~(a|b);//NOR
		`EXE_XOR_OP: y<= a^b;//XOR
		`EXE_LW_OP: y<= a+b;//LW
		`EXE_SW_OP: y<=a+b;//SW
		`EXE_BEQ_OP: y<= a+(~b)+1;//BEQ
		// ----移位指令----
		`EXE_SLL_OP: y<=(b<<offset);//SLL
		`EXE_SRL_OP: y<=(b>>offset);//SRL
		`EXE_SRA_OP: y<=$unsigned(( ($signed(b)) >>> offset));//SRA {offset{b[31]}},b[31:offset]}
		`EXE_SLLV_OP: y<=(b<<a);//SLLV
		`EXE_SRLV_OP: y<=(b>>a);//SRLV
		`EXE_SRAV_OP: y<=$unsigned(( ($signed(b)) >>> a));//SRAV
		// --------HILO指令-------
		`EXE_MTHI_OP: hi_output <= a;
		`EXE_MTLO_OP: lo_output <= a;
		`EXE_MFHI_OP: y <= hi_input;
		`EXE_MFLO_OP: y <= lo_input;
		default: y<=32'b0;
	endcase
end

// 溢出判断
always @(*) begin
	case (op)
		`EXE_ADD_OP,`EXE_ADDI_OP:overflow <= a[31] & b[31] & ~s[31] |
						~a[31] & ~b[31] & s[31];
		`EXE_SUB_OP:overflow <= ~a[31] & b[31] & s[31] |
						a[31] & ~b[31] & ~s[31];
		default : overflow <= 1'b0;
	endcase	
end
endmodule
