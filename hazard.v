`timescale 1ns / 1ps


module hazard(
	//取指
	output wire stallF,
	//译码
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,
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

	//回写
	input wire[4:0] writeregW,
	input wire regwriteW
    );

	wire lwstallD,branchstallD;

	// 前推信号 HILO
	assign forward_hilo_E = write_hiloM;

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

	assign #1 stallE = div_stallE;
	assign #1 stallD = lwstallD | branchstallD | div_stallE;
	assign #1 stallF = stallD; //取指阶段阻塞
		
	assign #1 flushE = stallD; //执行阶段阻塞
	
endmodule
