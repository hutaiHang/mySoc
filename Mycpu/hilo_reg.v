`timescale 1ns / 1ps

module hilo_reg(
	// input
    input wire clk,
    input wire rst,
    input wire we,  // 写使能
    input wire [31:0] hi_input, // 输入的hi值
    input wire [31:0] lo_input, // 输入的lo值

    // output
    output reg [31:0] hi_output, // 输出的hi值
    output reg [31:0] lo_output  // 输出的lo值
    );

    always @(negedge clk) begin
        if (rst) begin
            hi_output <= 0;
            lo_output <= 0;
        end
        else if (we) begin
            hi_output <= hi_input;
            lo_output <= lo_input;
        end
    end

endmodule
