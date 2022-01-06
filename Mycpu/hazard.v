`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	output wire stallD,flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire stall_divE,
	output reg[1:0] forwardaE,forwardbE,
	output wire stallE,flushE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	output wire stallM,flushM,
	input wire pcsrcM,jumpM,jrM,jalM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire stallW,flushW,

// 异常
    input wire except_logicM,
    input wire [31:0] excepttypeM,
    input wire [31:0] cp0_epcM,
    output reg [31:0] newpcM

    );

	wire lwstallD;
	
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
    assign branchflushM = pcsrcM;

	assign stallF = !except_logicM & (lwstallD  | (stall_divE & ~( branchflushM | jalM | jrM | jumpM)) ); //考虑一下，是否需要

	assign stallD = lwstallD  | stall_divE;
	assign flushD = except_logicM | (branchflushM | jalM | jrM | jumpM);

	assign stallE = stall_divE;
	assign flushE = except_logicM | lwstallD |  (~stall_divE &( branchflushM | jalM | jrM | jumpM)); //留下正在计算的div


	assign stallM = 0;
	assign flushM = except_logicM | stall_divE ;


	assign stallW = 0;
	assign flushW = except_logicM;


    always @(*) begin
        case (excepttypeM)
            32'h00000001,32'h00000004,32'h00000005,32'h00000008,
            32'h00000009,32'h0000000a,32'h0000000c,32'h0000000d: begin
                newpcM <= 32'hBFC00380;
            end
            32'h0000000e: newpcM <= cp0_epcM;
            default     : newpcM <= 32'hBFC00380;
        endcase
    end
		//stalling D stalls all previous stages

		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule
