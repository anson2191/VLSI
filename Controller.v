`include "def.v"


module Controller(
	clk,
	rst,
	START,
	DONE,
	//ROM
	ROM_IM_CS,ROM_W_CS,ROM_B_CS,//(V)
	ROM_IM_OE,ROM_W_OE,ROM_B_OE,//(V)
	ROM_IM_A,ROM_W_A,ROM_B_A,//(V)
	//SRAM
	SRAM_CENA,SRAM_CENB,//(V)
	SRAM_WENB,//(V)
	SRAM_AA,SRAM_AB,//(V)
	//PE
	PE1_IF_w,PE2_IF_w,PE3_IF_w,//(V)
	PE1_W_w,PE2_W_w,PE3_W_w,//(V)
	//Pooling
	Pool_en,//(V)
	//Decoder
	Decode_en,//(V)
	//Adder
	Adder_mode,//(V)
	//MUX
	MUX1_sel,MUX2_sel,MUX3_sel//(V)
);

	input clk;//(V)
	input rst;//(V)
	input START;//(V)

	output reg DONE;//(V)
	output reg ROM_IM_CS,ROM_W_CS,ROM_B_CS;//(V)
	output reg ROM_IM_OE,ROM_W_OE,ROM_B_OE;//(V)
	output reg [`ROM_IM_ADDR_BITS-1:0] ROM_IM_A;//(V)
	output reg [`ROM_W_ADDR_BITS-1:0] ROM_W_A;//(V)
	output reg [`ROM_B_ADDR_BITS-1:0] ROM_B_A;//(V)
	output reg SRAM_CENA,SRAM_CENB;//(V)
	output reg SRAM_WENB;//(V)
	output reg [`SRAM_ADDR_BITS-1:0] SRAM_AA,SRAM_AB;//(V)
	output reg PE1_IF_w,PE2_IF_w,PE3_IF_w;//(V)
	output reg PE1_W_w,PE2_W_w,PE3_W_w;//(V)
	output reg Pool_en;//(V)
	output reg Decode_en;//(V)
	output reg [1:0] Adder_mode;//(V)
	output reg [1:0] MUX2_sel;//(V)
	output reg MUX1_sel,MUX3_sel;//(V)
	

 	reg [5:0]  state,n_state;

	reg [19:0] channel;
	reg [19:0] filter_weight;
	reg [19:0] bias;

	reg	[2:0] tsel_if, tsel_w;

	reg	[19:0] column;
 	reg [19:0] row;
  	reg [3:0]	counter;
	
	

	parameter RESET=6'b000_000;
	parameter FINISH=6'b000_001;

	parameter CONV0_INIT=6'b001_000,CONV0_READ_W=6'b001_001,CONV0_WRITE=6'b001_010,CONV0_READ_C=6'b001_011,CONV0_READ_9=6'b001_100,CONV0_NOP=6'b001_101,CONV0_DONE=6'b001_110;

	parameter POOLING1_INIT=6'b010_000,POOLING1_READ=6'b010_001,POOLING1_WRITE=6'b010_010,POOLING1_DONE=6'b010_011;
	
	//parameter CONV2_INIT=6'b011_000,CONV2_READ_9=6'b011_001,CONV2_WRITE=6'b011_010,CONV2_NOP=6'b011_011,CONV2_DONE=6'b011_100;
	parameter CONV2_INIT=6'b001_000,CONV2_READ_W=6'b001_001,CONV2_WRITE=6'b001_010,CONV2_READ_C=6'b001_011,CONV2_READ_9=6'b001_100,CONV2_NOP=6'b001_101,CONV2_DONE=6'b001_110;

	//parameter FC_INIT,FC_READ_2,DECODE,WRITE;
	
 always@(posedge clk or posedge rst or posedge START)begin//state,col,row,counter,c0_filter
 if(rst)begin
	state<=RESET;
	
	filter_weight<=20'd0;
	column<=20'd0;
	row<=20'd0;
	counter<=4'd0;
	bias<=20'd0;
	channel<=20'd0;
 end
 else begin
	state<=(START)?CONV0_INIT:n_state;
	case(state)
//----------------------------------------------CONV0--------------------------------------------------
		CONV0_INIT:begin
			column<=20'd0;
			row<=20'd0;
			counter<=4'd0;
			filter_weight<=filter_weight;
			channel<=channel;
			bias<=bias;
		end
		CONV0_READ_W:begin
			counter<=(counter==4'd8)?4'd2:counter+4'd1;
			case(counter)
				4'd2:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd5:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd8:begin
					column<=column;
					row<=row;
				end
				default:begin
					column<=column+20'd1;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV0_WRITE:begin
			case(n_state)
				CONV0_READ_C:begin
					counter<=counter;
					column<=column+20'd1;
					row<=row-20'd2;
				end
				CONV0_READ_9:begin
					counter<=counter;
					column<=20'd0;
					row<=row-20'd1;
				end
				default:begin
					counter<=counter;
					column<=column;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV0_READ_C:begin
			if(n_state==CONV0_READ_C)counter<=(counter==4'd8)?4'd2:counter+4'd3;
			else begin
				if(column==20'd29)counter<=(counter==4'd8)?4'd0:counter+4'd3;
				else counter<=(counter==4'd8)?4'd2:counter+4'd3;
			end
			column<=column;
			case(counter)
				4'd2:begin
					row<=row+20'd1;
				end
				4'd5:begin
					row<=row+20'd1;
				end
				4'd8:begin
					row<=row;
				end
				default:begin
					row<=row+20'd1;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV0_READ_9:begin
			counter<=(counter==4'd8)?4'd2:counter+4'd1;
			case(counter)
				4'd2:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd5:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd8:begin
					column<=column;
					row<=row;
				end
				default:begin
					column<=column+20'd1;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV0_NOP:begin
			counter<=counter;
			column<=column;
			row<=row;
			channel<=channel;
			filter_weight<=filter_weight;
			bias<=bias;
		end
		CONV0_DONE:begin
			counter<=4'd0;
			column<=column;
			row<=row;
			filter_weight<=(filter_weight==20'd5)?20'd0:filter_weight+20'd1;
			bias<=(bias==20'd5)?20'd0:bias+20'd1;
			channel<=channel;
		end
//------------------------------------------------------CONV0------------------------------------------------------------------
//-----------------------------------------------------POOLING1----------------------------------------------------------------
		POOLING1_INIT:begin
			counter<=4'd0;
			column<=20'd0;
			row<=20'd0;
			channel<=channel;
			bias<=bias;
			filter_weight<=filter_weight;
		end
		POOLING1_READ:begin
			counter<=counter+4'd1;
			case(counter)
				4'd0:begin
					column<=column+20'd1;
					row<=row;
				end
				4'd1:begin
					column<=column-20'd1;
					row<=row+20'd1;
				end
				4'd2:begin
					column<=column+20'd1;
					row<=row;
				end
				4'd3:begin
					column<=column;
					row<=row;
				end
				default:begin
					column<=column+20'd1;
					row<=row;
				end
			endcase
			channel<=channel;
			bias<=bias;
			filter_weight<=filter_weight;
		end
		POOLING1_WRITE:begin
			counter<=4'd0;
			column<=(column==20'd27)?20'd0:column+20'd1;
			row<=(column==20'd27)?row+20'd1:row-20'd1;
			channel<=channel;
			bias<=bias;
			filter_weight<=filter_weight;
		end
		POOLING1_DONE:begin
			counter<=4'd0;
			column<=20'd0;
			row<=20'd0;
			channel<=channel;
			bias<=(bias==20'd5)?20'd0:bias;
			filter_weight<=(filter_weight==20'd5)?20'd0:filter_weight;
		end
//-----------------------------------------------------POOLING1----------------------------------------------------------------
//------------------------------------------------------CONV2------------------------------------------------------------------
		CONV2_INIT:begin
			column<=20'd0;
			row<=20'd0;
			counter<=4'd0;
			filter_weight<=filter_weight;
			channel<=channel;
			bias<=bias;
		end
		CONV2_READ_W:begin
			counter<=(counter==4'd8)?4'd2:counter+4'd1;
			case(counter)
				4'd2:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd5:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd8:begin
					column<=column;
					row<=row;
				end
				default:begin
					column<=column+20'd1;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV2_WRITE:begin
			case(n_state)
				CONV2_READ_C:begin
					counter<=counter;
					column<=column+20'd1;
					row<=row-20'd2;
				end
				CONV2_READ_9:begin
					counter<=counter;
					column<=20'd0;
					row<=row-20'd1;
				end
				default:begin
					counter<=counter;
					column<=column;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV2_READ_C:begin
			if(n_state==CONV2_READ_C)counter<=(counter==4'd8)?4'd2:counter+4'd3;
			else begin
				if(column==20'd13)counter<=(counter==4'd8)?4'd0:counter+4'd3;
				else counter<=(counter==4'd8)?4'd2:counter+4'd3;
			end
			column<=column;
			case(counter)
				4'd2:begin
					row<=row+20'd1;
				end
				4'd5:begin
					row<=row+20'd1;
				end
				4'd8:begin
					row<=row;
				end
				default:begin
					row<=row+20'd1;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV2_READ_9:begin
			counter<=(counter==4'd8)?4'd2:counter+4'd1;
			case(counter)
				4'd2:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd5:begin
					column<=20'd0;
					row<=row+20'd1;
				end
				4'd8:begin
					column<=column;
					row<=row;
				end
				default:begin
					column<=column+20'd1;
					row<=row;
				end
			endcase
			filter_weight<=filter_weight;
			bias<=bias;
			channel<=channel;
		end
		CONV2_NOP:begin
			counter<=counter;
			column<=column;
			row<=row;
			channel<=channel;
			filter_weight<=filter_weight;
			bias<=bias;
		end
		CONV2_DONE:begin
			counter<=4'd0;
			column<=column;
			row<=row;
			if(channel==20'd5)filter_weight<=(filter_weight==20'd14)?20'd0:filter_weight+20'd1;
			else filter_weight<=filter_weight;
			if(channel==20'd5)bias<=(bias==20'd14)?20'd0:bias+20'd1;
			else bias<=bias;
			channel<=(channel==20'd5)?20'd0:channel+20'd1;
		end
//------------------------------------------------------CONV2------------------------------------------------------------------
		default:begin
			counter<=counter;
			column<=column;
			row<=row;
			channel<=channel;
			bias<=bias;
			filter_weight<=filter_weight;
		end
	endcase
 end
 end
 always@(counter or state or column or row)begin//sel,nstate
	case(state)
//------------------------------------------------------CONV0------------------------------------------------------------------
		RESET:begin
			n_state=RESET;
			tsel_if=3'b0;
			tsel_w=3'b0;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_INIT:begin
			n_state=CONV0_READ_W;
			tsel_if=3'b0;
			tsel_w=3'b0;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_READ_W:begin
			n_state=(counter==4'd8)?CONV0_NOP:CONV0_READ_W;
				case(counter)
				4'd6:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd7:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd8:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd3:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd4:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd5:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd0:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				4'd1:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				4'd2:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				default:begin
					tsel_if=3'b000;
					tsel_w=3'b000;
				end
			endcase
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_WRITE:begin
			if(column==20'd29&&row==20'd29)n_state=CONV0_DONE;
			else if(column==20'd29&&row<20'd29)n_state=CONV0_READ_9;
			else n_state=CONV0_READ_C;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_READ_C:begin
			n_state=(counter==4'd8)?CONV0_NOP:CONV0_READ_C;
			case(counter)
				4'd8:begin
					tsel_if=3'b100;
				end
				4'd5:begin
					tsel_if=3'b010;
				end
				4'd2:begin
					tsel_if=3'b001;
				end
				default:begin
					tsel_if=3'b000;
				end
			endcase
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_READ_9:begin
			n_state=(counter==4'd8)?CONV0_NOP:CONV0_READ_9;
			case(counter)
				4'd6:begin
					tsel_if=3'b100;
				end
				4'd7:begin
					tsel_if=3'b100;
				end
				4'd8:begin
					tsel_if=3'b100;
				end
				4'd3:begin
					tsel_if=3'b010;
				end
				4'd4:begin
					tsel_if=3'b010;
				end
				4'd5:begin
					tsel_if=3'b010;
				end
				4'd0:begin
					tsel_if=3'b001;
				end
				4'd1:begin
					tsel_if=3'b001;
				end
				4'd2:begin
					tsel_if=3'b001;
				end
				default:begin
					tsel_if=3'b000;
				end
			endcase
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_NOP:begin
			n_state=CONV0_WRITE;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV0_DONE:begin
			n_state=(filter_weight==20'd5)?POOLING1_INIT:CONV0_INIT;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd1;
			Adder_mode=2'd2;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
//------------------------------------------------------CONV0------------------------------------------------------------------
//-----------------------------------------------------POOLING1----------------------------------------------------------------
		POOLING1_INIT:begin
			n_state=POOLING1_READ;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd2;
			MUX3_sel=1'd1;
			Adder_mode=2'd0;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		POOLING1_READ:begin
			n_state=(counter==4'd3)?POOLING1_WRITE:POOLING1_READ;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd2;
			MUX3_sel=1'd1;
			Adder_mode=2'd0;
			Pool_en=1'b1; 
			Decode_en=1'b0;
		end
		POOLING1_WRITE:begin
			n_state=(row==20'd27&&column==20'd27)?POOLING1_DONE:POOLING1_READ;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd2;
			MUX3_sel=1'd1;
			Adder_mode=2'd0;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		POOLING1_DONE:begin
			n_state=FINISH;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd2;
			MUX3_sel=1'd1;
			Adder_mode=2'd0;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
//-----------------------------------------------------POOLING1----------------------------------------------------------------
//------------------------------------------------------CONV2------------------------------------------------------------------
		CONV2_INIT:begin
			n_state=CONV2_READ_W;
			tsel_if=3'b0;
			tsel_w=3'b0;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_READ_W:begin
			n_state=(counter==4'd8)?CONV2_NOP:CONV2_READ_W;
				case(counter)
				4'd6:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd7:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd8:begin
					tsel_if=3'b100;
					tsel_w=3'b100;
				end
				4'd3:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd4:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd5:begin
					tsel_if=3'b010;
					tsel_w=3'b010;
				end
				4'd0:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				4'd1:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				4'd2:begin
					tsel_if=3'b001;
					tsel_w=3'b001;
				end
				default:begin
					tsel_if=3'b000;
					tsel_w=3'b000;
				end
			endcase
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_WRITE:begin
			if(column==20'd29&&row==20'd29)n_state=CONV2_DONE;
			else if(column==20'd29&&row<20'd29)n_state=CONV2_READ_9;
			else n_state=CONV2_READ_C;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_READ_C:begin
			n_state=(counter==4'd8)?CONV2_NOP:CONV2_READ_C;
			case(counter)
				4'd8:begin
					tsel_if=3'b100;
				end
				4'd5:begin
					tsel_if=3'b010;
				end
				4'd2:begin
					tsel_if=3'b001;
				end
				default:begin
					tsel_if=3'b000;
				end
			endcase
			tsel_w=3'b000;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_READ_9:begin
			n_state=(counter==4'd8)?CONV2_NOP:CONV2_READ_9;
			case(counter)
				4'd6:begin
					tsel_if=3'b100;
				end
				4'd7:begin
					tsel_if=3'b100;
				end
				4'd8:begin
					tsel_if=3'b100;
				end
				4'd3:begin
					tsel_if=3'b010;
				end
				4'd4:begin
					tsel_if=3'b010;
				end
				4'd5:begin
					tsel_if=3'b010;
				end
				4'd0:begin
					tsel_if=3'b001;
				end
				4'd1:begin
					tsel_if=3'b001;
				end
				4'd2:begin
					tsel_if=3'b001;
				end
				default:begin
					tsel_if=3'b000;
				end
			endcase
			tsel_w=3'b000;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_NOP:begin
			n_state=CONV2_WRITE;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
		CONV2_DONE:begin
			n_state=(filter_weight==20'd5)?FINISH:CONV2_INIT;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd1;
			MUX2_sel=2'd0;
			MUX3_sel=(channel==20'd0)?1'd0:1'd1;
			Adder_mode=(channel==20'd0)?2'd2:2'd1;
			Pool_en=1'b0; 
			Decode_en=1'b0;
		end
//------------------------------------------------------CONV2------------------------------------------------------------------
//-----------------------------------------------------POOLING3----------------------------------------------------------------

//-----------------------------------------------------POOLING3----------------------------------------------------------------
		default:begin
			n_state=RESET;
			tsel_if=3'b000;
			tsel_w=3'b000;
			MUX1_sel=1'd0;
			MUX2_sel=2'd0;
			MUX3_sel=1'd0;
			Adder_mode=2'd0;
			Pool_en=1'b1; 
			Decode_en=1'b0;
		end
	endcase
 end
//------------------------------------------------------CONV0------------------------------------------------------------------

 always@(*)begin//ROM addr,ROM oe,RAM addr,RAM oe
	case(state)
		CONV0_INIT:begin

			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_IM_A=20'd0;
			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);//filter*9
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);//filter*784

		end
		CONV0_READ_W:begin
			ROM_IM_CS=1'b1;//
			ROM_W_CS=1'b1;//
			ROM_B_CS=1'b1;//

			ROM_IM_OE=1'b1;//
			ROM_W_OE=1'b1;//
			ROM_B_OE=1'b1;//

			case(counter)//
				4'd0:ROM_IM_A=20'd1;
				4'd1:ROM_IM_A=20'd2;
				4'd2:ROM_IM_A=20'd30;
				4'd3:ROM_IM_A=20'd31;
				4'd4:ROM_IM_A=20'd32;
				4'd5:ROM_IM_A=20'd60;
				4'd6:ROM_IM_A=20'd61;
				4'd7:ROM_IM_A=20'd62;
				default:ROM_IM_A=20'dz;
			endcase
			case(counter)
				4'd0:ROM_W_A=20'd1+(filter_weight<<3)+(filter_weight);
				4'd1:ROM_W_A=20'd2+(filter_weight<<3)+(filter_weight);
				4'd2:ROM_W_A=20'd3+(filter_weight<<3)+(filter_weight);
				4'd3:ROM_W_A=20'd4+(filter_weight<<3)+(filter_weight);
				4'd4:ROM_W_A=20'd5+(filter_weight<<3)+(filter_weight);
				4'd5:ROM_W_A=20'd6+(filter_weight<<3)+(filter_weight);
				4'd6:ROM_W_A=20'd7+(filter_weight<<3)+(filter_weight);
				4'd7:ROM_W_A=20'd8+(filter_weight<<3)+(filter_weight);
				//4'd8:ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
				//default:ROM_W_A=20'd1+(filter_weight<<3)+(filter_weight);
				default:ROM_W_A=20'dz;
			endcase
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);//filter*28*28(784)

		end
		CONV0_WRITE:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;
			
			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			case(n_state)
				CONV0_READ_C:ROM_IM_A=column+20'd1+((row-20'd2)<<4)+((row-20'd2)<<3)+((row-20'd2)<<2)+((row-20'd2)<<1);//new col,row. col+row*30
				CONV0_READ_9:ROM_IM_A=((row-20'd1)<<4)+((row-20'd1)<<3)+((row-20'd1)<<2)+((row-20'd1)<<1);//new row. row*30
				default:ROM_IM_A=column+20'd1+((row-20'd2)<<4)+((row-20'd2)<<3)+((row-20'd2)<<2)+((row-20'd2)<<1);
			endcase
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b1;
			SRAM_AA=20'd0;
			SRAM_AB=(column-20'd2)+((row-20'd2)<<4)+((row-20'd2)<<3)+((row-20'd2)<<2)+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);//col+row*28+filter*784

		end
		CONV0_READ_C:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;
			
			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			ROM_IM_A=(n_state==CONV0_NOP)?(column+(row<<4)+(row<<3)+(row<<2)+(row<<1)):(column+((row+20'd1)<<4)+((row+20'd1)<<3)+((row+20'd1)<<2)+((row+20'd1)<<1));
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
		end
		CONV0_READ_9:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			if(n_state==CONV0_NOP) ROM_IM_A=(column+(row<<4)+(row<<3)+(row<<2)+(row<<1));
			else begin
				case(counter)
					4'd2:ROM_IM_A=(((row+2'd1)<<4)+((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1));
					4'd5:ROM_IM_A=(((row+2'd1)<<4)+((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1));
					//4'd8:ROM_IM_A=(column+(row<<4)+(row<<3)+(row<<2)+(row<<1));
					default:ROM_IM_A=column+20'd1+(row<<4)+(row<<3)+(row<<2)+(row<<1);
				endcase
			end
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
		end
		CONV0_NOP:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			ROM_IM_A=(column+(row<<4)+(row<<3)+(row<<2)+(row<<1));
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
		end
		CONV0_DONE:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
		end
//------------------------------------------------------CONV0------------------------------------------------------------------
//-----------------------------------------------------POOLING1----------------------------------------------------------------
		POOLING1_INIT:begin
			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b0;
			ROM_B_CS=1'b0;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);//filter*784
			SRAM_AB=20'd4704+(filter_weight<<7)+(filter_weight<<6)+(filter_weight<<2);//4704+filter*196
		end
		POOLING1_READ:begin
			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b0;
			ROM_B_CS=1'b0;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=(n_state==POOLING1_WRITE)?1'b1:1'b0;
			SRAM_AA=20'd0+column+(row<<4)+(row<<3)+(row<<2)+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
			SRAM_AB=20'd4704+column+(row<<3)+(row<<2)+(row<<1)+(filter_weight<<7)+(filter_weight<<6)+(filter_weight<<2);
		end
		POOLING1_WRITE:begin
			ROM_IM_CS=1'b0;//
			ROM_W_CS=1'b0;//
			ROM_B_CS=1'b0;//

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0+column+(row<<4)+(row<<3)+(row<<2)+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
			SRAM_AB=20'd4704+((column-20'd1)>>2)+(((row-20'd1)<<2)+((row-20'd1)<<1)+(row-20'd1))+(filter_weight<<7)+(filter_weight<<6)+(filter_weight<<2);
		end
		POOLING1_DONE:begin
			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b0;
			ROM_B_CS=1'b0;
	
			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0+(filter_weight<<9)+(filter_weight<<8)+(filter_weight<<4);
			SRAM_AB=20'd4704+(filter_weight<<7)+(filter_weight<<6)+(filter_weight<<2);

		end
//-----------------------------------------------------POOLING1----------------------------------------------------------------
//------------------------------------------------------CONV2------------------------------------------------------------------
		CONV2_INIT:begin

			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_IM_A=20'd0;
			ROM_W_A=20'd9+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;//filter*54+channel*9+9
			ROM_B_A=20'd6+(filter_weight);//6+filter

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd4704+(channel<<7)+(channel<<6)+(channel<<2);//channel*196+4704
			SRAM_AB=20'd0+(filter_weight<<7)+(filter_weight<<4)+(row<<3)+(row<<2)+column;//filter*144+row*9+column

		end
		CONV2_READ_W:begin
			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b1;
			ROM_B_OE=1'b1;

			ROM_IM_A=20'd0;
			case(counter)
				4'd0:ROM_W_A=20'd1+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd1:ROM_W_A=20'd2+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd2:ROM_W_A=20'd3+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd3:ROM_W_A=20'd4+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd4:ROM_W_A=20'd5+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd5:ROM_W_A=20'd6+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd6:ROM_W_A=20'd7+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				4'd7:ROM_W_A=20'd8+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				//4'd8:ROM_W_A=20'd0+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
				default:ROM_W_A=20'd1+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
			endcase
			ROM_B_A=20'd6+(filter_weight);

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			case(counter)//
				4'd0:SRAM_AA=20'd1+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd1:SRAM_AA=20'd2+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd2:SRAM_AA=20'd3+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd3:SRAM_AA=20'd4+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd4:SRAM_AA=20'd5+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd5:SRAM_AA=20'd6+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd6:SRAM_AA=20'd7+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				4'd7:SRAM_AA=20'd8+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				//4'd8:SRAM_AA=20'd0+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				default:SRAM_AA=20'd1+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			endcase
			SRAM_AB=20'd0+(filter_weight<<7)+(filter_weight<<4);//filter*144

		end
		CONV2_WRITE:begin
			ROM_IM_CS=1'b0;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;
			
			ROM_W_A=20'd9+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd6+(filter_weight);

			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b1;
			
			/*if(n_state==CONV2_NOP) SRAM_AA=(column+(row<<3)+(row<<2)+(row<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			else begin
				case(counter)
					4'd2:SRAM_AA=(((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
					4'd5:SRAM_AA=(((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
					//4'd8:ROM_IM_A=(column+(row<<4)+(row<<3)+(row<<2)+(row<<1));
					default:SRAM_AA=column+20'd1+(row<<3)+(row<<2)+(row<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				endcase
			end*/
			case(n_state)
				CONV2_READ_C:SRAM_AA=column+20'd1+((row-20'd2)<<3)+((row-20'd2)<<2)+((row-20'd2)<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);//new col,row. col+row*14
				CONV2_READ_9:SRAM_AA=((row-20'd1)<<3)+((row-20'd1)<<2)+((row-20'd1)<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);//new row. row*14
				default:SRAM_AA=column+20'd1+((row-20'd2)<<3)+((row-20'd2)<<2)+((row-20'd2)<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			endcase
			SRAM_AB=(column-20'd2)+((row-20'd2)<<3)+((row-20'd2)<<2)+(filter_weight<<7)+(filter_weight<<4);//col+row*12+filter*144

		end
		CONV2_READ_C:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;
			
			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=column+((row+20'd1)<<3)+((row+20'd1)<<2)+((row+20'd1)<<1)+20'd9+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			//SRAM_CENA=1'b0;
			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=column+((row+20'd1)<<3)+((row+20'd1)<<2)+((row+20'd1)<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);//col+row*14+4704+channel*196
			SRAM_AB=20'd0+(filter_weight<<7)+(filter_weight<<4);
		end
		CONV2_READ_9:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=column+((row+20'd1)<<3)+((row+20'd1)<<2)+((row+20'd1)<<1)+20'd9+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			//SRAM_CENA=1'b0;
			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			//SRAM_AA=column+((row+20'd1)<<3)+((row+20'd1)<<2)+((row+20'd1)<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			if(n_state==CONV2_NOP) SRAM_AA=(column+(row<<3)+(row<<2)+(row<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			else begin
				case(counter)
					4'd2:SRAM_AA=(((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
					4'd5:SRAM_AA=(((row+2'd1)<<3)+((row+2'd1)<<2)+((row+2'd1)<<1))+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
					//4'd8:ROM_IM_A=(column+(row<<4)+(row<<3)+(row<<2)+(row<<1));
					default:SRAM_AA=column+20'd1+(row<<3)+(row<<2)+(row<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
				endcase
			end
			SRAM_AB=20'd0+(filter_weight<<7)+(filter_weight<<4);
		end
		CONV2_NOP:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b1;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b1;

			ROM_W_A=20'd0+(filter_weight<<5)+(filter_weight<<4)+(filter_weight<<2)+(filter_weight<<1)+(channel<<3)+channel;
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0;

			//SRAM_CENA=1'b0;
			SRAM_CENA=1'b1;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=column+(row<<3)+(row<<2)+(row<<1)+20'd4704+(channel<<7)+(channel<<6)+(channel<<2);
			SRAM_AB=(column-20'd2)+((row-20'd2)<<3)+((row-20'd2)<<2)+20'd0+(filter_weight<<7)+(filter_weight<<4);
		end
		CONV2_DONE:begin
			ROM_IM_CS=1'b1;
			ROM_W_CS=1'b1;
			ROM_B_CS=1'b1;

			ROM_IM_OE=1'b0;
			ROM_W_OE=1'b0;
			ROM_B_OE=1'b0;

			ROM_W_A=20'd0+(filter_weight<<3)+(filter_weight);
			ROM_IM_A=20'd0;
			ROM_B_A=20'd0+(filter_weight);

			SRAM_CENA=1'b0;
			SRAM_CENB=1'b1;
			SRAM_WENB=1'b0;
			SRAM_AA=20'd0;
			SRAM_AB=20'd0+(filter_weight<<7)+(filter_weight<<4);
		end
//------------------------------------------------------CONV2------------------------------------------------------------------
//-----------------------------------------------------POOLING2----------------------------------------------------------------
//-----------------------------------------------------POOLING2----------------------------------------------------------------

	default:begin
		ROM_IM_CS=1'b0;//
		ROM_W_CS=1'b0;//
		ROM_B_CS=1'b0;//

		ROM_IM_OE=1'b0;
		ROM_W_OE=1'b0;
		ROM_B_OE=1'b0;

		ROM_W_A=20'd0;
		ROM_IM_A=20'd0;
		ROM_B_A=20'd0;

		SRAM_CENA=1'b0;
		SRAM_CENB=1'b0;
		SRAM_WENB=1'b0;
		SRAM_AA=20'd0;
		SRAM_AB=20'd0;

	end
	endcase
 end
 always@(*)begin
	PE1_IF_w=tsel_if[0];
	PE2_IF_w=tsel_if[1];
	PE3_IF_w=tsel_if[2];

	PE1_W_w=tsel_w[0];
	PE2_W_w=tsel_w[1];
	PE3_W_w=tsel_w[2];
 end
//------------------------------------------------------CONV------------------------------------------------------------------
 always@(state)DONE=(state==FINISH)?1'b1:1'b0;
	
endmodule
