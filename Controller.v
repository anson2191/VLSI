`include "def.v"


module Controller(
	clk,
	rst,
	Instruction,
	Branch_taken,
	IF_flush,
	ID_flush,
	EX_flush,
	done,
	WB,
	M,
	EX
);

	input clk;
	input rst;
	input Branch_taken;
	input [`INTERNAL_BITS-1:0] Instruction;

	output reg done, IF_flush, ID_flush, EX_flush;
	output reg [3:0] EX;
	output reg [1:0] WB;
	output reg [2:0] M;

 	reg [1:0] state,n_state;

	parameter RESET=2'b00;
	parameter EXECUTE=2'b01;
	parameter FINISH=2'b10;

 always@(posedge clk or posedge rst)begin
	if(rst)begin
		state <= RESET;
	end
	else begin
		state <= n_state;
	end
 end
 always@(*)begin
	case(state)
	 RESET:begin
		n_state = EXECUTE;
		done = 1'b0;
		EX = 4'b0;
		WB = 2'b0;
		M = 3'b0;
		IF_flush =1'b1;
		ID_flush = 1'b1;
		EX_flush = 1'b1;
	 end
	 EXECUTE:begin
		n_state = (Instruction==`HLT)?FINISH:EXECUTE;
		done = 1'b0;
		ID_flush = 1'b0;
		EX_flush = 1'b0;
		IF_flush = (Branch_taken&&(Instruction[`OPCODE]==`BEQ))?1'b1:1'b0;
		case(Instruction[`OPCODE])
			`RTYPE:begin
				if(Instruction==`NOP)begin
					EX = 4'b0000;
					M = 3'b000;
					WB = 2'b00;
				end
				else if(Instruction==`SYSCALL)begin
					EX = 4'b0000;
					M = 3'b000;
					WB = 2'b00;
				end
				else begin
					EX = 4'b1100;
					M = 3'b000;
					WB = 2'b10;
				end
			end
			`ADDI:begin
				EX = 4'b0001;
				M = 3'b000;
				WB = 2'b10;
			end
			`SUBI:begin
				EX = 4'b0001;
				M = 3'b000;
				WB = 2'b10;
			end
			`LW:begin
				EX = 4'b0001;
				M = 3'b010;
				WB = 2'b11;
			end
			`SW:begin
				EX = 4'b0001;
				M = 3'b001;
				WB = 2'b00;
			end
			`BEQ:begin
				EX = 4'b0010;
				M = 3'b100;
				WB = 2'b00;
			end
			`JMP:begin
				EX = 4'b0000;
				M = 3'b000;
				WB = 2'b00;
			end
			default:begin
				EX = 4'b0000;
				M = 3'b000;
				WB = 2'b00;
			end
		endcase
	 end
	 FINISH:begin
		n_state = FINISH;
		IF_flush =1'b1;
		ID_flush = 1'b1;
		EX_flush = 1'b1;
		EX = 4'b0;
		WB = 2'b0;
		M = 3'b0;
		done = 1'b1;
	 end
	 default:begin
		n_state = RESET;
		done = 1'b0;
		EX = 4'b0;
		WB = 2'b0;
		M = 3'b0;
		IF_flush =1'b1;
		ID_flush = 1'b1;
		EX_flush = 1'b1;
	 end
	endcase
 end
 
endmodule
