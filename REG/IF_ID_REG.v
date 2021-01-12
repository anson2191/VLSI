`include "def.v"
//`define INTERNAL_BITS 32
module IF_ID_REG(
	clk,//neg edge
	rst,
	Instruction_in,
	Instruction_out,
	PC_in,
	PC_out,
);

	input [`INTERNAL_BITS-1:0] Instruction_in, PC_in;
	input clk,rst;
	
	output reg [`INTERNAL_BITS-1:0] Instruction_out, PC_out;

 always@(posedge clk or posedge rst)begin
	PC_out <= (rst)?32'b0:PC_in;
	Instruction_out <= (rst)?`NOP:Instruction_in;
 end

endmodule
