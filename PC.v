`include "def.v"
//`define INTERNAL_BITS 32
//`define DATA_BITS 32
module PC(
	in,
	hold,
	out
	);

	input [`PC_BITS-1:0] in;
	input hold;
	output reg [`PC_BITS-1:0] out;
	
	always@(*) begin
		if(hold)
			out = out;
		else
			out = in;
	end

endmodule
