`include "def.v"
//`define INTERNAL_BITS 32
//`define DATA_BITS 32
module PC(
	clk,
	in,
	hold,
	out
	);

	input [`PC_BITS-1:0] in;
	input hold, clk;
	output reg [`PC_BITS-1:0] out;
	
	always@(posedge clk) begin
		if(hold)
			out <= out;
		else
			out <= in;
	end

endmodule
