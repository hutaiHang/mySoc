`timescale 1ns / 1ps

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
	
	//访存
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	input wire write_hiloM,
	//回写
	input wire memtoregW,
	input wire regwriteW,
	// HILO
	input wire write_hiloW
    );
	
	//取指
	wire stallF;
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
	//访存
	wire [4:0] writeregM;
	wire [63:0] hilo_inM;
	//回写
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [63:0] hilo_inW;
	wire [63:0] hilo_regW;
	wire forward_hilo_E;

	//冒险模块
	hazard h(
		//取指
		stallF,
		//译码
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,
		//执行
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,
		forward_hilo_E,
		//访存
		writeregM,
		regwriteM,
		memtoregM,
		write_hiloM,
		//回写
		writeregW,
		regwriteW
		);

	//下一PC值确定 先确定+4 or branch 再确定是否jump
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD,pcnextFD);

	//寄存器堆，负责读入或回写数据
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//取指
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	

	//译码 阻塞信号取反作为是能信号，控制pc不变以实现流水线暂停
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	signext se(instrD[15:0],signimmD,unsignimmD);
	sl2 immsh(signimmD,signimmshD);
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
	floprc #(32) r1E(clk,rst,flushE,srcaD,srcaE);
	floprc #(32) r2E(clk,rst,flushE,srcbD,srcbE);
	floprc #(32) r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5)  r4E(clk,rst,flushE,rsD,rsE);
	floprc #(5)  r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5)  r6E(clk,rst,flushE,rdD,rdE);
	floprc #(32) r7E(clk,rst,flushE,unsignimmD,unsignimmE);//无符号立即数拓展
	floprc #(5)  r8E(clk,rst,flushE,offsetD,offsetE);//偏移量
	//TODO 画数据通路图---
	mux2 #(32) choice_imm_is_signed(unsignimmE,signimmE,sign_extdE,final_imm);
	//----
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,final_imm,alusrcE,srcb3E);
	alu alu(srca2E,srcb3E,offsetE,alucontrolE,alu_hilo_src[63:32],alu_hilo_src[31:0],hilo_inE[63:32],hilo_inE[31:0],aluoutE);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

	//访存
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
	flopr #(64) r4M_hilo(clk,rst,hilo_inE,hilo_inM);

	//回写
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopr #(64) r4W_hilo(clk,rst,hilo_inM,hilo_inW);
	hilo_reg my_hilo_regW(clk,rst,write_hiloW,hilo_inW[63:32],hilo_inW[31:0],hilo_regW[63:32],hilo_regW[31:0]);
endmodule