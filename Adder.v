`include "def.v"
//`define PC_BITS 32
module Adder(
	Data_in1,
	Data_in2,
	Result
);

	input [`PC_BITS-1:0] Data_in1,Data_in2;
	output [`PC_BITS-1:0] Result;

 assign out = Data_in1 + Data_in2;

endmodule
