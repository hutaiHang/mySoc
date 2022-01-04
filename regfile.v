`timescale 1ns / 1ps

module regfile(
	// input
	input wire clk,
	input wire we3,
	input wire[4:0] ra1,ra2,wa3,
	input wire[31:0] wd3,
	// 新增信号
	input wire write_m,	// 为1, 写普通的寄存器;为0写特殊寄存器
	input wire write_hi, // 为1, 写HI;为0写LO寄存器
	input wire read_m, // 为1,读普通寄存器;为0,读特殊寄存器
	input wire read_hi, // 为1, 读HI寄存器;为0读LO寄存器

	// output
	output wire[31:0] rd1,rd2
    );

	reg [31:0] rf[31:0];
	
	reg HI[31:0];
	reg LO[31:0];

	always @(negedge clk) begin
		if (we3 && ~write_m && write_hi) begin
			HI <= wd3;
		end
		else if (we3 && ~write_m && ~write_hi) begin
			LO <= wd3;
		end
	end

	always @(negedge clk) begin
		if(we3 && write_m) begin
			 rf[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 != 0) ? 
			(read_m == 1)? rf[ra1] :
			(read_hi == 1)? HI : LO
			: 0;
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule
