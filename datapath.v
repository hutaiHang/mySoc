`timescale 1ns / 1ps
`include "defines.vh"
module datapath(
	input wire clk,rst,
	//取指
	output wire[31:0] pcF,//地址
	input wire[31:0] instrF,//指令
	//译码
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[5:0] opD,functD,
	//执行
	input wire memtoregE,//回写数据来自alu/存储器
	input wire alusrcE,regdstE,//写入的寄存器序号
	input wire regwriteE,//是否回写
	input wire[7:0] alucontrolE,//ALU控制信号
	input wire sign_extdE,//无符号立即数拓展
	output wire flushE,//流水线刷新信号
	output wire stallE,
	//访存
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM_addr,writedataM,
	input wire[31:0] readdataM,
	input wire write_hiloM,
	output wire stallM,
	output wire flushM,
	output reg[3:0] mem_wenM,
	//回写
	input wire memtoregW,
	input wire regwriteW,
	// HILO
	input wire write_hiloW,
	output wire stallW,
	output wire flushW
    );
	
	//取指
	wire stallF,flushF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//译码
	wire [31:0] pcplus4D,instrD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] unsignimmD;//无符号立即数拓展
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [4:0] offsetD;//偏移
	wire [63:0] hilo_inD;
	//执行
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	wire [31:0] unsignimmE;//无符号立即数拓展
	wire [31:0] final_imm;//最终选择的立即数
	wire [4:0] offsetE;//偏移
	wire [63:0] hilo_inE;
	wire [63:0] alu_hilo_src;
	wire div_stallE;
	// wire stallE;
	//访存
	wire [4:0] writeregM;
	wire [63:0] hilo_inM;
	wire [7:0] alucontrolM;
	wire [31:0] aluoutM;
	//回写
	wire [4:0] writeregW;
	wire [31:0] aluoutW,resultW;
	reg [31:0] readdataW;
	wire [63:0] hilo_inW;
	wire [63:0] hilo_regW;
	wire [7:0] alucontrolW;
	wire forward_hilo_E;

	//冒险模块
	hazard h(
		//取指
		stallF,
		flushF,
		//译码
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,flushD,
		//执行
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		div_stallE,
		forwardaE,forwardbE,
		forward_hilo_E,
		flushE,
		stallE,
		//访存
		writeregM,
		regwriteM,
		memtoregM,
		write_hiloM,
		stallM,
		flushM,
		//回写
		writeregW,
		regwriteW,
		stallW,
		flushW
		);

	//下一PC值确定 先确定+4 or branch 再确定是否jump
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD,pcnextFD);

	//寄存器堆，负责读入或回写数据
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//取指
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);//TODO PC触发器修改
	adder pcadd1(pcF,32'b100,pcplus4F);
	

	//译码 阻塞信号取反作为是能信号，控制pc不变以实现流水线暂停
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	signext se(instrD[15:0],signimmD,unsignimmD);
	sl2 immsh(signimmD,signimmshD);//依偎，乘4
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,equalD);
	// HILO 选择新的值
	mux2 #(64) forword_hilo_mux(hilo_regW,hilo_inM,forward_hilo_E,alu_hilo_src);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign offsetD = instrD[10:6];

	//执行 每个信号采用D触发器进行传递 刷新信号作为clear信号
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(32) r7E(clk,rst,~stallE,flushE,unsignimmD,unsignimmE);//无符号立即数拓展
	flopenrc #(5)  r8E(clk,rst,~stallE,flushE,offsetD,offsetE);//偏移量
	//TODO 画数据通路图---
	mux2 #(32) choice_imm_is_signed(unsignimmE,signimmE,sign_extdE,final_imm);
	//----
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,final_imm,alusrcE,srcb3E);
	alu alu(clk,rst,srca2E,srcb3E,offsetE,alucontrolE,alu_hilo_src[63:32],alu_hilo_src[31:0],hilo_inE[63:32],hilo_inE[31:0],div_stallE,aluoutE);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

	//访存
	flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluoutE,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writeregE,writeregM);
	flopenrc #(64) r4M_hilo(clk,rst,~stallM,flushM,hilo_inE,hilo_inM);
	flopenrc #(8) r5M_aluop(clk.rst,~stallM,flushM,alucontrolE,alucontrolM);
	//sw各种指令选择
	always @(*) begin
		case (alucontrolM)
			`EXE_SB_OP: mem_wenM <= 4'b0001;
			`EXE_SH_OP: mem_wenM <= 4'b0011;
			`EXE_SW_OP: mem_wenM <= 4'b1111;
			default: mem_wenM<= 4'b0000;
		endcase
	end

	// wire [31:0] aluoutM_addr;
	assign aluoutM_addr={aluoutM[31:2],2'b00};//取字地址

	//回写
	flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallW,flushW,readdataM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(8) r4W_aluop(clk.rst,~stallM,flushM,alucontrolM,alucontrolW);

	//取字节
	wire [31:0]readdata_signed_byte,readdata_unsigned_byte;
	// assign readdata_true={{24{readdataW[7]}},readdataW[7:0]};
	assign readdata_signed_byte = aluoutM[1:0]==2'b11 ? {{24{readdataW[7]}},readdataW[7:0]} :
							aluoutM[1:0]==2'b10 ? {{24{readdataW[15]}},readdataW[15:8]} :
							aluoutM[1:0]==2'b01 ? {{24{readdataW[23]}},readdataW[23:16]} :
							aluoutM[1:0]==2'b00 ? {{24{readdataW[31]}},readdataW[31:24]} : 32'b0;

	assign readdata_unsigned_byte = aluoutM[1:0]==2'b11 ? {{24{1'b0}},readdataW[7:0]} :
							aluoutM[1:0]==2'b10 ? {{24{1'b0}},readdataW[15:8]} :
							aluoutM[1:0]==2'b01 ? {{24{1'b0}},readdataW[23:16]} :
							aluoutM[1:0]==2'b00 ? {{24{1'b0}},readdataW[31:24]} : 32'b0;
	
	//取半字
	wire [31:0]readdata_signed_half,readdata_unsigned_half;
	// assign readdata_true={{24{readdataW[7]}},readdataW[7:0]};
	assign readdata_signed_half = aluoutM[1:0]==2'b10 ? {{16{readdataW[15]}},readdataW[15:0]} :
							aluoutM[1:0]==2'b00 ? {{16{readdataW[31]}},readdataW[31:16]} : 32'b0;

	assign readdata_unsigned =  aluoutM[1:0]==2'b10 ? {{16{1'b0}},readdataW[15:0]} :
							aluoutM[1:0]==2'b00 ? {{16{1'b0}},readdataW[31:16]} : 32'b0;

	always @(*) begin
		case (alucontrolW)
			`EXE_LB_OP:readdataW <= readdata_signed_byte;
			`EXE_LBU_OP:readdataW<= readdata_unsigned_byte;
			`EXE_LH_OP: readdataW <= readdata_signed_half;
			`EXE_LHU_OP: readdataW <= readdata_unsigned_half;
			default: readdataW <= readdataW;
		endcase	
	end

	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopenrc #(64) r4W_hilo(clk,rst,~stallW,flushW,hilo_inM,hilo_inW);
	hilo_reg my_hilo_regW(clk,rst,write_hiloW,hilo_inW[63:32],hilo_inW[31:0],hilo_regW[63:32],hilo_regW[31:0]);
endmodule
