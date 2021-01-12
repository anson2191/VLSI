`include "def.v"

module Instruction_memory(
	clk,
	address,
	instruction
);

	//parameters
	parameter ADDR_BITS = 10;
	parameter MEM_SIZE = 1024;

	input clk;
	input [ADDR_BITS-1:0] address;
	output [`DATA_BITS-1:0] instruction;

	reg [`DATA_BITS-1:0] Memory [0:MEM_SIZE-1];
	reg [`DATA_BITS-1:0] latched_output;

	always@(posedge clk)
	begin
		latched_output <= Memory[address];
	end

	assign instruction = latched_output;

endmodule
