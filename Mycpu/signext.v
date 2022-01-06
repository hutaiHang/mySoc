`timescale 1ns / 1ps

module signext(
	// input
	input wire[15:0] a,

	// output
	output wire [31:0] y_signed,
	output wire [31:0] y_unsigned

    );

	assign y_signed = {{16{a[15]}},a};
	assign y_unsigned = { {16{1'b0}} ,a[15:0]};
endmodule
