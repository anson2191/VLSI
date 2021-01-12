`include "def.v"

module Register(
	CLKA,
	rst,
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
	always@(posedge CLKA or posedge rst)
	begin
		if(rst)begin
			Read_data1 <= 32'b0;
			Read_data2 <= 32'b0;
		end
		else begin
			Read_data1 <= REG[Read_reg1];
			Read_data2 <= REG[Read_reg2];
		end
	end

	//Port B write only
	always@(posedge CLKB or posedge rst)
	begin
		if(rst)
			REG[Write_data] <= 32'b0;
		else if(Write_enable && (Write_reg!=5'b0))
			REG[Write_reg] <= Write_data;
		else
			REG[Write_reg] <= REG[Write_reg];
	end

endmodule
