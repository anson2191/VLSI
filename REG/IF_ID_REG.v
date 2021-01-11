`include "def.v"
//`define INTERNAL_BITS 32
module IF_ID_REG(
	clk,//neg edge
	flush,
	Instruction_in,
	Instruction_out,
	PC_in,
	PC_out,
);

	input [`INTERNAL_BITS-1:0] Instruction_in, PC_in;
	input clk,flush;
	
	output reg [`INTERNAL_BITS-1:0] Instruction_out, PC_out;

 always@(posedge clk or posedge flush)begin
	PC_out <= PC_in;
	Instruction_out <= (flush)?`NOP:Instruction_in;
 end

endmodule
