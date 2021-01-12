`include "def.v"
//`define INTERNAL_BITS 32
module EX_MEM_REG(
	clk,//neg edge
	flush,
	WB_in,
	M_in,
	WB_out,
	M_out,
	ALU_result_in,
	ALU_result_out,
	ALU_src2_in,
	ALU_src2_out,
	ALU_zero_in,
	ALU_zero_out,
	PC_in,
	PC_out,
	REG_dst_in,
	REG_dst_out
);

	input [`INTERNAL_BITS-1:0] ALU_result_in,ALU_src2_in,PC_in;
	input [4:0] REG_dst_in;
	input [1:0] WB_in;//Reg write, mem to reg
	input [2:0] M_in;//branch, mem read, mem write
	input ALU_zero_in,clk,flush;
	
	output reg [`INTERNAL_BITS-1:0] ALU_result_out,ALU_src2_out,PC_out;
	output reg [4:0] REG_dst_out;
	output reg [1:0] WB_out;
	output reg [2:0] M_out;
	output reg ALU_zero_out;

 always@(posedge clk or posedge flush)begin
	if(flush)begin
		WB_out <= 2'b0;
		M_out <= 3'b0;
	end
	else begin
		WB_out <= WB_in;
		M_out <= M_in;
	end
	ALU_result_out <= ALU_result_in;
	ALU_src2_out <= ALU_src2_in;
	ALU_zero_out <= ALU_zero_in;
	PC_out <= PC_in;
	REG_dst_out <= REG_dst_in;
 end

endmodule
