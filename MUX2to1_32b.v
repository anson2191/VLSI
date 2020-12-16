//compiled

`include "def.v"
//`define INTERNAL_BITS 32
module MUX2to1_32b(
	Data_in1,
	Data_in2,
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2;
	input sel;
	output [`INTERNAL_BITS-1:0] Data_out;

//complete your design here

 assign Data_out=(!sel)?Data_in1:Data_in2;

endmodule
