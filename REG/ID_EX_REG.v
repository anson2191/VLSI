`include "def.v"
//`define INTERNAL_BITS 32
module ID_EX_REG(
	clk,//neg edge
	EX_in,
	WB_in,
	M_in,
	EX_out,
	WB_out,
	M_out,
	Read_data1_in,
	Read_data2_in,
	Read_data1_out,
	Read_data2_out,
	Sign_extend_in,
	Sign_extend_out,
	Instruction_20_16_in,
	Instruction_15_11_in,
	Instruction_20_16_out,
	Instruction_15_11_out,
	PC_in,
	PC_out,
);

	input [`INTERNAL_BITS-1:0] Read_data1_in, Read_data2_in, Sign_extend_in, PC_in;
	input [4:0] Instruction_20_16_in, Instruction_15_11_in;
	input [3:0] EX_in;//Reg Dst, ALU Op1, ALU Op0, ALUSrc
	input [1:0] WB_in;//Reg write, mem to reg
	input [2:0] M_in;//branch, mem read, mem write
	input clk;
	
	output reg [`INTERNAL_BITS-1:0] Read_data1_out, Read_data2_out, Sign_extend_out, PC_out;
	output reg [4:0] Instruction_20_16_out, Instruction_15_11_out;
	output reg [3:0] EX_out;
	output reg [1:0] WB_out;
	output reg [2:0] M_out;
	output reg ALU_zero_out;

 always@(posedge clk)begin
	EX_out <= EX_in;
	WB_out <= WB_in;
	M_out <= M_in;
	Read_data1_out <= Read_data1_in;
	Read_data2_out <= Read_data2_in;
	Sign_extend_out <= Sign_extend_in;
	Instruction_20_16_out <= Instruction_20_16_in;
	Instruction_15_11_out <= Instruction_15_11_in;
	PC_out <= PC_in;
 end

endmodule
