`include "def.v"
//`define DATA_BITS 32
//`define INTERNAL_BITS 16
//`define ALUOP_BITS 4

module ALU(
	Data_in1,
	Data_in2,
	ALUop,
	Zero,
	Result
);

	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2;
	input [`ALUOP_BITS-1:0] ALUop;
	output [`INTERNAL_BITS-1:0] Result, Zero;
	
	always@(*) begin
		case(ALUop)
			
		endcase
	end
	
endmodule
