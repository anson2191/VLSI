`include "def.v"

module Register(
	CLKA,
	Read_reg1,
	Read_reg2,
	Read_data1,
	Read_data2,
	CLKB,
	Write_enable,
	Write_reg,
	Write_data
);

	//parameters
	parameter ADDR_BITS = 5;
	parameter REG_SIZE = 32;

	input CLKA,CLKB;
	input Write_enable;
	input [ADDR_BITS-1:0] Read_reg1,Read_reg2,Write_reg;
	input [`INTERNAL_BITS-1:0] Write_data;
	output [`INTERNAL_BITS-1:0] Read_data1,Read_data2;

	reg [`INTERNAL_BITS-1:0] REG [0:REG_SIZE-1];

	//Port A read only
	always@(posedge CLKA)
	begin
		Read_data1 <= REG[Read_reg1];
		Read_data2 <= REG[Read_reg2];
	end

	//Port B write only
	always@(posedge CLKB)
	begin
		if(Write_enable)
			REG[Write_reg] <= Write_data;
		else;
	end

endmodule
