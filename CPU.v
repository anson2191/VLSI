`include "def.v"
`include "Adder.v"
`include "ALU.v"
`include "ALUcontrol.v"
`include "Comparator.v"
`include "Controller.v"
`include "Forwarding_unit.v"
`include "Hazard_detection_unit.v"
`include "MUX2to1_32b.v"
`include "MUX4to1_32b.v"
`include "PC.v"
`include "Program_counter.v"
`include "Shift_left_2.v"
`include "Sign_extend.v"
`include ".v"
`include ".v"
`include ".v"
`include ".v"
module CPU(
	CLKA,
	CLKB,
	//IF
	Instruction_MEM_Address,//output
	Instruction_MEM_Read_Data,//input
	//MEM
	Data_MEM_Address,//output
	Data_MEM_Read_Enable,//output
	Data_MEM_Write_Data,//output
	Data_MEM_Write_Enable,//output
	Data_MEM_Read_Data//input
);
	input CLKA,CLKB,rst;
	input [`INTERNAL_BITS-1:0] Instruction_MEM_Read_Data, Data_MEM_Read_Data;
	
	output [`INTERNAL_BITS-1:0] Instruction_MEM_Address;
	output [`DATA_MEM_ADDR_BITS-1:0] Data_MEM_Address;
	output Data_MEM_Read_Enable;
	output Data_MEM_Write_Enable;
	output [`INTERNAL_BITS-1:0] Data_MEM_Write_Data;

	//IF--------
	MUX4to1_32b M1(	
	.Data_in1(A1_out),
	.Data_in2(32'h8000_0180),
	.Data_in3(A2_out),
	.Data_in4(32'h8000_0180),
	.sel(PCSrc),
	.Data_out(M1_out)
	);
	
	PC P1(
		.clk(CLKA),
		.in(M1_out),
		.hold(),//----------------------------
		.out(Instruction_MEM_Address)
	);
	
	Adder A1(
		.Data_in1(Instruction_MEM_Address),
		.Data_in2(32'd4),
		.Result(A1_out)
	);
	//IF--------
	IF_ID_REG R1(
		.clk(CLKB),//neg edge
		.rst(rst),
		.Instruction_in(Instruction_MEM_Read_Data),
		.Instruction_out(R1_out),
		.PC_in(A1_out),
		.PC_out(A2_in2),
	);
	//ID----------
	Adder A2(
		.Data_in1(),//------------------------------------
		.Data_in2(A2_in2),
		.Result(A2_out)
	);
	
	Hazard_detection_unit H1(
		.IF_ID_RS(),
		.IF_ID_RT(),
		.ID_EX_RT(),
		.ID_EX_RD(),
		.ID_EX_MemRead(),
		.ID_EX_RegWrite(),
		.branch(),
		.EX_MEM_RT(),
		.Hold(),
		.ID_Flush(),
		.EX_Flush()
	);
	
	Controller C1(
		.clk(),
		.rst(),
		.Instruction(),
		.Branch_taken(),
		.IF_flush(),
		.ID_flush(),
		.EX_flush(),
		.done(),
		.WB(),
		.M(),
		.EX()
	);
	
	or ();
	
	MUX4to1_32b M2(	
		.Data_in1(),
		.Data_in2(),
		.Data_in3(),
		.Data_in4(),
		.sel(),
		.Data_out()
	);
	
	Register REG1(
		.CLKA(),
		.rst(),
		.Read_reg1(),
		.Read_reg2(),
		.Read_data1(),
		.Read_data2(),
		.CLKB(),
		.Write_enable(),
		.Write_reg(),
		.Write_data()
	);
	
	Comparator CP1();
	
	Sign_extend S1();
	//ID------------
	ID_EX_REG R2(
		.clk(),//neg edge
		.rst(),
		.EX_in(),
		.WB_in(),
		.M_in(),
		.EX_out(),
		.WB_out(),
		.M_out(),
		.Read_data1_in(),
		.Read_data2_in(),
		.Read_data1_out(),
		.Read_data2_out(),
		.Data1_address_in(),
		.Data1_address_out(),
		.Data2_address_in(),
		.Data2_address_out(),
		.Sign_extend_in(),
		.Sign_extend_out(),
		.Instruction_20_16_in(),
		.Instruction_15_11_in(),
		.Instruction_20_16_out(),
		.Instruction_15_11_out(),
		.PC_in(),
		.PC_out(),
	);
	//EX-------------
	MUX4to1_32b M3(	
		.Data_in1(),
		.Data_in2(),
		.sel(),
		.Data_out()
	);
	
	MUX4to1_32b M4(	
		.Data_in1(),
		.Data_in2(),
		.sel(),
		.Data_out()
	);
	
	MUX4to1_32b M5(	
		.Data_in1(),
		.Data_in2(),
		.Data_in3(),
		.Data_in4(),
		.sel(),
		.Data_out()
	);
	
	MUX4to1_32b M6(	
		.Data_in1(),
		.Data_in2(),
		.Data_in3(),
		.Data_in4(),
		.sel(),
		.Data_out()
	);
	
	MUX4to1_32b M7(	
		.Data_in1(),
		.Data_in2(),
		.Data_in3(),
		.Data_in4(),
		.sel(),
		.Data_out()
	);
	
	ALU ALU1(
		.src1(),
		.src2(),
		.ALUcontrol(),
		.Zero(),
		.Result()
	);
	
	Forwarding_unit F1(
		.ID_EX_RS(),
		.ID_EX_RT(),
		.EX_MEM_RD(),
		.MEM_WB_RD(),
		.EX_MEM_RegWrite(),
		.MEM_WB_RegWrite(),
		.src1_mux(),
		.src2_mux()
	);
	//EX-----------------
	EX_MEM_REG R3(
		.clk(),//neg edge
		.rst(),
		.WB_in(),
		.M_in(),
		.WB_out(),
		.M_out(),
		.ALU_result_in(),
		.ALU_result_out(),
		.ALU_src2_in(),
		.ALU_src2_out(),
		.ALU_zero_in(),
		.ALU_zero_out(),
		.PC_in(),
		.PC_out(),
		.REG_dst_in(),
		.REG_dst_out()
	);
	//MEM---------------------
	//MEM---------------------
	MEM_WB_REG R4(
		.clk(),//neg edge
		.rst(),
		.WB_in(),
		.WB_out(),
		.Address_in(),
		.Address_out(),
		.Read_data_in(),
		.Read_data_out(),
	);
	//WB---------------------
	MUX4to1_32b M8(	
		.Data_in1(),
		.Data_in2(),
		.sel(),
		.Data_out()
	);
	//WB------------------------

endmodule
