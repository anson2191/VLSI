//=========================================
//Author:		Chen Yun-Ru (May)
//Filename:		TwoPort_SRAM.v
//Description:	Two-Port SRAM
//Version:		0.1
//=========================================
`include "def.v"

module Data_memory(
	CLKA,
	CLKB,
	Read_enable,
	Write_enable,
	Address,
	Write_data,
	Data_out
);//two port sram

	//parameters
	parameter ADDR_BITS = 13;
	parameter MEM_SIZE = 8192;

	input CLKA,CLKB;
	input Read_enable,Write_enable;
	input [ADDR_BITS-1:0] Address;
	input [`INTERNAL_BITS-1:0] Write_data;
	output [`INTERNAL_BITS-1:0] Data_out;

	reg [`INTERNAL_BITS-1:0] Memory [0:MEM_SIZE-1];
	reg [`INTERNAL_BITS-1:0] Data_out;

	//Port A read only
	always@(posedge CLKA)
	begin
		if(Read_enable)
			Data_out <= Memory[Address];
		else;
	end

	//Port B write only
	always@(posedge CLKB)
	begin
		if(Write_enable)
		begin
			Memory[Address] <= Write_data;
		end
		else;
	end

endmodule
