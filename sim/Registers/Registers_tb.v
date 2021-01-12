`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 100 //Max cycle number

`include "Registers.v"
`include "def.v"

module Registers_tb;

	//parameters
	parameter ADDR_BITS = 5;

	//inputs
	reg CLK;
	reg Write_enable;
	reg [ADDR_BITS-1:0] Read_reg1,Read_reg2,Write_reg;
	reg [`INTERNAL_BITS-1:0] Write_data;

	//outputs
	wire [`INTERNAL_BITS-1:0] Read_data1,Read_data2;

	Registers r(
		.CLKA(CLK),
		.CLKB(CLK),
		.Write_enable(Write_enable),
		.Read_reg1(Read_reg1),
		.Read_reg2(Read_reg2),
		.Write_reg(Write_reg),
		.Read_data1(Read_data1),
		.Read_data2(Read_data2),
		.Write_data(Write_data),
		.Read_data1(Read_data1),
		.Read_data2(Read_data2)
	);

	initial CLK = 0;
	always #(`CYCLE/2) CLK = ~CLK;

	integer i;

	initial
	begin
		for(i=0;i<32;i=i+1)
			r.REG[i] = i;

		Write_enable = 0;
		Read_reg1 = 0;
		//read test
		for(i=0;i<32;i=i+1)
			#(`CYCLE) Read_reg1 = i;

		//write test
		for(i=0;i<32;i=i+1)
		begin
			#(`CYCLE) Write_reg=i; Write_data=100-i; Write_enable=1;
		end
		//read test
		#(`CYCLE) Write_enable=0;
		for(i=0;i<32;i=i+1)
			#(`CYCLE) Read_reg1 = i;
		#(`CYCLE) $finish;
	end

	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("Registers.fsdb");
			$fsdbDumpvars(0,r,"+struct");
		`endif
	end

endmodule
