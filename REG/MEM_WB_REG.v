`include "def.v"
//`define INTERNAL_BITS 32
module MEM_WB_REG(
	clk,//neg edge
	rst,
	WB_in,
	WB_out,
	Address_in,
	Address_out,
	Read_data_in,
	Read_data_out,
);

	input [`INTERNAL_BITS-1:0] Read_data_in;
	input [`DATA_MEM_ADDR_BITS-1:0] Address_in;
	input [1:0] WB_in;//Reg write, mem to reg
	input clk,rst;
	
	output reg [`INTERNAL_BITS-1:0] Read_data_out;
	output reg [`DATA_MEM_ADDR_BITS-1:0] Address_out;
	output reg [1:0] WB_out;

 always@(posedge clk or posedge rst)begin
	WB_out <= (rst)?2'b0:WB_in;
	Address_out <= (rst)?13'b0:Address_in;
	Read_data_out <= (rst)?32'b0:Read_data_in;
 end
endmodule
