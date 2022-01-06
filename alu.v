`timescale 1ns / 1ps
`include "defines.vh"
module alu(
	input wire clk,
	input wire rst,
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
	output reg div_stall, // 除法器是否阻塞流水线
	// Old
	output reg[31:0] y,
	output reg overflow,//TODO 溢出信号暂未处理
	output wire zero
    );

	reg [31:0] a_reg,b_reg;
	wire[31:0] s,bout;
	wire subfunc;

	reg div_sign;
	reg div_start;
	// wire div_stall;
	wire [63:0] div_ans;
	

	assign subfunc=op==`EXE_SUB_OP|op==`EXE_SUBU_OP|op==`EXE_SLT_OP|op==`EXE_SLTI_OP|op==`EXE_SLTU_OP|op==`EXE_SLTIU_OP;
	assign bout = subfunc ? ~b : b;
	assign s = a + bout + subfunc;

	reg reg_control;
    always@(posedge clk) begin
		if(div_start) reg_control<=1;
		else reg_control<=0;
	end

	always@(negedge clk)begin
		if( (reg_control^div_start)&(div_start))begin
			a_reg<=a;
			b_reg<=b;
		end
		else begin
			a_reg<=a_reg;
			b_reg<=b_reg;
		end
		
	end

	div my_div(
			// input
			clk,
			rst,
			div_sign, // 是否是有符号除法, 1为有符号, 0为无符号
			a_reg, // 被除数
			b_reg, // 除数
			div_start, // 开始做除法运算, DivStart,
			1'b0, // 是否消除出发运算, 1为消除, 0为不消除

			// output
			div_ans, // 除法的结果
			div_ans_ready // 除法是否完成 DivResultReady
	);

	always @(*) begin
		// :初始化除法器, 不开始除法运算
		div_stall <= 1'b0;
		div_sign <= 1'b0;
		div_start <= `DivStop;
		case(op)
			`EXE_DIV_OP: begin
				if (div_ans_ready == 1'b0) begin
					div_sign <= 1'b1;
					div_start <= `DivStart;
					div_stall <= 1'b1;
				end else begin
					div_stall <= 1'b0;
					div_sign <= 1'b0;
					div_start <= `DivStop;
				end
			end
			`EXE_DIVU_OP: begin
				if (div_ans_ready == 1'b0) begin
					div_sign <= 1'b0;
					div_start <= `DivStart;
					div_stall <= 1'b1;
				end else begin
					div_stall <= 1'b0;
					div_sign <= 1'b0;
					div_start <= `DivStop;
				end
			end
			default:begin
				div_sign <= 1'b0;
				div_start <= `DivStop;
				div_stall <= 1'b0;
			end
		endcase
	end

	always @(*) begin
		// HILO 保持原值
		hi_output <= hi_input;
		lo_output <= lo_input;

		case (op)
			//----------算数运算指令
			`EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:y <= s;
			`EXE_SUB_OP,`EXE_SUBU_OP:y <= s;
			`EXE_MULT_OP:  {hi_output,lo_output} <= $signed(a) * $signed(b);//结果写入HILO寄存器
			`EXE_MULTU_OP: {hi_output,lo_output} <= {32'b0, a} * {32'b0, b};//结果写入HILO寄存器
			`EXE_DIV_OP, `EXE_DIVU_OP: {hi_output,lo_output} <= div_ans;

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
			`EXE_LW_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LH_OP,`EXE_LHU_OP: y<= a+b;//存取指令
			`EXE_SW_OP,`EXE_SH_OP,`EXE_SB_OP: y<=a+b;//SW
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
			//---------转移指令------------
			`EXE_BEQ_OP: y<= (a==b) ? 32'hffff_ffff:32'h0000_0000;//BEQ
			`EXE_BNE_OP: y<= (a!=b) ? 32'hffff_ffff:32'h0000_0000; //BNE
			`EXE_BGEZ_OP: y<= (a[31] == 1'b0) ? 32'hffff_ffff:32'h0000_0000;
			`EXE_BGTZ_OP:  y<= ((a[31] == 1'b0) && (a != `ZeroWord)) ? 32'hffff_ffff:32'h0000_0000;
			`EXE_BLEZ_OP: y <= ((a[31] == 1'b1) || (a == `ZeroWord)) ? 32'hffff_ffff:32'h0000_0000;
			`EXE_BLTZ_OP: y<= (a[31] == 1'b1) ? 32'hffff_ffff:32'h0000_0000;
			`EXE_BLTZAL_OP:y<= (a[31] == 1'b1) ? 32'hffff_ffff:32'h0000_0000;
			`EXE_BGEZAL_OP:y<= (a[31] == 1'b0) ? 32'hffff_ffff:32'h0000_0000;
			default: y<=32'b0;
		endcase
	end

	assign zero = (y == 32'b0); // zero

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
