`include "def.v"
module Adder(
	in,
	Result
);

	input [`PC_BITS-1:0] in;
	output [`PC_BITS-1:0] Result;

 assign out = in + 32'd4;

endmodule
