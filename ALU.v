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
	parameter AND = 4'b0000,
			  OR  = 4'b0001,
			  ADD = 4'b0010,
			  SUB = 4'b0110,
			  SLT = 4'b0111,
			  NOR = 4'b1100;
	
	input [`INTERNAL_BITS-1:0] Data_in1,Data_in2;
	input [`ALUOP_BITS-1:0] ALUop;
	output [`INTERNAL_BITS-1:0] Result, Zero;
	
	always@(*) begin
		case(ALUop)
			AND:begin
				Result = Data_in1&Data_in2;//bit-wise
			end
			
			OR:begin
				Result = Data_in1|Data_in2;//bit-wise
			end
			
			ADD:begin //CLA?
				Result = Data_in1 + Data_in2;
			end
			
			SUB:begin
				
			end
			
			SLT:begin
			
			end
			
			NOR:begin
			
			end
			
			default:begin
			
			end			
		endcase
	end
	
endmodule
