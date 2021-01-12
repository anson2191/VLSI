`include "dev.v"
//`define REGISTER_BITS 5

module Hazard_detection_unit(IF_ID_RS,
							 IF_ID_RT,
							 ID_EX_RT,
							 ID_EX_RD,
							 ID_EX_MemRead,
							 ID_EX_RegWrite,
							 branch,
							 EX_MEM_RT,
							 Hold,
							 ID_Flush,
							 EX_Flush
							 );
	
	input ID_EX_MemRead, ID_EX_RegWrite, branch;
	input [REGISTER_BITS-1:0] IF_ID_RS, IF_ID_RT, ID_EX_RT, ID_EX_RD;
	output Hold, ID_Flush, EX_Flush;
	
	//data hazard for lw , RT is the destination of lw
	always(*)
	begin
		if(ID_EX_MemRead) begin //lw before R-type or lw before branch
			EX_Flush = 1'b0;
			if( (IF_ID_RS==ID_EX_RT) || (IF_ID_RT==ID_EX_RT) ) begin
				Hold = 1'b1;
				ID_Flush = 1'b1; //ID_EX_MemRead = 0 next cycle
			end
			else begin
				Hold = 1'b0;
				ID_Flush = 1'b0;
			end
		end
		else if(EX_MEM_MemRead && branch) begin //lw before before branch
			if( (IF_ID_RS==EX_MEM_RT) || (IF_ID_RT==EX_MEM_RT) ) begin
				Hold = 1'b1;
				EX_Flush = 1'b1;
			end
			else begin
				Hold = 1'b0;
				EX_Flush = 1'b0;
			end
		end
		
	end
	
	//data hazard for R-type before branch
	always@(*)
	begin
		EX_Flush = 1'b0;
		if(ID_EX_RegWrite) begin
			if( (IF_ID_RS==ID_EX_RD) || (IF_ID_RT==ID_EX_RD)) begin
				Hold = 1'b1;
				ID_Flush = 1'b1;
			end
			else begin
				Hold = 1'b0;
				ID_Flush = 1'b0;
			end
		end
		else begin
			Hold = 1'b0;
			ID_Flush = 1'b0;
		end
	end
endmodule
