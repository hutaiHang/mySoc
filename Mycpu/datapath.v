`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	output wire[5:0] opD,opE,opM,functD,
	output wire[4:0] rsD,rtD,
	//execute stage
	input wire balE,jrE,jalE,
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	output wire flushE,stallE,
	//mem stage
	input wire balM,jrM,jalM,
	input wire branchM,jumpM,
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	output wire flushM,stallM,
	//writeback stage
	output wire [31:0] pcW,
	output wire [31:0] resultW,
	output wire [4:0] writeregW,
	input wire memtoregW,
	input wire regwriteW,
	output wire flushW,stallW,
	output wire[3:0] data_sram_wenM,
	input wire hilowriteM,

	input wire invalidD,
	input wire cp0writeM,
	input wire [5:0]ext_int,
	input wire is_in_delayslotF,
	output wire except_logicM
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcbranchE,pcbranchM;
	//decode stage
	wire [31:0] pcD,pcplus4D,instrD;
	wire forwardaD,forwardbD;
	wire [4:0] rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire stall_divE;
	wire [63:0]aluout_64E;
	wire [31:0] pcE,pcplus4E,pcplus8E,instrE;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutFalseE,aluoutE;
	//mem stage
	wire [4:0] rtM,rdM;
	wire pcsrcM;
	wire [31:0] pcM,pcplus4M,instrM;
	wire [4:0] writeregM;
	wire [63:0] aluout_64M;
	wire [31:0] srca2M,srcb2M;
	//writeback stage
	wire [31:0] instrW;
	wire [31:0] aluoutW,readdataW;
	wire [31:0] readdataM_real;
	wire [31:0]writedataM_temp;
	wire syscallD,breakD,eretD;
	wire pc_exceptF,pc_exceptD;
	wire [7:0] exceptE,exceptM;
	wire overflow;
	wire adelM,adesM;
	
	wire is_in_delayslotD,is_in_delayslotE,is_in_delayslotM;


	// hilo
	wire [31:0]hi,lo;

	wire [31:0]newpcM;
	wire [31:0]bad_addr;
	wire [31:0]cp0_data_oE,count_o,compare_o,status_o,cause_o,epc_o,config_o,prid_o;
	wire [31:0]badvaddr;
	wire timer_int_o;
	wire [31:0]excepttypeM;
	assign except_logicM = (|excepttypeM);

	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		stallD,
		flushD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		stall_divE,
		forwardaE,forwardbE,
		stallE,
		flushE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		stallM,
		flushM,
		pcsrcM,jumpM,jrM,jalM,
		//write back stage
		writeregW,
		regwriteW,
		stallW,
		flushW,
		// 异常
		except_logicM,
		excepttypeM,
		epc_o,
		newpcM
		);

	//next PC logic (operates in fetch an decode)
	pc_mux pc_mux(
		jumpM,
		jalM,
		jrM,
		pcsrcM,
   		excepttypeM,
		{pcplus4M[31:28],instrM[25:0],2'b00},   //jump鍚庣殑
		srca2M, //JR		
		pcplus4F, //pc+4
		pcbranchM, //pc璺宠浆鍚庣殑
    	newpcM,
		pcnextFD
	);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD ,flushD,pcF,pcD);	
	flopenrc #(1) r4D(clk,rst,~stallD,flushD,pc_exceptF,pc_exceptD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	signext se(instrD[15:0],signimmD,instrD[29:28]);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);


	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];

	//execute stage

	floprc #(32) r1E(clk,rst,flushE,srcaD,srcaE);
	floprc #(32) r2E(clk,rst,flushE,srcbD,srcbE);
	floprc #(32) r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5) r4E(clk,rst,flushE,rsD,rsE);
	floprc #(5) r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5) r6E(clk,rst,flushE,rdD,rdE);
	flopenrc #(32) r7E(clk,rst,~stallE,flushE,instrD,instrE);
	flopenr #(32) r9E(clk,rst,~stallE,pcplus4D,pcplus4E);
	floprc #(6) r8E(clk,rst,flushE,opD,opE);
	flopenrc #(32) r10E(clk,rst,~stallE,flushE,pcbranchD,pcbranchE);
	flopenrc #(32) r11E(clk,rst,~stallE,flushE,pcD,pcE);	
	flopenrc #(8) r12E(clk,rst,~stallE,flushE,{pc_exceptD,syscallD,breakD,eretD,invalidD,3'b0},exceptE);
	flopenrc #(1) r13E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(
		.clk(clk),
		.rst(rst),
		.a(srca2E),
		.b(srcb3E),
		.sa(instrE[10:6]),
		.op(alucontrolE),
		.y(aluoutFalseE),
		.aluout_64(aluout_64E),
		.stall_div(stall_divE)
		,.hi(hi),.lo(lo),
		.overflow(overflow),
		.cp0_data_o(cp0_data_oE));
	mux3 #(5) mux3_regDst(
    .d0(rtE),
    .d1(rdE),
    .d2(5'b11111),
    .sel({balE|jalE,regdstE}),
    .y(writeregE)
    );
	assign pcplus8E = pcplus4E + 32'b00000000000000000000000000000100; 
// 鑻ユ湁寤惰繜妲斤紝鍒檒ink鍒皃c+8
	mux2 #(32) alu_pc8(
    .d0(aluoutFalseE),
    .d1(pcplus8E),
    .sel((balE | jalE) | jrE),
    .y(aluoutE)
	);

	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM_temp);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
	flopenrc #(32) r4M(clk,rst,~stallM,flushM,instrE,instrM);
	flopr #(6) r5M(clk,rst,opE,opM);
	flopenrc #(64) r6M(clk,rst,~stallM,flushM,aluout_64E,aluout_64M);
	flopenrc #(32) r7M(clk,rst,~stallM,flushM,pcplus4E,pcplus4M);
	flopenrc #(64) r8M(clk,rst,~stallM,flushM,{srca2E,srcb2E},{srca2M,srcb2M});
	flopenrc #(5) r9M(clk,rst,~stallM,flushM,rtE,rtM);
	flopenrc #(32) r10M(clk,rst,~stallM,flushM,pcE,pcM);	
	flopenrc #(32) r11M(clk,rst,~stallM,flushM,pcbranchE,pcbranchM);
	flopenrc #(8) r12M(clk,rst,~stallM,flushM,{exceptE[7:3],overflow,exceptE[1:0]},exceptM);
	flopenrc #(5) r13M(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(1) r14M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	eqcmp comp(srca2M,srcb2M,opM,rtM,equalM);
    assign pcsrcM = equalM & (branchM | balM) ;

	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM_real,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopenrc #(32) r4W(clk,rst,~stallW,flushW,instrM,instrW);
	flopenrc #(32) r5W(clk,rst,~stallW,flushW,pcM,pcW);	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	
	lsmem lsmen(opM,aluoutM,readdataM_real,readdataM,writedataM,writedataM_temp,data_sram_wenM,adelM,adesM,bad_addr,pcM);
	hilo_reg hilo_reg(.clk(clk),.rst(rst),.we(hilowriteM& ~(|excepttypeM)&~stallM),.hilo_i(aluout_64M),.hi(hi),.lo(lo));
	assign syscallD = (instrD[31:26] == 6'b000000 && instrD[5:0] == 6'b001100);
    assign breakD = (instrD[31:26] == 6'b000000 && instrD[5:0] == 6'b001101);
    assign eretD = (instrD == 32'b01000010000000000000000000011000);
    assign pc_exceptF = (pcF[1:0] == 2'b00) ? 1'b0 : 1'b1;

	wire[39:0] asciiF;
	wire[39:0] asciiD;
	wire[39:0] asciiE;
	wire[39:0] asciiM;
	wire[39:0] asciiW;
	instdec instF(.instr(instrF),.ascii(asciiF));
	instdec instD(.instr(instrD),.ascii(asciiD));
	instdec instE(.instr(instrE),.ascii(asciiE));
	instdec instM(.instr(instrM),.ascii(asciiM));
	instdec instW(.instr(instrW),.ascii(asciiW));
	
	exception exp(
    rst,
    exceptM,
    adelM,
    adesM,
    status_o,
    cause_o,
    excepttypeM
    );
    
    cp0_reg CP0(
    .clk(clk),
	.rst(rst),
    .we_i(cp0writeM & ~stallM),
	.waddr_i(rdM),  // M???д??CP0
	.raddr_i(rdE),  // E??ζ??CP0?????????????????????????
	.data_i(srcb2M),

	.int_i(ext_int),

	.excepttype_i(excepttypeM),
	.current_inst_addr_i(pcM),
	.is_in_delayslot_i(is_in_delayslotM),
	.bad_addr_i(bad_addr),

	.data_o(cp0_data_oE),
	.count_o(count_o),
	.compare_o(compare_o),
	.status_o(status_o),
	.cause_o(cause_o),
	.epc_o(epc_o),
	.config_o(config_o),
	.prid_o(prid_o),
	.badvaddr_o(badvaddr),
	.timer_int_o(timer_int_o)
    );
endmodule
