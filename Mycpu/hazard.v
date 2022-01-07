`timescale 1ns / 1ps


module hazard(
	//取指
	output wire stallF,
	output wire flushF,
	//译码
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,flushD,
	//执行
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire div_stallE, // 除法是否阻塞流水线
	output reg[1:0] forwardaE,forwardbE,
	output wire forward_hilo_E,
	output wire flushE,
	output wire stallE,
	//访存
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire write_hiloM,
	input wire jumpM,
	input wire branchM,
	input wire pcsrcM,
	output wire stallM,
	output wire flushM,
	//回写
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire stallW,
	output wire flushW
    );

	wire lwstallD,branchstallD;
	wire jump_branchM;

	// 前推信号 HILO
	assign forward_hilo_E = write_hiloM;

	assign jump_branchM = jumpM | pcsrcM;

	//前推信号，用于branch分至比较的寄存器号确定
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	//前推信号，用于ALU数据输入的来源确定

	always @(*) 
	begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) 
		begin
			if(rsE == writeregM & regwriteM) 
			begin//此时是由于R-Type类型指令未回写完毕
				forwardaE = 2'b10;
			end 
			else if(rsE == writeregW & regwriteW) 
			begin//此时是由于lw指令未回写完毕
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) 
		begin
			if(rtE == writeregM & regwriteM) 
			begin
				forwardbE = 2'b10;
			end 
			else if(rtE == writeregW & regwriteW) 
			begin
				forwardbE = 2'b01;
			end
		end
	end

	//流水线阻塞
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);//当上条为lw指令时进行阻塞
	//当上条与这条beq指令或为lw指令时进行阻塞
	assign #1 branchstallD = branchD &
				(regwriteE & (writeregE == rsD | writeregE == rtD) 
				|
				memtoregM &(writeregM == rsD | writeregM == rtD));

	//F阶段阻塞
	assign stallF = lwstallD | div_stallE; //取指阶段阻塞
	//D阶段阻塞
	assign stallD = lwstallD | div_stallE;
	//E阶段阻塞
	assign stallE = div_stallE;
	//M阶段阻塞
	assign stallM = 0;//TODO M阶段阻塞
	//W阶段阻塞
	assign stallW = 0;//TODO W阶段阻塞

	//F阶段刷新
	assign flushF = jump_branchM;//TODO F阶段刷新
	//D阶段刷新
	assign flushD = jump_branchM;//TODO D阶段刷新
	//E阶段刷线
	assign flushE = lwstallD | ( ~div_stallE & (jump_branchM) ); 
	//M阶段刷新
	assign flushM = div_stallE;//TODO m阶段刷新目前还没出来
	//W阶段刷新
	assign flushW = 0;//TODO W阶段刷新

	
endmodule
