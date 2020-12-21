`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 100 //Max cycle number

`include "Instruction_memory.v"
`include "def.v"

module Instruction_memory_tb;

	//parameters
	parameter ADDR_BITS = 10;

	//inputs
	reg clk;
	reg [ADDR_BITS-1:0] address;

	//outputs
	wire [`DATA_BITS-1:0] instruction;

	Instruction_memory mem(
		.clk(clk),
		.address(address),
		.instruction(instruction)
	);
	defparam mem.ADDR_BITS = 10;
	defparam mem.MEM_SIZE = 1024;
	
	initial clk = 1'b0;
	always #(`CYCLE/2) clk = ~clk;

	integer i;

	initial
	begin
		for(i=0;i<100;i=i+1)
		begin
			mem.Memory[i] = i;
		end
		address = 0;
		for(i=0;i<100;i=i+1)
		begin
			#(`CYCLE) address = i;
		end

		#(`CYCLE) $finish;
	end
	
	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("Instruction_memory.fsdb");
			$fsdbDumpvars(0,mem,"+struct");
		`endif
	end

endmodule
