`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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

module alu(
    input wire clk,rst,
	input wire[31:0] a,b,
	input wire[4:0] sa,
	input wire[7:0] op,
	output reg[31:0] y,
	output wire [63:0]aluout_64,
	output reg stall_div,
	input [31:0] hi,
	input [31:0] lo,    
	output reg overflow,
    input [31:0] cp0_data_o,
	output wire zero
);
    wire [31:0] multa,multb;
    wire div_ready;
    reg start_div,signed_div;
    wire [63:0] div_result;
    reg [63:0] temp_aluout_64;
    assign multa = (op == `EXE_MULT_OP) && (a[31] == 1'b1) ? (~a + 1) : a;
    assign multb = (op == `EXE_MULT_OP) && (b[31] == 1'b1) ? (~b + 1) : b;
    assign aluout_64 = (div_ready) ?  div_result : temp_aluout_64;
    
	always @(*) begin
	    stall_div = 1'b0;
        overflow = 1'b0;
        start_div = `DivStop;
        signed_div =1'b0;
		case(op)
            `EXE_MFHI_OP :y = hi;
            `EXE_MTHI_OP :temp_aluout_64 <= {a,lo};
            `EXE_MFLO_OP :y = lo;
            `EXE_MTLO_OP :temp_aluout_64 <= {hi,a};    
			`EXE_AND_OP: y = a & b;
			`EXE_ANDI_OP: y = a & b;
			`EXE_OR_OP : y = a | b;
			`EXE_ORI_OP : y = a | b;
			`EXE_NOR_OP: y = ~ (a | b);
			`EXE_XOR_OP: y = a ^ b;
			`EXE_XORI_OP: y = a ^ b;
			`EXE_LUI_OP: y = { b[15:0] , 16'b0 };  

			`EXE_SLL_OP   : y = b << sa[4:0];
            `EXE_SLLV_OP: y = b << a[4:0];
            `EXE_SRL_OP: y = b >> sa[4:0];
            `EXE_SRLV_OP: y = b >> a[4:0];
            `EXE_SRA_OP: y = $signed(b) >>> sa[4:0];
            `EXE_SRAV_OP: y = $signed(b) >>> a[4:0];
            
            `EXE_LB_OP   :y = a + b;
		    `EXE_LBU_OP  :y = a + b;
            `EXE_LH_OP   :y = a + b;
            `EXE_LHU_OP  :y = a + b;
            `EXE_LW_OP   :y = a + b;
            `EXE_SB_OP   :y = a + b;
            `EXE_SH_OP   :y = a + b;
            `EXE_SW_OP   :y = a + b;
            
            `EXE_ADD_OP  :begin
               y = a + b; 
               overflow = (a[31] == b[31]) & (y[31] != a[31]);
            end
            `EXE_ADDU_OP :y = a + b;
            `EXE_SUB_OP  :begin 
                y = a - b;
                overflow = (a[31]^b[31]) & (y[31]==b[31]);
            end
            `EXE_SUBU_OP :y = a - b;
            `EXE_SLT_OP  :y = $signed(a) < $signed(b);
            `EXE_SLTU_OP :y = a < b;
            `EXE_MULT_OP :temp_aluout_64 = (a[31]^b[31]==1'b1)? ~(multa * multb) + 1 :  multa * multb; 
            `EXE_MULTU_OP:temp_aluout_64 = a * b;
            `EXE_DIV_OP  :begin
                if(div_ready ==1'b0) begin
                    start_div <= `DivStart;
                    signed_div <=1'b1;
                    stall_div <=1'b1;
                end else if (div_ready == 1'b1) begin
                    start_div <= `DivStop;
                    signed_div <=1'b1;
                    stall_div <=1'b0;
                end 
            end
            `EXE_DIVU_OP :begin
                if(div_ready ==1'b0) begin
                    start_div <= 1'b1;
                    signed_div <= 1'b0;
                    stall_div <=1'b1;
                end else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    signed_div <=1'b0;
                    stall_div <=1'b0;
                end else begin
                    start_div <= 1'b0;
                    signed_div <=1'b0;
                    stall_div <=1'b0;
                end
            end
            `EXE_ADDI_OP :begin
                y = a + b;
                overflow = (a[31] == b[31]) & (y[31] != a[31]);
            end
            `EXE_ADDIU_OP:y = a + b;
            `EXE_SLTI_OP :begin//y = a < b;
                case(a[31])
                    1'b1: begin
                        if(b[31] == 1'b1) begin
                            y = a < b;
                        end
                        else begin
                            y = 1'b1;
                        end
                    end
                    1'b0: begin
                        if(b[31] == 1'b1) begin
                            y = 1'b0;
                        end
                        else begin
                            y = a < b;
                        end
                    end
                endcase
            end
            `EXE_SLTIU_OP:y = a < b;
            `EXE_MFC0_OP: y = cp0_data_o;
			default : y = 32'b0;
		endcase
	end
	
	div mydiv(
        .clk(clk),
        .rst(rst),
        .ena(~stall_div),
        .signed_div_i(signed_div), 
        .opdata1_i(a),
        .opdata2_i(b),
        
        .start_i(start_div),
        .annul_i(1'b0),
        .result_o(div_result),
        .ready_o(div_ready)
);

endmodule