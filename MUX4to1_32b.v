//compiled

`include "def.v"
//`define INTERNAL_BITS 32
module MUX4to1_32b(
	Data_in1,
	Data_in2,
	Data_in3,
	Data_in4,
	sel,
	Data_out
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2,Data_in3,Data_in4;
	input [1:0] sel;
	output reg [`INTERNAL_BITS-1:0] Data_out;

//complete your design here

 always@(*)begin
	case(sel)
		2'd0:Data_out=Data_in1;
		2'd1:Data_out=Data_in2;
		2'd2:Data_out=Data_in3;
		2'd3:Data_out=Data_in4;
	endcase
 end

endmodule
