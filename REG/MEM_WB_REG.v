`include "def.v"
//`define INTERNAL_BITS 32
module MEM_WB_REG(
	clk,//neg edge
	WB_in,
	WB_out,
	Address_in,
	Address_out,
	Read_data_in,
	Read_data_out,
);

	input [`INTERNAL_BITS-1:0] Address_in, Read_data_in;
	input [1:0] WB_in;//Reg write, mem to reg
	input clk;
	
	output reg [`INTERNAL_BITS-1:0] Address_out, Read_data_out;
	output reg [1:0] WB_out;

 always@(posedge clk)begin
	WB_out <= WB_in;
	Address_out <= Address_in;
	Read_data_out <= Read_data_in;
 end
endmodule
