`timescale 1ns/10ps

`define CYCLE 10 //Cycle time
`define MAX 100 //Max cycle number

`include "Data_memory.v"
`include "def.v"

module Data_memory_tb;

	//parameters
	parameter ADDR_BITS = 13;

	//inputs
	reg CLK;
	reg Read_enable,Write_enable;
	reg [ADDR_BITS-1:0] Address;
	reg [`INTERNAL_BITS-1:0] Write_data;

	//outputs
	wire [`INTERNAL_BITS-1:0] Data_out;

	Data_memory mem(
		.CLKA(CLK),
		.CLKB(CLK),
		.Read_enable(Read_enable),
		.Write_enable(Write_enable),
		.Address(Address),
		.Write_data(Write_data),
		.Data_out(Data_out)
	);

	initial CLK = 0;
	always #(`CYCLE/2) CLK = ~CLK;

	integer i;

	initial
	begin
		for(i=0;i<100;i=i+1)
			mem.Memory[i] = i;

		Read_enable = 1; Write_enable = 0;
		Address = 0; Data_out = 0;

		//read test
		for(i=0;i<100;i=i+1)
			#(`CYCLE) Address = i;

		//write test
		for(i=0;i<100;i=i+1)
		begin
			#(`CYCLE) Address=i; Data_out=100-i; Write_enable=1;
		end
		//read test
		#(`CYCLE) Write_enable=0;
		for(i=0;i<100;i=i+1)
			#(`CYCLE) Address = i;
		#(`CYCLE) $finish;
	end

	initial
	begin
		`ifdef FSDB
			$fsdbDumpfile("Data_out.fsdb");
			$fsdbDumpvars(0,mem,"+struct");
		`endif
	end

endmodule
